import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_fimber/flutter_fimber.dart';

/// Wrapper around Firebase RemoteConfig that makes it a bit easier to use.
class RemoteConfigWrapper {
  static Completer<RemoteConfig> _initCompleter = Completer<RemoteConfig>();

  /// Unlike the regular Firebase instance method, this only completes once
  /// the values have been fetched and activated.
  static Future<RemoteConfig> get instance async {
    if (!_initCompleter.isCompleted) {
      _initCompleter.complete(await _getRemoteConfigInstance());
    }
    return _initCompleter.future;
  }

  /// Returns a completely initialized RemoteConfig with values fetched.
  static Future<RemoteConfig> _getRemoteConfigInstance() async {
    var instance = await RemoteConfig.instance;
    await instance.fetch(expiration: const Duration(hours: 6));
    await instance.activateFetched();

    disableMedia = instance.getBool('disable_media');
    disableEggMachine = instance.getBool('disable_egg_machine');
    disableExchange = instance.getBool('disable_exchange');
    iosBanner = instance.getString('ios_banner');
    androidBanner = instance.getString('android_banner');

    Fimber.i('disableMedia: $disableMedia'
        ', disableEggMachine: $disableEggMachine'
        ', disableExchange: $disableExchange'
        ', iosBanner: ${iosBanner?.length}'
        ', androidBanner: ${androidBanner?.length}');

    return instance;
  }

  // Toggles for new features.
  static bool disableMedia = false;
  static bool disableEggMachine = false;
  static bool disableExchange = false;

  // Guaranteed to be set in remoteconfig.
  static String iosBanner = '';
  static String androidBanner = '';
}
