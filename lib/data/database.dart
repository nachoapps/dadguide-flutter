import 'dart:io';

import 'package:flutter/services.dart' show rootBundle, ByteData;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database _database;
  static final _databaseName = "database.sqlite";
  static final _databaseVersion = 1;

  DatabaseHelper._internal();

  // only have a single app-wide reference to the database
  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);

    print(path);
//    await File(path).delete();
    // Only copy if the database doesn't exist
    if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound) {
      print('copying');
      // Load database from asset and copy
      ByteData data =
          await rootBundle.load(join('assets', 'data', _databaseName));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      print(bytes.length);

      // Save copied asset to documents
      await new File(path).writeAsBytes(bytes);
    }

    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    print('running oncreate');
//    await db.execute('''
//          CREATE TABLE $table (
//            $columnId INTEGER PRIMARY KEY,
//            $columnName TEXT NOT NULL,
//            $columnAge INTEGER NOT NULL
//          )
//          ''');
  }
}
