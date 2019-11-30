import 'package:background_fetch/background_fetch.dart';
import 'package:dadguide2/components/enums.dart';
import 'package:dadguide2/components/notifications.dart';
import 'package:dadguide2/components/service_locator.dart';
import 'package:dadguide2/components/settings_manager.dart';
import 'package:dadguide2/data/tables.dart';
import 'package:dadguide2/services/update_service.dart';
import 'package:flutter_fimber/flutter_fimber.dart';

class BackgroundFetchInit {
  BackgroundFetchInit() {
    init();
  }

  Future<void> init() async {
    BackgroundFetch.configure(
        BackgroundFetchConfig(
            // Will run in the background every 15 minutes. Consider making this a preference.
            minimumFetchInterval: 15,
            stopOnTerminate: false,
            forceReload: true,
            enableHeadless: false,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresStorageNotLow: false,
            requiresDeviceIdle: false,
            requiredNetworkType: BackgroundFetchConfig.NETWORK_TYPE_NONE), () async {
      var notifications = Notifications();
      var _scheduleDao = getIt<ScheduleDao>();
      var _trackedDungeons = Prefs.trackedDungeons;

      // force an update
      await updateManager.start();

      Fimber.i("User's tracked dungeons: $_trackedDungeons");
      var events = await _scheduleDao.findListEvents(EventSearchArgs.from(
        [Prefs.eventCountry],
        Prefs.eventStarters,
        ScheduleTabKey.all,
        DateTime.now(),
        DateTime.now().add(Duration(days: 2)),
        Prefs.eventHideClosed,
      ));
      Fimber.d("Event ids found: ${events.map((event) => event.dungeon.dungeonId).join(", ")}");
      events.forEach((event) => notifications.checkEvent(event.event));
      BackgroundFetch.finish();
    }).then((result) {
      Fimber.i("BackgroundFetch config done");
    }).catchError((e, stacktrace) => Fimber.i("Error", ex: e, stacktrace: stacktrace));
  }
}
