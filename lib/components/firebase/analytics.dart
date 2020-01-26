import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_fimber/flutter_fimber.dart';

var _analytics = FirebaseAnalytics();

/// Records a screen-change event in Firebase analytics.
void screenChangeEvent(String name) {
  try {
    _analytics.setCurrentScreen(screenName: name, screenClassOverride: 'C:$name');
  } catch (ex) {
    Fimber.e('Failed to record screen change $name');
  }
}

/// Record a generic kind of event.
void recordEvent(String eventName) {
  try {
    _analytics.logEvent(name: eventName);
  } catch (ex) {
    Fimber.e('Failed to record event $eventName');
  }
}
