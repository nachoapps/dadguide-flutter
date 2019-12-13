import 'dart:io';

import 'package:dadguide2/components/service_locator.dart';
import 'package:dadguide2/components/settings_manager.dart';
import 'package:dadguide2/services/endpoints.dart';
import 'package:flutter_fimber/flutter_fimber.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

class ResourceHelper {
  /// Controls the logical DB version, stored in a preference key and used to determine if we need
  /// to download the initial data db again. This should probably keep in sync with `dbZipFileName`
  /// but can be adjusted to force a re-download of the data for testing purposes.
  static const dbVersion = 3;

  /// Server-side database version name. Should be updated whenever the structure of the DB changes.
  static const dbZipFileName = 'v2_dadguide.sqlite.zip';

  /// Server-side icon/awakening/latent zip file name. Probably never changes.
  static const iconsZipFileName = 'icons.zip';

  /// Local file name for database. Should be stored in the sqlite database dir.
  static const dbFileName = 'dadguide.sqlite';

  /// Database should be at least 10MB.
  static const minExpectedDbSize = 1024 * 1024 * 10;

  static String remoteDbFile() {
    return getIt<Endpoints>().db(dbZipFileName);
  }

  static String remoteIconsFile() {
    return getIt<Endpoints>().db(iconsZipFileName);
  }

  static Future<bool> checkDbExists() async {
    var dbFile = File(await dbFilePath());
    var dbStat = await dbFile.stat();

    Fimber.i('Database file type: ${dbStat.type} - size: ${dbStat.size}');
    var fileExists = dbStat.type != FileSystemEntityType.notFound;

    if (!fileExists) {
      Fimber.w('Database not found, probably initial install');
      return false;
    } else if (dbStat.size < minExpectedDbSize) {
      Fimber.e('Database too small, got ${dbStat.size} wanted at least $minExpectedDbSize');
      return false;
    } else if (Prefs.currentDbVersion != dbVersion && fileExists) {
      Fimber.w('Database requires version update, got ${Prefs.currentDbVersion} wanted $dbVersion');
      await dbFile.delete();
      Prefs.currentDbVersion = dbVersion;
      return false;
    }
    Fimber.i('Database ready to use');
    return true;
  }

  static Future<File> newTmpFile(String name) async {
    var tmpDir = await getTemporaryDirectory();
    var tmpFile = File(join(tmpDir.path, name));
    if (await tmpFile.exists()) {
      await tmpFile.delete();
    }
    return tmpFile;
  }

  static Future<String> dbFilePath() async {
    return join(await sqflite.getDatabasesPath(), dbFileName);
  }
}
