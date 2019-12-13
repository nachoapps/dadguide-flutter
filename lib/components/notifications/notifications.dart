import 'dart:async';
import 'dart:convert';

import 'package:dadguide2/components/enums.dart';
import 'package:dadguide2/components/service_locator.dart';
import 'package:dadguide2/components/settings_manager.dart';
import 'package:dadguide2/data/tables.dart';
import 'package:flutter_fimber/flutter_fimber.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

/// Ensures the Notification plugin is only initialized once.
class NotificationSingleton {
  static final _instance = NotificationSingleton._internal();

  factory NotificationSingleton() {
    return _instance;
  }

  NotificationSingleton._internal() {
    // Android specific stuff. app_icon needs to be a added as a drawable resource.
    var initSettingsAndroid = AndroidInitializationSettings('app_icon');

    // iOS specific stuff. Not supporting onDidReceiveLocalNotification (iOS <10)
    var initSettingsIOS = IOSInitializationSettings();

    FlutterLocalNotificationsPlugin().initialize(
      InitializationSettings(initSettingsAndroid, initSettingsIOS),
      onSelectNotification: _onNotificationTap,
    );
  }

  /// TODO: Support more specific notification types instead of just string payload.
  final _notificationController = StreamController<String>();
  Stream<String> get selectNotification => _notificationController.stream;

  Future<void> _onNotificationTap(String payload) async {
    Fimber.v("Notification pressed: $payload");
    _notificationController.sink.add(payload);
  }

  Future<void> dispose() => _notificationController.close();
}

class NotificationManager {
  final _plugin = FlutterLocalNotificationsPlugin();

  final _defaultDetails = NotificationDetails(
    AndroidNotificationDetails(
      'Dungeons',
      'Subscribed dungeon notification',
      'Notify user that their dungeon is now available',
      importance: Importance.Max,
      priority: Priority.High,
    ),
    IOSNotificationDetails(presentAlert: true),
  );

  /// Takes the schedule and ensures notifications exist for each tracked dungeon.
  Future<void> ensureEventsScheduled() async {
    var events = await getIt<ScheduleDao>().findListEvents(_upcomingEventArgs());

    var eventsToSchedule = events.where((le) =>
        Prefs.trackedDungeons.contains(le.dungeon.dungeonId) &&
        Prefs.checkCountryNotifyStatusById(le.event.serverId));

    for (var listEvent in eventsToSchedule) {
      var event = listEvent.event;
      var dungeonName = listEvent.dungeonName.call().trim();
      var country = Country.byId(event.serverId);
      String endTimeText = _formatTime(_eventDateTime(event.endTimestamp));

      List<String> titleComponents = [
        "[${country.countryCode}]",
        if (event.groupName != null) "[${event.groupName}]",
        '$dungeonName active',
      ];

      String title = titleComponents.join(" ");
      String body = 'Available until $endTimeText';
      DateTime startTime = _eventDateTime(event.startTimestamp);
      String payload = JsonEncoder().convert(event);

      _scheduleNotification(event.eventId, title, body, startTime, payload);
    }

    await _logScheduledNotifications();
  }

  /// Schedules the actual notification in the OS.
  Future<void> _scheduleNotification(
      int uniqueId, String title, String body, DateTime scheduledTime, String payload) async {
    await _plugin.schedule(uniqueId, title, body, scheduledTime, _defaultDetails,
        payload: payload, androidAllowWhileIdle: true);
  }

  /// Cancels all pending events with a matching dungeon id.
  Future<void> cancelByDungeonId(int dungeonId) async {
    var pendingNotifications = await _pendingNotifications;
    var payloads = pendingNotifications
        .map((pendingNotification) => JsonDecoder().convert(pendingNotification.payload))
        .toList();

    for (var payload in payloads) {
      if (payload['dungeonId'] == dungeonId) {
        await cancelByEventId(payload['eventId']);
      }
    }
  }

  /// Cancels a single event by event id.
  Future<void> cancelByEventId(int eventId) async {
    Fimber.d('Canceling notification: $eventId');
    await _plugin.cancel(eventId);
  }

  Future<List<PendingNotificationRequest>> get _pendingNotifications async =>
      await _plugin.pendingNotificationRequests();

  Future<void> _logScheduledNotifications() async {
    var notifications = await _plugin.pendingNotificationRequests();
    notifications.forEach((n) =>
        Fimber.v("Notification #${n.id} is pending. Title: '${n.title}', Body: '${n.body}'"));
  }
}

DateTime _eventDateTime(int secondsFromEpoch) =>
    DateTime.fromMillisecondsSinceEpoch(secondsFromEpoch * 1000, isUtc: true);

String _formatTime(DateTime dateTime) => DateFormat.MMMd().add_jm().format(dateTime.toLocal());

EventSearchArgs _upcomingEventArgs() => EventSearchArgs.from(
      [Prefs.eventCountry],
      Prefs.eventStarters,
      ScheduleTabKey.all,
      DateTime.now(),
      DateTime.now().add(Duration(days: 2)),
      Prefs.eventHideClosed,
    );
