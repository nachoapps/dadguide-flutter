import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_fimber/flutter_fimber.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'tables.dart';

class DatabaseHelper {
  // TODO: make this injected
  static final dio = Dio();
  static final _dbRemotePath = 'https://f002.backblazeb2.com/file/dadguide-data/db/dadguide.sqlite';
  static final _dbName = 'dadguide.sqlite';
  static final DatabaseHelper instance = DatabaseHelper._internal();

  DadGuideDatabase _database;
  DatabaseHelper._internal();

  // only have a single app-wide reference to the database
  Future<DadGuideDatabase> get database async {
    await ensureDb();
    return _database;
  }

  Future<void> ensureDb() async {
    if (_database != null) {
      return;
    }

    var dbFileExists = await _dbFileExists();
    if (!dbFileExists) {
      await _downloadDb();
    }
    _database = DadGuideDatabase(await _dbFilePath());
  }

  Future<void> forceRedownloadDb() async {
    Fimber.d('Forcing DB Reload');
    _database = null;
    await _deleteDb();
    await ensureDb();
    Fimber.d('Reload Complete');
  }

  Future<void> _createDb() async {
    Fimber.d('Creating DB');
    _database = new DadGuideDatabase(await _dbFilePath());
  }

  Future<void> _deleteDb() async {
    Fimber.d('Deleting DB');
    await File(await _dbFilePath()).delete();
  }

  Future<void> _downloadDb() async {
    Fimber.d('Downloading DB');
    await dio.download(_dbRemotePath, await _dbFilePath());
  }

  Future<bool> _dbFileExists() async {
    return FileSystemEntity.typeSync(await _dbFilePath()) == FileSystemEntityType.file;
  }

  Future<String> _dbFilePath() async {
    return join(await sqflite.getDatabasesPath(), _dbName);
  }
}
