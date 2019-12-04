import 'package:background_fetch/background_fetch.dart';
import 'package:dadguide2/components/notifications.dart';
import 'package:dadguide2/components/service_locator.dart';
import 'package:dadguide2/components/settings_manager.dart';
import 'package:dadguide2/data/data_objects.dart';
import 'package:dadguide2/data/tables.dart';
import 'package:dadguide2/services/update_service.dart';
import 'package:flutter_fimber/flutter_fimber.dart';

class BackgroundFetchInit {
  BackgroundFetchInit() {
    updateDatabaseTask();
  }

  /// updates the database and schedules tracked event notifications.
  Future<void> updateDatabaseTask() async {
    BackgroundFetch.configure(
        BackgroundFetchConfig(
            // minutes
            minimumFetchInterval: 1440,
            stopOnTerminate: false,
            forceReload: true,
            enableHeadless: false,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresStorageNotLow: false,
            requiresDeviceIdle: false,
            requiredNetworkType: BackgroundFetchConfig.NETWORK_TYPE_ANY), () async {
      var notifications = Notifications();
      var _scheduleDao = getIt<ScheduleDao>();
      var _trackedDungeons = Prefs.trackedDungeons;

      // force an update
      await updateManager.start();

      Fimber.i("User's tracked dungeons: $_trackedDungeons");
      List<ListEvent> events = await _scheduleDao.findListEvents(notifications.eventArgs);

      if (Prefs.inDevMode)
        Fimber.d(
            "Event ids found: ${events.map((listEvent) => listEvent.dungeon.dungeonId).join(", ")}");

      await notifications.checkEvents(events);

      BackgroundFetch.finish();
    }).then((result) {
      Fimber.i("BackgroundFetch config done");
    }).catchError((e, stacktrace) =>
        Fimber.i("BackgroundFetch configuration error", ex: e, stacktrace: stacktrace));
  }
}
