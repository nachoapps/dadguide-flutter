import 'package:background_fetch/background_fetch.dart';
import 'package:dadguide2/services/update_service.dart';
import 'package:flutter_fimber/flutter_fimber.dart';

/// Configuration for background execution.
final _config = BackgroundFetchConfig(
  // Execute once per day.
  minimumFetchInterval: 60 * 24,
  // Only execute when on WiFi since we're downloading data.
  requiredNetworkType: BackgroundFetchConfig.NETWORK_TYPE_UNMETERED,
  // This forces the app to load if it was terminated by the user (it immediately minimizes). We
  // could work around this by enabling headless mode but that is much more complicated. To prevent
  // an annoying user experience, also require that the device is idle.
  forceReload: true,
  // As described above, only perform updates when the device is idle so users don't see the awkward
  // launch and minimize.
  requiresDeviceIdle: true,
  // It might be nice to support this in the future but it only works on Android and is a more
  // complicated setup.
  enableHeadless: false,
  // We want to run even if (especially if) the user is not using the device).
  stopOnTerminate: false,
  // We don't use much resources so ignore these requirements.
  requiresBatteryNotLow: false,
  requiresCharging: false,
  requiresStorageNotLow: false,
);

/// Configures the task that runs once a day to update the database.
Future<void> configureUpdateDatabaseTask() async {
  Fimber.i('Configuring background fetch');
  try {
    var result = await BackgroundFetch.configure(_config, triggerUpdate);
    Fimber.i('Configuring background fetch completed with status $result');
  } catch (ex, st) {
    Fimber.e('Configuing background fetch failed', ex: ex, stacktrace: st);
  }
}

Future<void> triggerUpdate() async {
  Fimber.i('Background fetch triggered');
  try {
    await updateManager.start();
    BackgroundFetch.finish(BackgroundFetch.FETCH_RESULT_NEW_DATA);
  } catch (ex, st) {
    Fimber.e('Update task failed', ex: ex, stacktrace: st);
    BackgroundFetch.finish(BackgroundFetch.FETCH_RESULT_FAILED);
  }
}
