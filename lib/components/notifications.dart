import 'package:dadguide2/components/settings_manager.dart';
import 'package:dadguide2/data/data_objects.dart';
import 'package:dadguide2/data/tables.dart';
import 'package:flutter_fimber/flutter_fimber.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dadguide2/screens/dungeon_info/dungeon_info_subtab.dart';
import 'package:dadguide2/components/service_locator.dart';
import 'dart:async';
import 'package:dadguide2/components/service_locator.dart';
import 'package:intl/intl.dart';

class NotificationInit {
  /// Create streams for these callbacks so the app can listen for notification events.
  /// TODO: convert the selectNotification type to a Map to have notification specific payloads.
  final _didReceiveLocalNotificationController = StreamController<ReceivedNotification>();
  final _selectNotificationController = StreamController<String>();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  NotificationInit() : flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin() {
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');

    // iOS specific stuff.
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: (int id, String title, String body, String payload) async {
      _didReceiveLocalNotificationSink
          .add(ReceivedNotification(id: id, title: title, body: body, payload: payload));
    });
    var initializationSettings =
        InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (payload) async {
      if (payload != null) {
        Fimber.i("Notification pressed: $payload");
      }
      _selectNotificationSink.add(payload);
    });
  }

  StreamSink<ReceivedNotification> get _didReceiveLocalNotificationSink =>
      _didReceiveLocalNotificationController.sink;

  Stream<ReceivedNotification> get receivedNotifications =>
      _didReceiveLocalNotificationController.stream;

  /// For now the sink just stores a simple payload string.
  /// TODO: Create screen-specific payloads to navigate to depending on the notification tapped.
  StreamSink<String> get _selectNotificationSink => _selectNotificationController.sink;

  Stream<String> get selectNotification => _selectNotificationController.stream;

  void dispose() {
    _didReceiveLocalNotificationController.close();
    _selectNotificationController.close();
  }
}

class ReceivedNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  ReceivedNotification(
      {@required this.id, @required this.title, @required this.body, @required this.payload});
}

class Notifications {
  final notifications = getIt<NotificationInit>();

  // TODO: implement this code block, which is the callback for when a user clicks on a notification
//  void initState() {
//    _notificationsBloc._didReceiveLocalNotificationController.stream
//        .listen((ReceivedNotification receivedNotification) async {
//      await showDialog(
//        context: context,
//        builder: (BuildContext context) => CupertinoAlertDialog(
//          title: receivedNotification.title != null
//              ? Text(receivedNotification.title)
//              : null,
//          content: receivedNotification.body != null
//              ? Text(receivedNotification.body)
//              : null,
//          actions: [
//            CupertinoDialogAction(
//              isDefaultAction: true,
//              child: Text('Ok'),
//              onPressed: () async {
//                Navigator.of(context, rootNavigator: true).pop();
//                await Navigator.push(
//                  context,
//                  MaterialPageRoute(
//                    builder: (context) =>
//                        SecondScreen(receivedNotification.payload),
//                  ),
//                );
//              },
//            )
//          ],
//        ),
//      );
//    });
//    _notificationsBloc._selectNotificationController.stream.listen((String payload) async {
//      await Navigator.push(
//        context,
//        MaterialPageRoute(builder: (context) =>DungeonDetailScreen(payload)),
//      );
//    });
//  }

  Future<void> showEventNotification(ScheduleEvent event) async {
    DungeonsDao _dungeonsDao = getIt<DungeonsDao>();
    FullDungeon fullDungeon = await _dungeonsDao.lookupFullDungeon(event.dungeonId);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails('Dungeons',
        'Subscribed dungeon notification', 'Notify user that their dungeon is now available',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');

    /// TODO: implement the iOS stuff
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics =
        NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await notifications.flutterLocalNotificationsPlugin.show(
        event.dungeonId, // notifications need to have a unique ID
        'Dungeon ${fullDungeon.name.call()} available!',
        'Available until ${DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch(event.endTimestamp * 1000, isUtc: true).toLocal())}',
        platformChannelSpecifics,
        payload: null);
  }

  Future<void> checkEvent(ScheduleEvent event) async {
    int dungeonId = event.dungeonId;
    if (Prefs.trackedDungeons.contains(dungeonId)) {
      Notifications notifications = Notifications();
      notifications.showEventNotification(event);
    }
  }
}
