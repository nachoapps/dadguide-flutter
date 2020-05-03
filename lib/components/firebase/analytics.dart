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

void iapInitialized(bool init) {
  if (!init) {
    Fimber.i('Recording iap init failure');
    recordEvent('iap_init_failure');
  }
}

bool _iapSeenEventRecorded = false;

/// Record that the widget was visible to the user. Can only fire once per session.
void iapSeen() {
  if (_iapSeenEventRecorded) {
    return;
  }
  Fimber.i('Recording iap seen');
  _iapSeenEventRecorded = true;
  recordEvent('iap_view_seen');
}

void iapClicked() {
  Fimber.i('Recording iap click');
  recordEvent('iap_click');
}

void iapClickFailed() {
  Fimber.i('Recording iap click failed');
  recordEvent('iap_click_failed');
}

void iapPurchaseOk() {
  Fimber.i('Recording iap purchase ok');
  recordEvent('iap_purchase_ok');
}

void iapPurchaseFailure() {
  Fimber.i('Recording iap purchase failure');
  recordEvent('iap_purchase_failure');
}

void screenshotSuccess() {
  Fimber.i('Recording iap click');
  recordEvent('screenshot_success');
}

void screenshotFailure() {
  recordEvent('screenshot_failure');
}
