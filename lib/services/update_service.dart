import 'dart:async';
import 'dart:io' show HttpStatus;

import 'package:convert/convert.dart';
import 'package:dadguide2/components/config/service_locator.dart';
import 'package:dadguide2/components/config/settings_manager.dart';
import 'package:dadguide2/components/firebase/analytics.dart';
import 'package:dadguide2/components/notifications/notifications.dart';
import 'package:dadguide2/components/ui/task_progress.dart';
import 'package:dadguide2/data/tables.dart';
import 'package:dadguide2/services/endpoints.dart';
import 'package:dio/dio.dart';
import 'package:flutter_fimber/flutter_fimber.dart';
import 'package:moor/moor.dart';
import 'package:moor_flutter/moor_flutter.dart';
import 'package:tuple/tuple.dart';

// TODO: convert this to being supplied by getIt.
final updateManager = UpdateManager._();

class ApplicationUpdateRequired implements Exception {}

/// Singleton that controls updates to the database.
///
/// Publishes two streams, one for 'task updates' which can be used to update the user-friendly UI,
/// and one which declares that an update has completed.
class UpdateManager with TaskPublisher {
  // Ignoring this warning because this stays open as long as the app does.
  // ignore: close_sinks
  final _controller = StreamController.broadcast();
  StreamSink<void> get _updateSink => _controller.sink;

  /// This stream will emit a value every time the update completes (as well as any errors).
  Stream<void> get updateStream => _controller.stream;

  /// If an update is currently running, it's in here.
  Future<void> runningTask;

  UpdateManager._();

  /// Kicks off an update. If an update is already running, waits on that update to complete instead
  /// of spawning a new task.
  ///
  /// Returns true if the invocation actually started an update as opposed to waiting on an existing
  /// one.
  Future<bool> start() async {
    if (runningTask != null) {
      // Already running, so wait for that to finish.
      await runningTask;
      return false;
    }

    recordEvent('update_starting');
    var instance = UpdateTask(getIt<DadGuideDatabase>(), getIt<Dio>(), getIt<Endpoints>());
    // Proxy task updates to listeners.
    instance.pipeTo(this);

    try {
      runningTask = instance.start();
      await runningTask;
      _updateSink.add(null);
      recordEvent('update_succeeded');
      return true;
    } catch (ex, st) {
      recordEvent('update_failed');
      Fimber.e('Update failed', ex: ex, stacktrace: st);
      _updateSink.addError(ex, st);
      throw ex;
    } finally {
      runningTask = null;
    }
  }
}

/// Contacts the server to get the newest timestamp for each table; if a table has an older max
/// timestamp locally, pulls all the data since that timestamp and upserts it.
class UpdateTask with TaskPublisher {
  final DadGuideDatabase _database;
  final Dio _dio;
  final Endpoints _endpoints;

  UpdateTask(this._database, this._dio, this._endpoints);

  void _pub(int index, int count, {int progress}) {
    publish(TaskProgress('Updating', index, count, TaskStatus.started, progress: progress));
  }

  Future<void> start() async {
    Fimber.i('Checking for table updates');
    Prefs.updateRan();

    // Pull the remote table timestamp info.
    _pub(0, 0);
    var timestamps = await _retrieveTimestamps();

    // Compare the remote table timestamps against the local one to determine what work to do.
    List<Tuple2<TableInfo, int>> tablesToUpdate = [];
    for (var table in _updateOrder()) {
      var tableTstamp = await _database.maxTstamp(table) ?? 0;
      var remoteTstamp = timestamps[table.actualTableName] ?? 0;

      if (remoteTstamp > tableTstamp) {
        Fimber.i('Table $table needs update, $remoteTstamp > $tableTstamp');
        tablesToUpdate.add(Tuple2(table, tableTstamp));
      }
    }

    // For each table that needs updating, run the update and publish updates as we go.
    for (var tableAndTstamp in tablesToUpdate) {
      await _updateTable(
          tableAndTstamp.item1,
          tableAndTstamp.item2,
          (p) =>
              _pub(tablesToUpdate.indexOf(tableAndTstamp) + 1, tablesToUpdate.length, progress: p));
    }

    var deletedRowsTs = timestamps['deleted_rows'] ?? 0;
    await _processDeletedRows(deletedRowsTs);

    Fimber.i('Table update complete');
  }

  // Executes the update for each table.
  Future<void> _updateTable(TableInfo table, int localTstamp, void Function(int) progressFn) async {
    // TODO: this definitely needs batching, it's slow as fuck

    var data = await _retrieveTableData(table.actualTableName, tstamp: localTstamp);
    Fimber.i('Retrieved ${data.length} rows for ${table.actualTableName}');
    int complete = 0;
    progressFn(complete * 100 ~/ data.length);
    for (var row in data) {
//      var item = table.map(row) as Insertable;
//      await _database.upsertData(table, item);

      // TODO: ughhh this is super gross and must be fixable but dart is complaining about types.
      if (table == _database.activeSkills) {
        await _database.upsertData(_database.activeSkills, _database.activeSkills.map(row));
      } else if (table == _database.activeSkillTags) {
        await _database.upsertData(_database.activeSkillTags, _database.activeSkillTags.map(row));
      } else if (table == _database.awakenings) {
        await _database.upsertData(_database.awakenings, _database.awakenings.map(row));
      } else if (table == _database.awokenSkills) {
        await _database.upsertData(_database.awokenSkills, _database.awokenSkills.map(row));
      } else if (table == _database.drops) {
        await _database.upsertData(_database.drops, _database.drops.map(row));
      } else if (table == _database.dungeons) {
        await _database.upsertData(_database.dungeons, _database.dungeons.map(row));
      } else if (table == _database.eggMachines) {
        await _database.upsertData(_database.eggMachines, _database.eggMachines.map(row));
      } else if (table == _database.encounters) {
        await _database.upsertData(_database.encounters, _database.encounters.map(row));
      } else if (table == _database.enemyData) {
        // EnemyData needs custom deserialization since it has an encoded blob.
        var enemyId = row['enemy_id'] as int;
        var status = row['status'] as int;
        var encodedBehavior = row['behavior'] as String;
        var tstamp = row['tstamp'] as int;
        encodedBehavior = encodedBehavior.substring(2); // Strip the 0x prefix
        var decodedBehavior = Uint8List.fromList(hex.decode(encodedBehavior));
        var item = EnemyDataItem(
          enemyId: enemyId,
          status: status,
          behavior: decodedBehavior,
          tstamp: tstamp,
        );
        await _database.upsertData(_database.enemyData, item);
      } else if (table == _database.enemySkills) {
        await _database.upsertData(_database.enemySkills, _database.enemySkills.map(row));
      } else if (table == _database.evolutions) {
        await _database.upsertData(_database.evolutions, _database.evolutions.map(row));
      } else if (table == _database.exchanges) {
        await _database.upsertData(_database.exchanges, _database.exchanges.map(row));
      } else if (table == _database.leaderSkills) {
        await _database.upsertData(_database.leaderSkills, _database.leaderSkills.map(row));
      } else if (table == _database.leaderSkillTags) {
        await _database.upsertData(_database.leaderSkillTags, _database.leaderSkillTags.map(row));
      } else if (table == _database.monsters) {
        await _database.upsertData(_database.monsters, _database.monsters.map(row));
      } else if (table == _database.schedule) {
        await _database.upsertData(_database.schedule, _database.schedule.map(row));
      } else if (table == _database.series) {
        await _database.upsertData(_database.series, _database.series.map(row));
      } else if (table == _database.subDungeons) {
        await _database.upsertData(_database.subDungeons, _database.subDungeons.map(row));
      } else {
        throw 'Unexpected table: ${table.actualTableName}';
      }
      complete++;
      progressFn(complete * 100 ~/ data.length);
    }

    // In case new scheduled events were inserted, reschedule all alarms.
    getIt<NotificationManager>().ensureEventsScheduled();
  }

  /// Gets the server-side max timestamp for each table.
  Future<Map<String, int>> _retrieveTimestamps() async {
    var items = await _retrieveTableData('timestamps');
    return Map.fromIterable(items, key: (i) => i['name'], value: (i) => i['tstamp']);
  }

  /// Gets the actual data for a table that needs upserting.
  Future<List<Map<String, dynamic>>> _retrieveTableData(String tableName, {int tstamp}) async {
    var url = _endpoints.api(tableName, tstamp: tstamp);
    var resp = await _dio.get(url);
    if (resp.statusCode == HttpStatus.notAcceptable) {
      throw ApplicationUpdateRequired();
    }
    var data = resp.data;
    var items = data['items'] as List<dynamic>;
    return items.cast<Map<String, dynamic>>();
  }

  /// Controls the actual order that we update tables. This probably doesn't matter, since Sqlite
  /// doesn't actually enforce foreign key references at the moment. Tables need to be added here
  /// or they wont be updated.
  List<TableInfo> _updateOrder() {
    return [
      _database.activeSkills,
      _database.activeSkillTags,
      _database.awokenSkills,
      _database.leaderSkills,
      _database.leaderSkillTags,
      _database.series,
      _database.monsters,
      _database.eggMachines,
      _database.exchanges,
      _database.evolutions,
      _database.awakenings,
      _database.dungeons,
      _database.subDungeons,
      _database.encounters,
      _database.drops,
      _database.schedule,
      _database.enemySkills,
      _database.enemyData,
    ];
  }

  /// Get the table record by name, useful for the delete operation.
  TableInfo tableByName(String tableName) {
    for (var table in _updateOrder()) {
      if (table.actualTableName == tableName) {
        return table;
      }
    }
    return null;
  }

  /// If necessary, pull the deleted_rows table and delete the rows it contains.
  ///
  /// When complete, update the local timestamp (since we don't keep deleted rows locally).
  Future<void> _processDeletedRows(int deletedRowsTs) async {
    var deleteFailed = false;
    var tsLastDeleted = Prefs.tsLastDeleted;
    if (deletedRowsTs > tsLastDeleted) {
      try {
        var rowsToDelete = await _retrieveTableData('deleted_rows', tstamp: tsLastDeleted);
        for (var row in rowsToDelete) {
          try {
            var tableName = row['table_name'] ?? '';
            var tableRowId = row['table_row_id'] ?? 0;
            if (tableName == '' || tableRowId == 0) {
              recordEvent('delete_bad_row');
              Fimber.w('Cannot delete table row: $tableName - $tableRowId');
              continue;
            }
            var tableInfo = tableByName(tableName);
            if (tableInfo == null) {
              recordEvent('delete_missing_table');
              Fimber.w('Cannot not locate table to delete from: $tableName $tableRowId');
              continue;
            }
            var tablePrimaryKey = tableInfo.$primaryKey.first.escapedName;
            var deleteSql = 'DELETE FROM $tableName WHERE $tablePrimaryKey == $tableRowId';
            Fimber.v('Deleting row: $deleteSql');
            _database.customUpdate(deleteSql);
          } catch (ex) {
            deleteFailed = true;
            Fimber.e('Failed to delete row', ex: ex);
          }
        }
      } catch (ex) {
        Fimber.e('Failed to process deleted rows', ex: ex);
      } finally {
        Prefs.tsLastDeleted = deletedRowsTs;
      }
    }
    recordEvent(deleteFailed ? 'delete_failed' : 'delete_succeded');
  }
}
