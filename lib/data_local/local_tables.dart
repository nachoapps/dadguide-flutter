import 'dart:convert';
import 'dart:io';

import 'package:dadguide2/screens/team_editor/team_data.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/foundation.dart';
import 'package:moor/moor.dart';
import 'package:moor_ffi/moor_ffi.dart';
import 'package:rxdart/rxdart.dart';

part 'local_tables.g.dart';
part 'src/builds.dart';

// Locally-stored database tables.

/// Stores builds (1-3 teams, title, description).
class Builds extends Table {
  IntColumn get buildId => integer().autoIncrement()();

  TextColumn get title => text().withDefault(Constant(''))();
  TextColumn get description => text().withDefault(Constant(''))();

  TextColumn get team1 => text().map(TeamConverter())();
  TextColumn get team2 => text().map(TeamConverter()).nullable()();
  TextColumn get team3 => text().map(TeamConverter()).nullable()();
}

@UseMoor(
  daos: [BuildsDao],
  tables: [Builds],
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
}

// stores preferences as strings
class TeamConverter extends TypeConverter<Team, String> {
  const TeamConverter();
  @override
  Team mapToDart(String fromDb) {
    if (fromDb == null) {
      return null;
    }
    return Team.fromJson(json.decode(fromDb) as Map<String, dynamic>);
  }

  @override
  String mapToSql(Team value) {
    if (value == null) {
      return null;
    }

    return json.encode(value.toJson());
  }
}
