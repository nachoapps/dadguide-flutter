import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter_fimber/flutter_fimber.dart';

Future<DeviceInfo> createDeviceInfo() async {
  try {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      var iosInfo = await deviceInfo.iosInfo;
      return DeviceInfo.ios(iosInfo.systemVersion);
    } else {
      var androidInfo = await deviceInfo.androidInfo;
      return DeviceInfo.android(androidInfo.version.release);
    }
  } catch (ex) {
    Fimber.w('Failed to create Device Info', ex: ex);
    return DeviceInfo.unknown();
  }
}

enum DevicePlatform { ANDROID, IOS, UNKNOWN }

class DeviceInfo {
  final DevicePlatform platform;
  final DeviceOsVersion osVersion;

  DeviceInfo.ios(String versionString)
      : platform = DevicePlatform.IOS,
        osVersion = DeviceOsVersion.fromVersionString(versionString);

  DeviceInfo.android(String versionString)
      : platform = DevicePlatform.ANDROID,
        osVersion = DeviceOsVersion.fromVersionString(versionString);

  DeviceInfo.unknown()
      : platform = DevicePlatform.UNKNOWN,
        osVersion = DeviceOsVersion(0, 0, 0);
}

class DeviceOsVersion {
  final int major, minor, patch;

  DeviceOsVersion(this.major, this.minor, this.patch);

  // Expects something like "10.0", or "11.2.3"
  factory DeviceOsVersion.fromVersionString(String versionString) {
    var split = versionString.split(".");

    var major, minor, patch = 0;

    if (split.length > 0) {
      major = int.parse(split.elementAt(0)) ?? 0;
    }

    if (split.length > 1) {
      minor = int.parse(split.elementAt(1)) ?? 0;
    }

    if (split.length > 2) {
      patch = int.parse(split.elementAt(2)) ?? 0;
    }

    return new DeviceOsVersion(major, minor, patch);
  }

  @override
  String toString() {
    return "$major.$minor.$patch";
  }
}
