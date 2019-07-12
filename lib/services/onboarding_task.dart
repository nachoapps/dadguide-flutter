import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dadguide2/components/cache.dart';
import 'package:dadguide2/components/service_locator.dart';
import 'package:dadguide2/components/task.dart';
import 'package:dadguide2/data/database.dart';
import 'package:dio/dio.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:preferences/preferences.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

var onboardingManager = OnboardingTaskManager._();

enum _SubTasks {
  downloadDb,
  unpackDb,
  downloadImages,
  unpackImages,
}

var _taskNames = {
  _SubTasks.downloadDb: 'Downloading initial data',
  _SubTasks.unpackDb: 'Unpacking initial data',
  _SubTasks.downloadImages: 'Downloading icon set',
  _SubTasks.unpackImages: 'Unpacking icon set',
};

class OnboardingTaskManager {
  OnboardingTask instance;

  OnboardingTaskManager._();

  Future<bool> mustRun() async {
    return !await ResourceHelper.checkDbExists() || !PrefService.getBool('icons_downloaded');
  }

  Future<void> start() {
    if (instance != null) {
      throw 'Already started';
    }
    instance = OnboardingTask();
    return instance.start();
  }
}

class OnboardingTask with TaskPublisher {
  Future<void> start() async {
    while (!await ResourceHelper.checkDbExists()) {
      try {
        await _downloadDb();
      } catch (e) {
        Fimber.w('Downloading DB failed', ex: e);
        await Future.delayed(Duration(seconds: 5));
      }
    }

    while (!PrefService.getBool('icons_downloaded')) {
      try {
        await _downloadIcons();
        PrefService.setBool('icons_downloaded', true);
      } catch (e) {
        Fimber.w('Downloading icons failed', ex: e);
        await Future.delayed(Duration(seconds: 5));
      }
    }

    finishStream();

    await DatabaseHelper.instance.reloadDb();
  }

  Future<void> _downloadDb() async {
    File tmpFile = await _downloadFileWithProgress(
        _SubTasks.downloadDb, ResourceHelper._remoteDbZipFile, 'db.zip');

    pub(_SubTasks.unpackDb, TaskStatus.idle);
    try {
      final archive = new ZipDecoder().decodeBytes(tmpFile.readAsBytesSync());
      var archiveDbFile = archive.firstWhere((e) => e.name == ResourceHelper._dbFileName);
      var dbFile = File(await ResourceHelper._dbFilePath());
      pub(_SubTasks.unpackDb, TaskStatus.started);
      await compute(_decompressLargeFile, _UnzipArgs(archiveDbFile, dbFile));
      pub(_SubTasks.unpackDb, TaskStatus.finished);
    } catch (e) {
      pub(_SubTasks.unpackDb, TaskStatus.failed, message: 'Unexpected error: ${e.toString()}');
      throw e;
    }
  }

  Future<void> _downloadIcons() async {
    File tmpFile = await _downloadFileWithProgress(
        _SubTasks.downloadImages, ResourceHelper._remoteIconsZipFile, 'icons.zip');

    pub(_SubTasks.unpackImages, TaskStatus.idle);
    try {
      final cacheManager = getIt<PermanentCacheManager>();
      final archive = new ZipDecoder().decodeBytes(tmpFile.readAsBytesSync());
      await cacheManager.storeImageArchive(archive,
          (progress) => pub(_SubTasks.unpackImages, TaskStatus.started, progress: progress));
      pub(_SubTasks.unpackImages, TaskStatus.finished);
    } catch (e) {
      pub(_SubTasks.unpackImages, TaskStatus.failed, message: 'Unexpected error: ${e.toString()}');
      throw e;
    }
  }

  Future<File> _downloadFileWithProgress(
      _SubTasks task, String remoteZipFile, String tmpFileName) async {
    pub(task, TaskStatus.idle, progress: 0);
    try {
      File tmpFile = await ResourceHelper.newTmpFile(tmpFileName);
      await getIt<Dio>().download(
        remoteZipFile,
        tmpFile.path,
        onReceiveProgress: (received, total) {
          pub(task, TaskStatus.started, progress: received * 100 ~/ total);
        },
      );
      pub(task, TaskStatus.finished);
      return tmpFile;
    } on DioError catch (e) {
      pub(task, TaskStatus.failed, message: e.message);
      throw e;
    } catch (e) {
      pub(task, TaskStatus.failed, message: 'Unexpected error: ${e.toString()}');
      throw e;
    }
  }

  void pub(_SubTasks curTask, TaskStatus status, {int progress, String message}) {
    publish(TaskProgress(_taskNames[curTask], curTask.index + 1, _SubTasks.values.length, status,
        progress: progress, message: message));
  }
}

class ResourceHelper {
  static const _remoteDbZipFile =
      'https://f002.backblazeb2.com/file/dadguide-data/db/dadguide.sqlite.zip';
  static const _remoteIconsZipFile = 'https://f002.backblazeb2.com/file/dadguide-data/db/icons.zip';

  static const _dbFileName = 'dadguide.sqlite';

  static Future<bool> checkDbExists() async {
    return await File(await _dbFilePath()).exists();
  }

  static Future<File> newTmpFile(String name) async {
    var tmpDir = await getTemporaryDirectory();
    var tmpFile = File(join(tmpDir.path, name));
    if (await tmpFile.exists()) {
      await tmpFile.delete();
    }
    return tmpFile;
  }

  static Future<String> _dbFilePath() async {
    return join(await sqflite.getDatabasesPath(), _dbFileName);
  }
}

/// When used with compute(), efficiently extracts a file from an archive off the main thread.
void _decompressLargeFile(_UnzipArgs args) {
  args.destFile.writeAsBytesSync(args.archiveFile.content, flush: true);
}

/// Helper argument for _decompressLargeFile() received via compute().
class _UnzipArgs {
  final ArchiveFile archiveFile;
  final File destFile;

  _UnzipArgs(this.archiveFile, this.destFile);
}
