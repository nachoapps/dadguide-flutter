import 'dart:async';

import 'package:dadguide2/components/service_locator.dart';
import 'package:dadguide2/components/settings_manager.dart';
import 'package:dadguide2/data/data_objects.dart';
import 'package:dadguide2/data/tables.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_fimber/flutter_fimber.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:moor_flutter/moor_flutter.dart';

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
            Fimber.d("Notification pressed: $payload");
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

  ReceivedNotification({@required this.id, @required this.title, @required this.body, @required this.payload});
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

  /// checks if the event is being tracked by a user
  Future<bool> checkEvent(ScheduleEvent event) async {
    int dungeonId = event.dungeonId;
    return Prefs.trackedDungeons.contains(dungeonId);
  }

  /// schedules the actual notification in the OS
  Future<void> _createScheduledNotification(int uniqueId, String title, String body,
      DateTime scheduledTime, NotificationDetails notificationDetails,
      {payload}) async {
    List<int> pendingNotificationRequestIds =
    (await notifications.flutterLocalNotificationsPlugin.pendingNotificationRequests())
        .map((x) => x.id).toList();

    if (!pendingNotificationRequestIds.contains(uniqueId)) {
      Fimber.d("Scheduling a notification #$uniqueId at ${DateFormat.yMd().add_jm().format(
          scheduledTime.toLocal())}");
      await notifications.flutterLocalNotificationsPlugin.schedule(
          uniqueId, title, body, scheduledTime, notificationDetails,
          payload: payload, androidAllowWhileIdle: true);
    } else {
      Fimber.d("Notification #$uniqueId already exists, skipping.");
    }
  }

  /// gets a datetime from a timestamp in seconds
  static DateTime _eventDateTime(int secondsFromEpoch) =>
      DateTime.fromMillisecondsSinceEpoch(secondsFromEpoch * 1000, isUtc: true);

  static String _formatTime(DateTime dateTime) =>
      DateFormat.MMMd().add_jm().format(dateTime.toLocal());

  /// takes the event and schedules a notification to appear at the event start time.
  Future<void> scheduleEventNotification(ScheduleEvent event) async {
    DungeonsDao _dungeonsDao = getIt<DungeonsDao>();
    FullDungeon fullDungeon = await _dungeonsDao.lookupFullDungeon(event.dungeonId);
    String datetimeDisplay = _formatTime(_eventDateTime(event.endTimestamp));
    Fimber.i("Scheduling ${event.groupName} - ${fullDungeon.name.call()} at ${_formatTime(
        _eventDateTime(event.startTimestamp))}");
    var androidDetails = AndroidNotificationDetails('Dungeons', 'Subscribed dungeon notification',
        'Notify user that their dungeon is now available',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    // TODO: Implement iOSDetails
    var iOSDetails = IOSNotificationDetails();
    var notificationDetails = NotificationDetails(androidDetails, iOSDetails);

    // each event and timestamp make it's unique notification id. This is because some events have
    // the same dungeonId but have separate start times, so we can't simply use the dungeonId.
    int uniqueId = event.dungeonId + event.startTimestamp;
    String groupName = event.groupName != null ? "[${event.groupName}] " : "";
    String title = '$groupName${fullDungeon.name.call()} active';
    String body = 'Available until $datetimeDisplay';
    DateTime startTime = _eventDateTime(event.startTimestamp);

    _createScheduledNotification(uniqueId, title, body, startTime, notificationDetails);
  }

  Future<void> logScheduledNotifications() async {
    List<PendingNotificationRequest> pendingNotificationRequests =
    await notifications.flutterLocalNotificationsPlugin.pendingNotificationRequests();
    pendingNotificationRequests.forEach((pendingNotification) =>
        Fimber.d(
            "Notification #${pendingNotification.id} is pending. Title: '${pendingNotification
                .title}', Body: '${pendingNotification.body}'"));
  }
}
