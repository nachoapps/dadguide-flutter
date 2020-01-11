import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dadguide2/components/config/service_locator.dart';
import 'package:dadguide2/components/config/settings_manager.dart';
import 'package:dadguide2/components/images/cache.dart';
import 'package:dadguide2/components/task_progress.dart';
import 'package:dadguide2/data/database.dart';
import 'package:dadguide2/data/resources.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:dio/dio.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/foundation.dart';
import 'package:preferences/preferences.dart';

// TODO: convert to being supplied by getIt
var onboardingManager = OnboardingTaskManager._();

/// The different stages that the onboarding runs through.
class _SubTask {
  final int id;
  final String Function() _text;

  const _SubTask._(this.id, this._text);

  static _SubTask downloadDb = _SubTask._(1, () => localized.onboardingDownloadDb);
  static _SubTask unpackDb = _SubTask._(2, () => localized.onboardingUnpackDb);
  static _SubTask downloadImages = _SubTask._(3, () => localized.onboardingDownloadImages);
  static _SubTask unpackImages = _SubTask._(4, () => localized.onboardingUnpackImages);

  String get text => _text();

  static List<_SubTask> all = [downloadDb, unpackDb, downloadImages, unpackImages];
  static List<_SubTask> update = [downloadDb, unpackDb];
}

/// Singleton that manages the onboarding workflow.
class OnboardingTaskManager {
  OnboardingTask instance;

  OnboardingTaskManager._();

  Future<bool> mustRun() async {
    return !await ResourceHelper.checkDbExists() || !PrefService.getBool('icons_downloaded');
  }

  /// Start the onboarding flow. Attempting to start this more than once is unexpected.
  Future<void> start() {
    if (instance != null) {
      Fimber.w('Already started onboarding');
      return null;
    }
    instance = OnboardingTask();
    return instance.start();
  }
}

/// Executes the onboarding workflow, publishing updates as it goes.
class OnboardingTask with TaskPublisher {
  Future<void> start() async {
    // Keep trying to download and update the database until it exists (accounts for failures).
    while (!await ResourceHelper.checkDbExists()) {
      try {
        await _downloadDb();
        Prefs.updateRan();
      } catch (e) {
        Fimber.w('Downloading DB failed', ex: e);
        await Future.delayed(Duration(seconds: 5));
      }
    }

    // Keep trying to download and unpack the icons until it succeeds (accounts for failures).
    while (!PrefService.getBool('icons_downloaded')) {
      try {
        await _downloadIcons();
        PrefService.setBool('icons_downloaded', true);
      } catch (e) {
        Fimber.w('Downloading icons failed', ex: e);
        await Future.delayed(Duration(seconds: 5));
      }
    }

    // Now that the database has downloaded successfully, redo initialization.
    await DatabaseHelper.instance.reloadDb();
    await tryInitializeServiceLocatorDb(true);

    finishStream();
  }

  Future<void> _downloadDb() async {
    File tmpFile = await _downloadFileWithProgress(
        _SubTask.downloadDb, ResourceHelper.remoteDbFile(), 'db.zip');

    pub(_SubTask.unpackDb, TaskStatus.idle);
    try {
      final archive = new ZipDecoder().decodeBytes(tmpFile.readAsBytesSync());
      var archiveDbFile = archive.firstWhere((e) => e.name == ResourceHelper.dbFileName);
      var dbFile = File(await ResourceHelper.dbFilePath());
      pub(_SubTask.unpackDb, TaskStatus.started);
      await compute(_decompressLargeFile, _UnzipArgs(archiveDbFile, dbFile));
      pub(_SubTask.unpackDb, TaskStatus.finished);
      tmpFile.delete();
    } catch (e) {
      pub(_SubTask.unpackDb, TaskStatus.failed, message: 'Unexpected error: ${e.toString()}');
      throw e;
    }
  }

  Future<void> _downloadIcons() async {
    File tmpFile = await _downloadFileWithProgress(
        _SubTask.downloadImages, ResourceHelper.remoteIconsFile(), 'icons.zip');

    pub(_SubTask.unpackImages, TaskStatus.idle);
    try {
      final cacheManager = getIt<PermanentCacheManager>();
      final archive = new ZipDecoder().decodeBytes(tmpFile.readAsBytesSync());
      await cacheManager.storeImageArchive(archive,
          (progress) => pub(_SubTask.unpackImages, TaskStatus.started, progress: progress));
      pub(_SubTask.unpackImages, TaskStatus.finished);
      tmpFile.delete();
    } catch (e) {
      pub(_SubTask.unpackImages, TaskStatus.failed, message: 'Unexpected error: ${e.toString()}');
      throw e;
    }
  }

  Future<File> _downloadFileWithProgress(
      _SubTask task, String remoteZipFile, String tmpFileName) async {
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

  void pub(_SubTask curTask, TaskStatus status, {int progress, String message}) {
    publish(TaskProgress(curTask.text, curTask.id, taskCount(), status,
        progress: progress, message: message));
  }

  int taskCount() {
    return PrefService.getBool('icons_downloaded') ? _SubTask.update.length : _SubTask.all.length;
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
