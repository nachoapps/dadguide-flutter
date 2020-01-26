import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dadguide2/components/config/app_state.dart';
import 'package:dadguide2/components/config/service_locator.dart';
import 'package:dadguide2/components/config/settings_manager.dart';
import 'package:dadguide2/components/images/cache.dart';
import 'package:dadguide2/components/ui/task_progress.dart';
import 'package:dadguide2/data/database.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:dadguide2/services/endpoints.dart';
import 'package:dio/dio.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:preferences/preferences.dart';

// TODO: convert to being supplied by getIt
var onboardingManager = OnboardingTaskManager._();

/// The different stages that the onboarding runs through.
class _SubTask {
  final int id;
  final String Function() _text;

  const _SubTask._(this.id, this._text);

  // Adding default text if localized is null. Strangely enough this can happen during the
  // onboarding process, which might kick off before the widget tree has finished rendering.
  static _SubTask downloadDb =
      _SubTask._(1, () => localized?.onboardingDownloadDb ?? 'Downloading initial data');
  static _SubTask unpackDb =
      _SubTask._(2, () => localized?.onboardingUnpackDb ?? 'Unpacking initial data');
  static _SubTask downloadImages =
      _SubTask._(3, () => localized?.onboardingDownloadImages ?? 'Downloading icon set');
  static _SubTask unpackImages =
      _SubTask._(4, () => localized?.onboardingUnpackImages ?? 'Unpacking icon set');

  String get text => _text();

  static List<_SubTask> all = [downloadDb, unpackDb, downloadImages, unpackImages];
  static List<_SubTask> update = [downloadDb, unpackDb];
}

/// Singleton that manages the onboarding workflow.
class OnboardingTaskManager {
  /// Server-side database version name. Should be updated whenever the structure of the DB changes.
  static String remoteDbFile() {
    return getIt<Endpoints>().db('v2_dadguide.sqlite.zip');
  }

  /// Server-side icon/awakening/latent zip file name. Probably never changes.
  static String remoteIconsFile() {
    return getIt<Endpoints>().db('icons.zip');
  }

  OnboardingTask instance;

  OnboardingTaskManager._();

  Future<bool> onboardingMustRun() async {
    return await DatabaseHelper.instance.database == null || !Prefs.iconsDownloaded;
  }

  Future<bool> upgradingMustRun() async {
    return await DatabaseHelper.instance.database == null && Prefs.iconsDownloaded;
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
    while (await DatabaseHelper.instance.database == null) {
      try {
        await _downloadDb();
        Prefs.updateRan();
      } catch (e) {
        Fimber.w('Downloading DB failed', ex: e);
        await Future.delayed(Duration(seconds: 5));
      }
    }

    // Keep trying to download and unpack the icons until it succeeds (accounts for failures).
    while (!Prefs.iconsDownloaded) {
      try {
        await _downloadIcons();
        Prefs.setIconsDownloaded(true);
      } catch (e) {
        Fimber.w('Downloading icons failed', ex: e);
        await Future.delayed(Duration(seconds: 5));
      }
    }

    // Now that the database has downloaded successfully, redo initialization.
    await tryInitializeServiceLocatorDb();
    appStatusSubject.add(AppStatus.ready);

    finishStream();
  }

  Future<void> _downloadDb() async {
    File tmpFile = await _downloadFileWithProgress(
        _SubTask.downloadDb, OnboardingTaskManager.remoteDbFile(), 'db.zip');

    pub(_SubTask.unpackDb, TaskStatus.idle);
    try {
      final archive = new ZipDecoder().decodeBytes(tmpFile.readAsBytesSync());
      var archiveDbFile = archive.firstWhere((e) => e.name == DatabaseHelper.dbName);
      var dbFile = File(await DatabaseHelper.dbFilePath());
      pub(_SubTask.unpackDb, TaskStatus.started);
      await compute(_decompressLargeFile, _UnzipArgs(archiveDbFile, dbFile));
      pub(_SubTask.unpackDb, TaskStatus.finished);
      await tmpFile.delete();
    } catch (e) {
      pub(_SubTask.unpackDb, TaskStatus.failed, message: 'Unexpected error: ${e.toString()}');
      throw e;
    }
  }

  Future<void> _downloadIcons() async {
    File tmpFile = await _downloadFileWithProgress(
        _SubTask.downloadImages, OnboardingTaskManager.remoteIconsFile(), 'icons.zip');

    pub(_SubTask.unpackImages, TaskStatus.idle);
    try {
      final cacheManager = getIt<PermanentCacheManager>();
      final archive = new ZipDecoder().decodeBytes(tmpFile.readAsBytesSync());
      await cacheManager.storeImageArchive(archive,
          (progress) => pub(_SubTask.unpackImages, TaskStatus.started, progress: progress));
      pub(_SubTask.unpackImages, TaskStatus.finished);
      await tmpFile.delete();
    } catch (e) {
      pub(_SubTask.unpackImages, TaskStatus.failed, message: 'Unexpected error: ${e.toString()}');
      throw e;
    }
  }

  Future<File> _downloadFileWithProgress(
      _SubTask task, String remoteZipFile, String tmpFileName) async {
    pub(task, TaskStatus.idle, progress: 0);
    try {
      File tmpFile = await _newTmpFile(tmpFileName);
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

Future<File> _newTmpFile(String name) async {
  var tmpDir = await getTemporaryDirectory();
  var tmpFile = File(join(tmpDir.path, name));
  if (await tmpFile.exists()) {
    await tmpFile.delete();
  }
  return tmpFile;
}
