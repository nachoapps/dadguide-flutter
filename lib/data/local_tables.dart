import 'dart:io';

import 'package:fimber/fimber.dart';
import 'package:flutter/foundation.dart';
import 'package:moor/moor.dart';
import 'package:moor_ffi/moor_ffi.dart';
import 'package:rxdart/rxdart.dart';

part 'local_tables.g.dart';

// Locally-stored database tables.

/// Stores the individual team entries; six monsters, no description.
@DataClassName("TeamRow")
class Teams extends Table {
  IntColumn get teamId => integer().autoIncrement()();

  TextColumn get jsonData => text()();
}

@UseMoor(
  daos: [],
  tables: [
    Teams,
  ],
  queries: {},
)
class LocalStorageDatabase extends _$LocalStorageDatabase {
  LocalStorageDatabase(String dbPath) : super(VmDatabase(File(dbPath)));
  LocalStorageDatabase.connect(DatabaseConnection c) : super.connect(c);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(onCreate: (Migrator m) {
      Fimber.i('Initial local storage database creation');
      return m.createAll();
    }, onUpgrade: (Migrator m, int from, int to) {
      Fimber.i('Upgrade local storage database from:$from to:$to');
      return m.createAll();
    });
  }

  ValueStream<List<TeamRow>> teamsStream() {
    return ValueConnectableStream(select(teams).watch())..autoConnect();
  }

  void saveTeam(TeamRow team) async {
    await into(teams).insert(team, mode: InsertMode.insertOrReplace);
  }

  void deleteTeam(TeamRow team) async {
    await delete(teams).delete(team);
  }
}
