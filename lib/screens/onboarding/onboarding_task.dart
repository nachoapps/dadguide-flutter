import 'dart:io';

import 'package:dadguide2/components/config/app_state.dart';
import 'package:dadguide2/components/config/service_locator.dart';
import 'package:dadguide2/components/config/settings_manager.dart';
import 'package:dadguide2/components/firebase/analytics.dart';
import 'package:dadguide2/components/images/cache.dart';
import 'package:dadguide2/components/ui/task_progress.dart';
import 'package:dadguide2/data/database.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:dadguide2/services/endpoints.dart';
import 'package:dio/dio.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:path/path.dart';
import 'package:preferences/preferences.dart';

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
  OnboardingTaskManager._internal() {
    Fimber.i('Created OnboardingTaskManager');
  }

  static OnboardingTaskManager _instance;
  static OnboardingTaskManager get instance {
    _instance ??= OnboardingTaskManager._internal();
    return _instance;
  }

  /// Server-side database version name. Should be updated whenever the structure of the DB changes.
  static String remoteDbFile() {
    return getIt<Endpoints>().db('v2_dadguide.sqlite.zip');
  }

  /// Server-side icon/awakening/latent zip file name. Probably never changes.
  static String remoteIconsFile() {
    return getIt<Endpoints>().db('icons.zip');
  }

  OnboardingTask task;

  Future<bool> onboardingMustRun() async {
    return await DatabaseHelper.instance.database == null || !Prefs.iconsDownloaded;
  }

  Future<bool> upgradingMustRun() async {
    return await DatabaseHelper.instance.database == null && Prefs.iconsDownloaded;
  }

  /// Start the onboarding flow. Attempting to start this more than once is unexpected.
  Future<void> start() {
    if (task != null) {
      Fimber.w('Already started onboarding');
      return null;
    }
    task = OnboardingTask();
    return task.start();
  }
}

/// Executes the onboarding workflow, publishing updates as it goes.
class OnboardingTask with TaskPublisher {
  Future<void> start() async {
    // Keep trying to download and update the database until it exists (accounts for failures).
    while (await DatabaseHelper.instance.database == null) {
      try {
        await _downloadDb();
        Prefs.currentDbVersion = DatabaseHelper.dbVersion;
        Prefs.updateRan();

        // Now that the database has downloaded successfully, redo initialization.
        await tryInitializeServiceLocatorDb();
      } catch (e) {
        Fimber.w('Downloading DB failed', ex: e);
        recordEvent('onboarding_failure_db');
        await Future<void>.delayed(Duration(seconds: 5));
      }
    }

    // Keep trying to download and unpack the icons until it succeeds (accounts for failures).
    while (!Prefs.iconsDownloaded) {
      try {
        await _downloadIcons();
        Prefs.setIconsDownloaded(true);
      } catch (e) {
        Fimber.w('Downloading icons failed', ex: e);
        recordEvent('onboarding_failure_icons');
        await Future<void>.delayed(Duration(seconds: 5));
      }
    }

    appStatusSubject.add(AppStatus.ready);
    finishStream();
  }

  Future<void> _downloadDb() async {
    final tmpFile = await _downloadZipFileWithProgress(
        _SubTask.downloadDb, OnboardingTaskManager.remoteDbFile(), 'db.download');

    pub(_SubTask.unpackDb, TaskStatus.idle);
    try {
      pub(_SubTask.unpackDb, TaskStatus.started);
      final unpackDir = await _newTmpDir('db.unpack');
      await _nativeUnzipLargeFile(tmpFile, unpackDir);

      final unzippedDbFile = File(join(unpackDir.path, DatabaseHelper.dbName));
      if (!unzippedDbFile.existsSync()) {
        throw 'File does not exist: ${unzippedDbFile.path}';
      }

      final targetFile = await DatabaseHelper.dbFilePath();
      Fimber.i('Moving ${unzippedDbFile.path} to $targetFile}');
      await unzippedDbFile.rename(targetFile);
      Fimber.i('Done moving to $targetFile');

      pub(_SubTask.unpackDb, TaskStatus.finished);

      try {
        await tmpFile.delete();
        await unpackDir.delete(recursive: true);
      } catch (ex) {
        Fimber.w('Failed to delete tmp db files', ex: ex);
      }
    } catch (e) {
      recordEvent('onboarding_failure_db_unpack');
      pub(_SubTask.unpackDb, TaskStatus.failed, message: 'Unexpected error: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> _downloadIcons() async {
    final tmpFile = await _downloadZipFileWithProgress(
        _SubTask.downloadImages, OnboardingTaskManager.remoteIconsFile(), 'icons');

    pub(_SubTask.unpackImages, TaskStatus.idle);
    try {
      final unpackDir = await _newTmpDir('icons.unpack');
      await _nativeUnzipLargeFile(tmpFile, unpackDir);

      final cacheManager = getIt<PermanentCacheManager>();
      await cacheManager.storeImageDir(unpackDir,
          (int progress) => pub(_SubTask.unpackImages, TaskStatus.started, progress: progress));

      pub(_SubTask.unpackImages, TaskStatus.finished);

      try {
        await tmpFile.delete();
        await unpackDir.delete(recursive: true);
      } catch (ex) {
        Fimber.w('Failed to delete tmp icon files', ex: ex);
      }
    } catch (e) {
      recordEvent('onboarding_failure_icons_unpack');
      pub(_SubTask.unpackImages, TaskStatus.failed, message: 'Unexpected error: ${e.toString()}');
      rethrow;
    }
  }

  Future<File> _downloadZipFileWithProgress(
      _SubTask task, String remoteZipFile, String fileInfo) async {
    pub(task, TaskStatus.idle, progress: 0);
    try {
      final tmpDir = await _newTmpDir(fileInfo);
      final tmpFile = File(join(tmpDir.path, '$fileInfo.zip'));
      Fimber.i('Starting download of $remoteZipFile');
      var resp = await getIt<Dio>().download(
        remoteZipFile,
        tmpFile.path,
        onReceiveProgress: (received, total) {
          pub(task, TaskStatus.started, progress: received * 100 ~/ total);
        },
      );
      Fimber.i(
          'Finished downloading file ${tmpFile.path}: ${resp.statusCode} : ${resp.statusMessage}');
      pub(task, TaskStatus.finished);
      return tmpFile;
    } on DioError catch (e) {
      pub(task, TaskStatus.failed, message: e.message);
      rethrow;
    } catch (e) {
      pub(task, TaskStatus.failed, message: 'Unexpected error: ${e.toString()}');
      rethrow;
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

Future<void> _nativeUnzipLargeFile(File zipFile, Directory destinationDir) async {
  Fimber.i('Unpacking ${zipFile.path} to ${destinationDir.path}');
  await FlutterArchive.unzip(zipFile: zipFile, destinationDir: destinationDir);
  final fileCount = await destinationDir.list().length;
  Fimber.i('Done unpacking $fileCount files to ${destinationDir.path}');
}

Future<Directory> _newTmpDir(String dirType) async {
  return Directory.systemTemp.createTemp(dirType);
}
