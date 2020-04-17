import 'package:dadguide2/components/config/settings_manager.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_fimber/flutter_fimber.dart';
import 'package:rxdart/rxdart.dart';

/// Represents whether ads are enabled or disabled.
enum AdStatus {
  /// Ads are enabled. The default value until sign-in.
  enabled,

  /// Ads are disabled. Only available after sign-in.
  disabled,
}

/// Interface that can be used to enable/disable ads.
///
/// Must call syncInitFromPrefs() after preferences have been initialized, and later on
/// asyncInitFromFirestore() before launching the app.
class AdStatusManager {
  AdStatusManager._internal();
  static final AdStatusManager instance = new AdStatusManager._internal();

  /// Publishes status events for the app.
  final status = BehaviorSubject.seeded(AdStatus.enabled);

  AdStatus syncInitFromPrefs() {
    var adStatus = Prefs.adsEnabled ? AdStatus.enabled : AdStatus.disabled;
    status.add(adStatus);
    return adStatus;
  }

  // Maybe we don't need this and it should just stream from the user thing?
//  Future<AdStatus> asyncInitFromFirestore() async {
//    var adsEnabled = false; // Change this to load from firestore
//    Prefs.adsEnabled = adsEnabled;
//    return syncInitFromPrefs();
//  }

  void disableAds() {
    Prefs.adsEnabled = false;
    syncInitFromPrefs();
  }

  void enableAds() {
    Prefs.adsEnabled = true;
    syncInitFromPrefs();
  }
}

MobileAdTargetingInfo createTargetingInfo() {
  return MobileAdTargetingInfo(
    keywords: <String>['game', 'mobile game', 'puzzles', 'matching', '3-match'],
    childDirected: false,
    testDevices: <String>[], // Android emulators are considered test devices
  );
}

/// Create a banner ad with the default
BannerAd createBannerAd(String bannerId) {
  return BannerAd(
    adUnitId: bannerId,
    size: AdSize.banner,
    targetingInfo: createTargetingInfo(),
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
