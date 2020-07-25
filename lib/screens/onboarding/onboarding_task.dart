import 'dart:io';

import 'package:dadguide2/components/config/app_state.dart';
import 'package:dadguide2/components/config/service_locator.dart';
import 'package:dadguide2/components/config/settings_manager.dart';
import 'package:dadguide2/components/db/dadguide_database.dart';
import 'package:dadguide2/components/firebase/analytics.dart';
import 'package:dadguide2/components/images/cache.dart';
import 'package:dadguide2/components/ui/task_progress.dart';
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

  static String remoteUnzippedDbFile() {
    return getIt<Endpoints>().db('dadguide.sqlite');
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
    Prefs.onboardingFailureCount = 0;
    task = OnboardingTask();
    return task.start();
  }
}

/// Executes the onboarding workflow, publishing updates as it goes.
class OnboardingTask with TaskPublisher {
  Future<void> start() async {
    // If we're here, we're either in an initial run, or we already determined
    // that an update is necessary and the DB has been cleared.
    Prefs.currentDbVersion = DatabaseHelper.dbVersion;
    Prefs.updateRan();
    Prefs.onboardingFailureCount = 0;

    // Try the download zip and then unzip workflow.
    if (await DatabaseHelper.instance.database == null) {
      try {
        await _downloadDb();
      } catch (ex) {
        Prefs.incrementOnboardingFailureCount();
        Fimber.w('Downloading zipped DB failed', ex: ex);
        recordEvent('onboarding_failure_db_zipped');
        pub(_SubTask.unpackDb, TaskStatus.failed, message: 'ZIP file unpacking failed');
      }
    }

    // Try the unzipped download workflow.
    if (await DatabaseHelper.instance.database == null) {
      await Future<void>.delayed(Duration(seconds: 1));
      Prefs.incrementOnboardingFailureCount();
      recordEvent('onboarding_failure_db_zipped_bad');
      try {
        await _downloadUnpackedDb();
      } catch (ex) {
        Prefs.incrementOnboardingFailureCount();
        Fimber.w('Downloading unzipped DB failed', ex: ex);
        recordEvent('onboarding_failure_db_unzipped');
        pub(_SubTask.downloadDb, TaskStatus.failed, message: 'DB File download failed');
        await Future<void>.delayed(Duration(seconds: 1));
      }
    }

    // The database should be available by now, if not, we've failed onboarding.
    if (await DatabaseHelper.instance.database == null) {
      Prefs.incrementOnboardingFailureCount();
      Fimber.e('Since database was still null, onboarding permanently failed');
      await Future<void>.delayed(Duration(seconds: 1));
      pub(_SubTask.unpackDb, TaskStatus.permanently_failed,
          message: 'Database initialization failed');
      return;
    }

    try {
      await tryInitializeServiceLocatorDb();
    } catch (ex) {
      Fimber.e('Could not register DB to service locator', ex: ex);
      recordEvent('onboarding_failure_registration');
      pub(_SubTask.unpackDb, TaskStatus.permanently_failed,
          message: 'Database registration failed');
      Prefs.incrementOnboardingFailureCount();
      return;
    }

    // If we got here, we skipped whatever failures occurred earlier.
    Prefs.onboardingFailureCount = 0;

    // Keep trying to download and unpack the icons until it succeeds (accounts for failures).
    while (!Prefs.iconsDownloaded) {
      try {
        await _downloadIcons();
        Prefs.setIconsDownloaded(true);
      } catch (ex) {
        Prefs.incrementOnboardingFailureCount();
        Fimber.w('Downloading icons failed', ex: ex);
        recordEvent('onboarding_failure_icons');

        // If we can't download the icons that's fine. It will just be slower for the user.
        if (Prefs.onboardingFailureCount >= 3) {
          Fimber.e('Abandoning icon download');
          break;
        }

        // If we still have retries, pause for a bit before continuing.
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
  }

  Future<void> _downloadUnpackedDb() async {
    await _downloadFileWithProgress(_SubTask.downloadDb,
        OnboardingTaskManager.remoteUnzippedDbFile(), await DatabaseHelper.dbFilePath());
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
      _SubTask task, String remoteZipFile, String fileName) async {
    final tmpDir = await _newTmpDir(fileName);
    final tmpFile = File(join(tmpDir.path, '$fileName.zip'));
    await _downloadFileWithProgress(task, remoteZipFile, tmpFile.path);
    return tmpFile;
  }

  Future<void> _downloadFileWithProgress(_SubTask task, String remoteFile, String localFile) async {
    pub(task, TaskStatus.idle, progress: 0);
    try {
      Fimber.i('Starting download of $remoteFile to $localFile');
      var resp = await getIt<Dio>().download(
        remoteFile,
        localFile,
        onReceiveProgress: (received, total) {
          pub(task, TaskStatus.started, progress: received * 100 ~/ total);
        },
      );
      Fimber.i(
          'Finished downloading file ${localFile}: ${resp.statusCode} : ${resp.statusMessage}');
      pub(task, TaskStatus.finished);
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
  await ZipFile.extractToDirectory(zipFile: zipFile, destinationDir: destinationDir);
  final fileCount = await destinationDir.list().length;
  Fimber.i('Done unpacking $fileCount files to ${destinationDir.path}');
}

Future<Directory> _newTmpDir(String dirType) async {
  return Directory.systemTemp.createTemp(dirType);
}
