import 'dart:io';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_fimber/flutter_fimber.dart';

String appId() {
  return Platform.isIOS
      ? 'ca-app-pub-8889612487979093~4523633017'
      : 'ca-app-pub-8889612487979093~4833133513';
}

String bannerId() {
  return Platform.isIOS
      ? 'ca-app-pub-8889612487979093/4405526594'
      : 'ca-app-pub-8889612487979093/5487739634';
}

BannerAd createBannerAd() {
  MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    keywords: <String>['game', 'mobile game', 'puzzles', 'matching', '3-match'],
    childDirected: false,
    testDevices: <String>[], // Android emulators are considered test devices
  );

  return BannerAd(
    adUnitId: bannerId(),
    size: AdSize.banner,
    targetingInfo: targetingInfo,
    listener: (MobileAdEvent event) {
      print("BannerAd event is $event");
    },
  );
}

double getBannerHeight(BuildContext context) {
  return 50;
}

/// The initial size of the banner is calculated on the height of the
/// viewport. Due to ADMob banner refresh policies, in order to have
/// a consistent behaviour, we should keep track of the current AD size
/// and maintain it when the user rotates the screen, and update that
/// value at every banner successful.
/// For now, we will avoid this complexity and set the banner height to
/// the maximum height that a banner could get on this device, forcing
/// the use of the longest side as the base.
/// see https://developers.google.com/admob/android/banner#smart_banners
double getSmartBannerHeight(BuildContext context) {
  MediaQueryData mediaScreen = MediaQuery.of(context);
  double dpHeight = mediaScreen.orientation == Orientation.portrait
      ? mediaScreen.size.height
      : mediaScreen.size.width;
  Fimber.v("Device height: $dpHeight");
  if (dpHeight <= 400.0) {
    return 32.0;
  }
  if (dpHeight > 720.0) {
    return 90.0;
  }
  return 50.0;
}
