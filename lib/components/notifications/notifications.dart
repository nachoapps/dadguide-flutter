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

  final _cachedNotificationIds = <int>[];

  /// Takes the schedule and ensures notifications exist for each tracked dungeon.
  Future<void> ensureEventsScheduled() async {
    await _plugin.cancelAll();
    var events = await getIt<ScheduleDao>().findListEvents(_upcomingEventArgs());
    var eventsToSchedule =
        events.where((le) => Prefs.trackedDungeons.contains(le.dungeon.dungeonId)).toList();

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

      await _scheduleNotification(event.eventId, title, body, startTime, payload);
    }

    await _logAndStoreNotifications();
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
        await cancelByEventId(payload['eventId'], update: false);
      }
    }
    await _logAndStoreNotifications();
  }

  // This is deliberately synchronous; it needs to be called from build().
  bool isEventTracked(int eventId) {
    return _cachedNotificationIds.contains(eventId);
  }

  /// Cancels a single event by event id.
  Future<void> cancelByEventId(int eventId, {bool update: true}) async {
    Fimber.d('Canceling notification: $eventId');
    await _plugin.cancel(eventId);
    if (update) await _logAndStoreNotifications();
  }

  Future<List<PendingNotificationRequest>> get _pendingNotifications async =>
      await _plugin.pendingNotificationRequests();

  // This does double-duty for caching the notifications so it should be called
  // whenever a modification is made.
  Future<void> _logAndStoreNotifications() async {
    var notifications = await _plugin.pendingNotificationRequests();
    Fimber.i('There are ${notifications.length} notifications pending');
    _cachedNotificationIds.clear();
    _cachedNotificationIds.addAll(notifications.map((n) => n.id));
  }
}

DateTime _eventDateTime(int secondsFromEpoch) =>
    DateTime.fromMillisecondsSinceEpoch(secondsFromEpoch * 1000, isUtc: true);

String _formatTime(DateTime dateTime) => DateFormat.MMMd().add_jm().format(dateTime.toLocal());

EventSearchArgs _upcomingEventArgs() => EventSearchArgs.from(
      [Prefs.gameCountry],
      Prefs.eventStarters,
      ScheduleTabKey.all,
      DateTime.now(),
      DateTime.now().add(Duration(days: 2)),
      Prefs.eventHideClosed,
    );
