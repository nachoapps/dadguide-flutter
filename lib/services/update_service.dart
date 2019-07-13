import 'package:dadguide2/components/service_locator.dart';
import 'package:dadguide2/components/task_progress.dart';
import 'package:dadguide2/data/database.dart';
import 'package:dadguide2/data/tables.dart';
import 'package:dadguide2/services/endpoints.dart';
import 'package:dio/dio.dart';
import 'package:flutter_fimber/flutter_fimber.dart';
import 'package:moor/moor.dart';
import 'package:tuple/tuple.dart';

final updateManager = UpdateManager._();

class UpdateManager with TaskPublisher {
  Future<void> runningTask;

  UpdateManager._();

  Future<bool> start() async {
    if (runningTask != null) {
      await runningTask;
      return false;
    }

    var db = await DatabaseHelper.instance.database;
    var instance = UpdateTask(db, getIt<Dio>(), getIt<Endpoints>());
    instance.pipeTo(this);
    try {
      runningTask = instance.start();
      await runningTask;
      return true;
    } finally {
      runningTask = null;
    }
  }
}

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
    _pub(0, 0);
    var timestamps = await _retrieveTimestamps();

    List<Tuple2<TableInfo, int>> tablesToUpdate = [];
    for (var table in _updateOrder()) {
      var tableTstamp = await _database.maxTstamp(table) ?? 0;
      var remoteTstamp = timestamps[table.actualTableName] ?? 0;

      if (remoteTstamp > tableTstamp) {
        Fimber.v('Table $table needs update, $remoteTstamp > $tableTstamp');
        tablesToUpdate.add(Tuple2(table, tableTstamp));
      }
    }

    for (var tableAndTstamp in tablesToUpdate) {
      await _updateTable(
          tableAndTstamp.item1,
          tableAndTstamp.item2,
          (p) =>
              _pub(tablesToUpdate.indexOf(tableAndTstamp) + 1, tablesToUpdate.length, progress: p));
    }

    Fimber.i('Table update complete');
  }

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
      } else if (table == _database.awokenSkills) {
        await _database.upsertData(_database.awokenSkills, _database.awokenSkills.map(row));
      } else if (table == _database.leaderSkills) {
        await _database.upsertData(_database.leaderSkills, _database.leaderSkills.map(row));
      } else if (table == _database.series) {
        await _database.upsertData(_database.series, _database.series.map(row));
      } else if (table == _database.monsters) {
        await _database.upsertData(_database.monsters, _database.monsters.map(row));
      } else if (table == _database.evolutions) {
        await _database.upsertData(_database.evolutions, _database.evolutions.map(row));
      } else if (table == _database.awakenings) {
        await _database.upsertData(_database.awakenings, _database.awakenings.map(row));
      } else if (table == _database.dungeons) {
        await _database.upsertData(_database.dungeons, _database.dungeons.map(row));
      } else if (table == _database.subDungeons) {
        await _database.upsertData(_database.subDungeons, _database.subDungeons.map(row));
      } else if (table == _database.encounters) {
        await _database.upsertData(_database.encounters, _database.encounters.map(row));
      } else if (table == _database.drops) {
        await _database.upsertData(_database.drops, _database.drops.map(row));
      } else if (table == _database.schedule) {
        await _database.upsertData(_database.schedule, _database.schedule.map(row));
      } else {
        throw 'Unexpected table: ${table.actualTableName}';
      }
      complete++;
      progressFn(complete * 100 ~/ data.length);
    }
  }

  Future<Map<String, int>> _retrieveTimestamps() async {
    var items = await _retrieveTableData('timestamps');
    return Map.fromIterable(items, key: (i) => i['name'], value: (i) => i['tstamp']);
  }

  Future<List<Map<String, dynamic>>> _retrieveTableData(String tableName, {int tstamp}) async {
    var url = _endpoints.api(tableName, tstamp: tstamp);
    var resp = await _dio.get(url);
    var data = resp.data;
    var items = data['items'] as List<dynamic>;
    return items.cast<Map<String, dynamic>>();
  }

  List<TableInfo> _updateOrder() {
    return [
      _database.activeSkills,
      _database.awokenSkills,
      _database.leaderSkills,
      _database.series,
      _database.monsters,
      _database.evolutions,
      _database.awakenings,
      _database.dungeons,
      _database.subDungeons,
      _database.encounters,
      _database.drops,
      _database.schedule,
    ];
  }
}
