import 'dart:io';

import 'package:dadguide2/components/config/settings_manager.dart';
import 'package:dadguide2/data_dadguide/tables.dart';
import 'package:flutter_fimber/flutter_fimber.dart';
import 'package:moor_ffi/moor_ffi.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:synchronized/synchronized.dart';

import 'moor_isolate.dart';

/// Wrapper for database loading and reloading.
class DatabaseHelper {
  static final _dbLock = Lock(reentrant: true);

  /// The on-disk unwrapped database file name stored in the sqlite database dir.
  static const dbName = 'dadguide.sqlite';

  /// Database should be at least 10MB.
  static const minExpectedDbSize = 1024 * 1024 * 10;

  /// Controls the logical DB version, stored in a preference key and used to determine if we need
  /// to download the initial data db again. This should probably keep in sync with `dbZipFileName`
  /// but can be adjusted to force a re-download of the data for testing purposes.
  static const dbVersion = 7;

  /// Statically loaded AwokenSkills loaded when the database is opened (for performance).
  static var allAwokenSkills = <AwokenSkill>[];

  /// Statically loaded AwokenSkillTags loaded when the database is opened (for performance).
  static var allActiveSkillTags = <ActiveSkillTag>[];

  /// Statically loaded LeaderSkillTags loaded when the database is opened (for performance).
  static var allLeaderSkillTags = <LeaderSkillTag>[];

  static Future<String> dbFilePath() async {
    return join(await sqflite.getDatabasesPath(), dbName);
  }

  static Future<Directory> dbDirectory() async {
    return Directory(await sqflite.getDatabasesPath());
  }

  /// Private constructor.
  DatabaseHelper._internal();

  /// Only one instance of this class may exist.
  static final DatabaseHelper instance = DatabaseHelper._internal();

  /// The database; might be null if it has not been loaded yet. This would occur if the database
  /// file was missing (e.g. on first run), failed validation (corrupt, needs re-download), or was
  /// intentionally deleted (e.g. on update).
  DadGuideDatabase _database;

  /// We only have a single app-wide reference to the database. It might be null if the database
  /// fails to load for some reason (see above).
  Future<DadGuideDatabase> get database async {
    // To prevent attempts from stomping on each other, use a lock to guard initialization.
    return await _dbLock.synchronized(() async {
      try {
        await _ensureDb();
      } catch (ex, st) {
        Fimber.e('Failed to ensure DB exists, oops', ex: ex, stacktrace: st);
      }
      return _database;
    });
  }

  Future<void> _ensureDb() async {
    if (_database != null) {
      return;
    }

    Fimber.i('Ensuring database file exists');
    await logDbDirContents();

    var dbFile = File(await dbFilePath());
    var dbStat = await dbFile.stat();

    Fimber.i('Database file type: ${dbStat.type} - size: ${dbStat.size}');
    var fileExists = dbStat.type != FileSystemEntityType.notFound;

    if (!fileExists) {
      Fimber.w('Database not found, probably initial install');
      return;
    } else if (dbStat.size < minExpectedDbSize) {
      // TODO: This condition might be unnecessary, consider removing it.
      Fimber.e('Database too small, got ${dbStat.size} wanted at least $minExpectedDbSize');
      await dbFile.delete();
      await logDbDirContents();
      return;
    } else if (Prefs.currentDbVersion != dbVersion && fileExists) {
      Fimber.w('Database requires version update, got ${Prefs.currentDbVersion} wanted $dbVersion');
      await dbFile.delete();
      await logDbDirContents();
      Prefs.currentDbVersion = dbVersion;
      return;
    }

    // Database seems good; try loading it and reading some data.
    Fimber.d('Creating DB');
    var tmpDatabase = DadGuideDatabase(VmDatabase(File(await dbFilePath())));

    try {
      Fimber.d('Loading static data');
      var monsterDao = MonstersDao(tmpDatabase);
      allAwokenSkills = await monsterDao.allAwokenSkills();
      allActiveSkillTags = await monsterDao.allActiveSkillTags();
      allLeaderSkillTags = await monsterDao.allLeaderSkillTags();

      // Database seems not corrupt, activate it.
      if (useIsolate) {
        // If we want to use the database on an isolate, need to shut down the temporary version.
        await tmpDatabase.close();
        tmpDatabase = null;
        // Then reopen on an isolate.
        _database = await createDadGuideDatabaseOnIsolate();
      } else {
        // If we're not using an isolate, just use the opened database.
        _database = tmpDatabase;
        tmpDatabase = null;
      }
    } catch (ex) {
      Fimber.e('Failed to get static info from db, probably corrupt', ex: ex);
      try {
        await tmpDatabase.close();
      } catch (ex) {
        Fimber.e('Failed to close corrupt database', ex: ex);
      }
      try {
        await logDbDirContents();
        await dbFile.delete();
        Fimber.i('Done deleting');
        await logDbDirContents();
      } catch (ex) {
        Fimber.e('Failed to delete corrupt database, fatal error', ex: ex);
      }
      return;
    }

    Fimber.i('Database init complete');
  }

  /// Dump the contents of the database directory to the log for debugging purposes.
  Future<void> logDbDirContents() async {
    final dirPath = await dbDirectory();
    Fimber.i('Logging database dir contents: $dirPath');
    await dirPath.list().forEach(print);
  }
}

/// If enabled, uses the isolate instead of the foreground database runner.
/// Testing shows that this reduces the lag time in the UI, although it seems
/// to be overall a bit slower.
bool useIsolate = true;

/// Create the LocalStorageDatabase on an isolate.
Future<DadGuideDatabase> createDadGuideDatabaseOnIsolate() async {
  final isolate = await createMoorIsolate(DatabaseHelper.dbName);
  final connection = await isolate.connect();
  return DadGuideDatabase.connect(connection);
}
