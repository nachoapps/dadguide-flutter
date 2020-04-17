import 'dart:async';
import 'dart:io';

import 'package:dadguide2/components/config/service_locator.dart';
import 'package:dadguide2/components/firebase/remote_config.dart';
import 'package:dadguide2/components/firebase/src/ads.dart';
import 'package:dadguide2/services/device_utils.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_fimber/flutter_fimber.dart';

/// Helper widget for reacting to ad availability status changes.
///
/// Displays the supplied enabled/disabled widgets as appropriate based on the stream status. If an
/// error occurs, displays some error symbols.
class AdAvailabilityWidget extends StatelessWidget {
  final Widget enabled;
  final Widget disabled;

  const AdAvailabilityWidget(this.enabled, this.disabled);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: AdStatusManager.instance.status.value,
      stream: AdStatusManager.instance.status.stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          Fimber.e('Unexpected error in AdAvailability widget: ${snapshot.error}');
          return Icon(Icons.error_outline, color: Colors.red);
        } else if (!snapshot.hasData) {
          Fimber.e('Unexpected missing data in AdAvailability widget');
          return Icon(Icons.error_outline, color: Colors.yellow);
        }

        switch (snapshot.data) {
          case AdStatus.enabled:
            return enabled;
          case AdStatus.disabled:
            return disabled;
          default:
            Fimber.e('Error, unexpected ad state ${snapshot.data}');
            return Icon(Icons.mood_bad);
        }
      },
    );
  }
}

/// Displays 'on' or 'off' depending on the status of ads.
class AdAvailabilityStatusWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AdAvailabilityWidget(Text('On'), Text('Off)'));
  }
}

/// Leaves a spacer if ads are on, otherwise collapses.
class AdAvailabilitySpacerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AdAvailabilityWidget(
      SizedBox(height: getBannerHeight(context) + 12),
      Container(),
    );
  }
}

/// The platform-specific AdMob ID. They make you register separate apps for iOS and Android.
String appId() {
  return Platform.isIOS
      ? 'ca-app-pub-8889612487979093~4523633017'
      : 'ca-app-pub-8889612487979093~4833133513';
}

class BannerAdManager {
  /// Initialization status. May be true even though _bannerAd is null.
  bool _initialized = false;

  /// Banner ad, which may or may not be null.
  BannerAd _bannerAd;

  // Subscription to the ad status which can disable the ad, may or may not be null.
  StreamSubscription<AdStatus> _subscription;

  Future<bool> init() async {
    if (_initialized) {
      Fimber.e('Attempted to init BannerAdManager multiple times, BannerAd=$_bannerAd');
      return false;
    }
    _initialized = true;

    var deviceInfo = getIt<DeviceInfo>();
    if (deviceInfo.platform == DevicePlatform.IOS && deviceInfo.osVersion.major < 11) {
      Fimber.w('Skipping ad load due to IOS bug');
      return false;
    }

    await RemoteConfigWrapper.instance;
    var bannerId =
        Platform.isIOS ? RemoteConfigWrapper.iosBanner : RemoteConfigWrapper.androidBanner;
    if (bannerId == null || bannerId.isEmpty) {
      Fimber.e('No bannerId available');
      return false;
    }

    _bannerAd = createBannerAd(bannerId);
    _subscription = AdStatusManager.instance.status.listen((as) {
      if (as == AdStatus.disabled) {
        dispose();
      }
    });

    final loaded = await _bannerAd.load();

    // We waited, so confirm we haven't been disposed.
    if (_bannerAd == null) return false;
    Fimber.i('Ad loaded: $loaded');

    final shown = await _bannerAd.show();
    Fimber.i('Ad shown: $shown');

    return shown;
  }

  Future<bool> dispose() async {
    if (_subscription != null) {
      _subscription.cancel();
      _subscription = null;
    }
    if (_bannerAd != null) {
      var result = _bannerAd.dispose();
      _bannerAd = null;
      return result;
    }
    return true;
  }
}
