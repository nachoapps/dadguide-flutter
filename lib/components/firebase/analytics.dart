import 'package:firebase_analytics/firebase_analytics.dart';

var _analytics = FirebaseAnalytics();

/// Records a screen-change event in Firebase analytics.
void screenChangeEvent(String name) {
  _analytics.setCurrentScreen(screenName: name, screenClassOverride: 'C:$name');
}
