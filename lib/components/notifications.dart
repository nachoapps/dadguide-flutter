import 'dart:async';
import 'dart:convert';

import 'package:dadguide2/components/enums.dart';
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

  ReceivedNotification(
      {@required this.id, @required this.title, @required this.body, @required this.payload});
}

class Notifications {
  final _notificationPlugin = getIt<NotificationInit>();
  final Map<int, FullDungeon> _dungeons = {};
  final List<ScheduleEvent> _events = [];
  final eventArgs = EventSearchArgs.from(
    [Prefs.eventCountry],
    Prefs.eventStarters,
    ScheduleTabKey.all,
    DateTime.now(),
    DateTime.now().add(Duration(days: 2)),
    Prefs.eventHideClosed,
  );

  /// takes the schedule and creates the notifications for each tracked event in the schedule.
  Future<void> checkEvents(List<ListEvent> events) async {
    events.forEach((listEvent) {
      if (Prefs.trackedDungeons.contains(listEvent.dungeon.dungeonId) &&
          Prefs.checkCountryNotifyStatusById(listEvent.event.serverId)) {
        _events.add(listEvent.event);
      }
    });
    await _retrieveFullDungeons();
    await _scheduleEventNotifications();
    await _logScheduledNotifications();
  }

  /// retrieves FullDungeons for each event from the _events list, to avoid repeatedly querying db.
  Future<void> _retrieveFullDungeons() async {
    final Set<int> _dungeonIds = {};
    _events.forEach((event) => _dungeonIds.add(event.dungeonId));
    DungeonsDao _dungeonsDao = getIt<DungeonsDao>();
    await Future.forEach(
        _dungeonIds, (id) async => _dungeons[id] = await _dungeonsDao.lookupFullDungeon(id));
  }

  /// schedules the actual notification in the OS
  Future<void> _createScheduledNotification(int uniqueId, String title, String body,
      DateTime scheduledTime, NotificationDetails notificationDetails,
      {payload}) async {
    List<int> pendingNotificationRequestIds =
        (await _notificationPlugin.flutterLocalNotificationsPlugin.pendingNotificationRequests())
            .map((x) => x.id)
            .toList();

    if (!pendingNotificationRequestIds.contains(uniqueId)) {
      Fimber.d(
          "New notification scheduled: ID: $uniqueId, Title: '$title', scheduledTime: '${_formatTime(scheduledTime)}', Body: '$body'");
      await _notificationPlugin.flutterLocalNotificationsPlugin.schedule(
          uniqueId, title, body, scheduledTime, notificationDetails,
          payload: payload, androidAllowWhileIdle: true);
    } else {
      Fimber.d("Notification #$uniqueId already exists, skipping.");
    }
  }

  static DateTime _eventDateTime(int secondsFromEpoch) =>
      DateTime.fromMillisecondsSinceEpoch(secondsFromEpoch * 1000, isUtc: true);

  static String _formatTime(DateTime dateTime) =>
      DateFormat.MMMd().add_jm().format(dateTime.toLocal());

  /// schedules all of the notifications in the _events list
  Future<void> _scheduleEventNotifications() async {
    var androidDetails = AndroidNotificationDetails('Dungeons', 'Subscribed dungeon notification',
        'Notify user that their dungeon is now available',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    // TODO: Implement iOSDetails
    var iOSDetails = IOSNotificationDetails();
    var notificationDetails = NotificationDetails(androidDetails, iOSDetails);

    for (var event in _events) {
      String datetimeDisplay = _formatTime(_eventDateTime(event.endTimestamp));

      List<String> titleComponents = [];
      titleComponents.add("[${Country.byId(event.serverId).countryCode}]");
      if (event.groupName != null) titleComponents.add("[${event.groupName}]");
      titleComponents.add('${_dungeons[event.dungeonId].name.call().trim()} active');
      String title = titleComponents.join(" ");
      String body = 'Available until $datetimeDisplay';
      DateTime startTime = _eventDateTime(event.startTimestamp);
      String payload = JsonEncoder().convert(event);
      _createScheduledNotification(event.eventId, title, body, startTime, notificationDetails,
          payload: payload);
    }
  }

  Future<List<PendingNotificationRequest>> get _pendingNotifications async =>
      await _notificationPlugin.flutterLocalNotificationsPlugin.pendingNotificationRequests();

  Future<void> _cancelPendingNotification(int eventId) async {
    await _notificationPlugin.flutterLocalNotificationsPlugin.cancel(eventId);
  }

  Future<void> cancelPendingNotificationsByDungeonId(int dungeonId) async {
    var pendingNotifications = await _pendingNotifications;
    var payloads = pendingNotifications
        .map((pendingNotification) => JsonDecoder().convert(pendingNotification.payload))
        .toList();
    Fimber.d("Old pending notifications: ${pendingNotifications.map((x) => x.id).toList()}");
    payloads.forEach((payload) async {
      if (payload['dungeonId'] == dungeonId) {
        await _cancelPendingNotification(payload['eventId']);
      }
    });
    Fimber.d("New pending notifications: ${pendingNotifications.map((x) => x.id).toList()}");
  }

  Future<void> _logScheduledNotifications() async {
    List<PendingNotificationRequest> pendingNotificationRequests =
        await _notificationPlugin.flutterLocalNotificationsPlugin.pendingNotificationRequests();
    pendingNotificationRequests.forEach((pendingNotification) => Fimber.d(
        "Notification #${pendingNotification.id} is pending. Title: '${pendingNotification.title}', Body: '${pendingNotification.body}'"));
  }
}
