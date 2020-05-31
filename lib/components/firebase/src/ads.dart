import 'package:dadguide2/components/config/service_locator.dart';
import 'package:dadguide2/components/config/settings_manager.dart';
import 'package:dadguide2/components/firebase/analytics.dart';
import 'package:dadguide2/services/api.dart';
import 'package:dadguide2/services/device_utils.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_fimber/flutter_fimber.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
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
  static final removeAdsProductId = 'dadguide.remove_ads.1';
  static final AdStatusManager instance = AdStatusManager._internal();

  static final _iap = InAppPurchaseConnection.instance;
  bool _iapAvailable = false;
  List<ProductDetails> _productDetails = [];
  final Map<String, PurchaseDetails> _purchaseDetails = {};

  AdStatusManager._internal();

  /// Publishes status events for the app.
  final status = BehaviorSubject.seeded(AdStatus.enabled);

  /// Checks the ad preference state and emits it.
  AdStatus syncInitFromPrefs() {
    var adStatus = Prefs.adsEnabled ? AdStatus.enabled : AdStatus.disabled;
    status.add(adStatus);
    return adStatus;
  }

  /// Sets the local preference for ads to false and triggers a state change.
  void disableAds() {
    Prefs.adsEnabled = false;
    syncInitFromPrefs();
  }

  /// Sets the local preference for ads to true and triggers a state change.
  void enableAds() {
    Prefs.adsEnabled = true;
    syncInitFromPrefs();
  }

  /// Hooks up a listener to the IAP purchase stream.
  ///
  /// Should only be called once, immediately at startup.
  void listenForIap() {
    _iap.purchaseUpdatedStream.listen((purchases) {
      Fimber.i('Streamed ${purchases.length} purchases');
      _addAllPurchases(purchases);
      if (purchases.any(_isApprovedAdRemoval)) {
        iapPurchaseOk();
      } else if (purchases.any(_isErrorAdRemoval)) {
        iapPurchaseFailure();
      }
    });
  }

  bool get iapAvailable => _iapAvailable;

  /// Determines if IAP is online, and if so, requests products and purchases.
  Future<bool> populateIap() async {
    Fimber.i('Populating IAP');
    _iapAvailable = await _iap.isAvailable();
    iapInitialized(_iapAvailable);

    if (_iapAvailable) {
      await _populateProducts();

      // If the user seems to have ads disabled, retrieve their purchases to confirm it.
      // Don't always fetch this because it forces a store login.
      if (!Prefs.adsEnabled) {
        await populatePurchases();
      }
    }

    return _iapAvailable;
  }

  /// Return the ProductDetails for the remove ads IAP. Might return null if not available.
  ProductDetails getRemoveAdsProduct() {
    return _productDetails.isEmpty
        ? null
        : _productDetails.firstWhere((pd) => pd.id == removeAdsProductId);
  }

  Future<bool> startPurchaseFlow() async {
    var deviceId = await getDeviceId();
    if (deviceId != null) {
      // If we have a device ID, hash it before sending to google play (per docs).
      deviceId = deviceId.hashCode.toString();
    }

    var iapResult = await _iap.buyNonConsumable(
      purchaseParam: PurchaseParam(
        applicationUserName: deviceId,
        productDetails: getRemoveAdsProduct(),
      ),
    );
    Fimber.i('IAP result: $iapResult');
    return iapResult;
  }

  Future<void> _populateProducts() async {
    Fimber.i('Populating products');
    final resp = await _iap.queryProductDetails({removeAdsProductId});
    if (resp.notFoundIDs.isNotEmpty) {
      Fimber.e('Missing IDs: ${resp.notFoundIDs}');
    }
    if (resp.error == null) {
      _setAllProducts(resp.productDetails);
    } else {
      Fimber.e('Retreiving products failed: ${resp.error.code} : ${resp.error.details}');
    }
  }

  void _setAllProducts(List<ProductDetails> products) {
    for (var p in products) {
      final title = p.skuDetail?.title ?? p.skProduct?.localizedTitle;
      final price = p.skuDetail?.price ?? p.skProduct?.price;
      Fimber.i('Got product: id=${p.id} title=$title price=$price');
    }
    _productDetails = products;
  }

  Future<void> populatePurchases() async {
    Fimber.i('Populating purchases');
    final resp = await _iap.queryPastPurchases();
    if (resp.error == null) {
      _addAllPurchases(resp.pastPurchases);
    } else {
      Fimber.e('Retreiving purchase records failed: ${resp.error.code} : ${resp.error.details}');
    }
  }

  void _addAllPurchases(List<PurchaseDetails> purchases) {
    for (var p in purchases) {
      Fimber.i(
          'Got purchase: id=${p.purchaseID} product=${p.productID} status=${p.status} pending=${p.pendingCompletePurchase}');
      _purchaseDetails[p.purchaseID] = p;

      var bcp = p.billingClientPurchase;
      if (bcp != null) {
        Fimber.i('ack=${bcp.isAcknowledged} state=${bcp.purchaseState}');
      }
      var pt = p.skPaymentTransaction;
      if (pt != null) {
        Fimber.i('err=${pt.error} state=${pt.transactionState}');
      }
    }
    _checkForAdRemovalPurchase();
    _maybeCompletePurchases();
  }

  Future<void> _maybeCompletePurchases() async {
    final pendingCompletes = _purchaseDetails.values.where((p) => p.pendingCompletePurchase);
    for (var purchase in pendingCompletes) {
      try {
        final result = await _iap.completePurchase(purchase);
        if (result.responseCode != BillingResponse.ok) {
          Fimber.e(
              'Bad response from completePurchase: ${result.responseCode} : ${result.debugMessage}');
        }
      } catch (ex) {
        Fimber.e('Completing purchase failed: $ex}');
      }
    }
  }

  List<PurchaseDetails> _getAdsPurchases() =>
      _purchaseDetails.values.where((p) => p.productID == removeAdsProductId).toList();

  PurchaseDetails getAdRemovalPurchase() {
    final adsPurchases = _getAdsPurchases();
    return adsPurchases.isEmpty
        ? null
        : adsPurchases.firstWhere((p) => p.status == PurchaseStatus.purchased);
  }

  void _checkForAdRemovalPurchase() async {
    final adsPurchases = _getAdsPurchases();
    final adsDisabledPurchase = getAdRemovalPurchase();
    final latestPurchase = adsPurchases.isEmpty
        ? null
        : adsPurchases.reduce((l, r) => _purchaseDate(l) > _purchaseDate(r) ? l : r);

    if (adsDisabledPurchase != null) {
      if (Prefs.adsEnabled) {
        Fimber.i('Recording purchase');
        try {
          await getIt<ApiClient>().submitPurchase(adsDisabledPurchase);
        } catch (ex) {
          Fimber.e('Failed to submit purchase', ex: ex);
        }
      }
      Fimber.i('Disabling ads');
      disableAds();
    } else {
      if (!Prefs.adsEnabled) {
        Fimber.i('Recording error or other');
        try {
          await getIt<ApiClient>().submitPurchase(latestPurchase);
        } catch (ex) {
          Fimber.e('Failed to submit error purchase', ex: ex);
        }
      }
      Fimber.e('Enabling ads');
      enableAds();
    }
  }

  bool _isApprovedAdRemoval(PurchaseDetails p) =>
      p.productID == removeAdsProductId && p.status == PurchaseStatus.purchased;
  bool _isErrorAdRemoval(PurchaseDetails p) => p.status == PurchaseStatus.error;
  int _purchaseDate(PurchaseDetails p) => int.tryParse(p.transactionDate) ?? 0;
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
  // The app is fixed into portrait orientation so no need to check.
  final dpHeight = MediaQuery.of(context).size.height;
  if (dpHeight <= 400.0) {
    return 32.0;
  }
  if (dpHeight > 720.0) {
    return 90.0;
  }
  return 50.0;
}

EdgeInsets dialogInsetsAccountingForAd(BuildContext context) {
  var offset =
      AdStatusManager.instance.status.value == AdStatus.disabled ? 0 : getBannerHeight(context);
  return EdgeInsets.only(left: 40.0, right: 40.0, top: 24.0, bottom: 48 + offset);
}
