import 'package:background_fetch/background_fetch.dart';
import 'package:dadguide2/components/firebase/analytics.dart';
import 'package:dadguide2/components/updates/update_service.dart';
import 'package:flutter_fimber/flutter_fimber.dart';

/// Configuration for background execution.
final _config = BackgroundFetchConfig(
  // Execute once per day.
  minimumFetchInterval: 60 * 24,
  // We want to run even if (especially if) the user is not using the device.
  stopOnTerminate: false,
  // We want to recieve events even if rebooted.
  startOnBoot: true,
  // Support headless mode on Android.
  enableHeadless: true,
  // We don't need higher precision.
  forceAlarmManager: false,
  // Only execute when on WiFi since we're downloading data.
  requiredNetworkType: NetworkType.UNMETERED,
  // We don't use much resources so ignore these requirements.
  requiresBatteryNotLow: false,
  // We don't use much resources so ignore these requirements.
  requiresCharging: false,
  // We don't use much resources so ignore these requirements.
  requiresStorageNotLow: false,
  // Only perform updates when the device is idle so users don't see the awkward
  // launch and minimize.
  requiresDeviceIdle: true,
);

/// Configures the task that runs once a day to update the database.
Future<void> configureUpdateDatabaseTask() async {
  Fimber.i('Background fetch is disabled until I can figure it out =(');

//  Fimber.i('Configuring background fetch');
//  try {
//    var result = await BackgroundFetch.configure(_config, triggerUpdate);
//    Fimber.i('Configuring background fetch completed with status $result');
//    await BackgroundFetch.registerHeadlessTask(triggerUpdate);
//  } catch (ex, st) {
//    Fimber.e('Configuing background fetch failed', ex: ex, stacktrace: st);
//  }
}

Future<void> triggerUpdate(String taskId) async {
  recordEvent('background_fetch_triggered');
  Fimber.i('Background fetch triggered: $taskId');
  try {
    await updateManager.start();
  } catch (ex, st) {
    Fimber.e('Update task failed: $taskId', ex: ex, stacktrace: st);
  } finally {
    BackgroundFetch.finish(taskId);
  }
}
