import 'dart:io';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_fimber/flutter_fimber.dart';

/// The platform-specific AdMob ID. They make you register separate apps for iOS and Android.
String appId() {
  return Platform.isIOS
      ? 'ca-app-pub-8889612487979093~4523633017'
      : 'ca-app-pub-8889612487979093~4833133513';
}

/// Create a banner ad with the default
BannerAd createBannerAd(String bannerId) {
  MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    keywords: <String>['game', 'mobile game', 'puzzles', 'matching', '3-match'],
    childDirected: false,
    testDevices: <String>[], // Android emulators are considered test devices
  );

  return BannerAd(
    adUnitId: bannerId,
    size: AdSize.banner,
    targetingInfo: targetingInfo,
    listener: (MobileAdEvent event) {
      if (event == MobileAdEvent.failedToLoad) {
        Fimber.w('BannerAd failed to load: $event');
      } else {
        Fimber.v('BannerAd event: $event');
      }
    },
  );
}

/// The size of a 'standard' banner. The smart banner looked wrong on my device, needs more testing.
double getBannerHeight(BuildContext context) {
  return 50;
}

/// The initial size of the banner is calculated on the height of the
/// viewport. Since the app cannot rotate, this only needs to be checked once.
/// see https://developers.google.com/admob/android/banner#smart_banners
double getSmartBannerHeight(BuildContext context) {
  MediaQueryData mediaScreen = MediaQuery.of(context);
  // The app is fixed into portrait orientation so no need to check.
  double dpHeight = mediaScreen.size.height;
  if (dpHeight <= 400.0) {
    return 32.0;
  }
  if (dpHeight > 720.0) {
    return 90.0;
  }
  return 50.0;
}
