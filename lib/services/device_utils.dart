abstract class DeviceInfo {
  final DevicePlatform platform;
  final DeviceOsVersion osVersion;

  const DeviceInfo(this.platform, this.osVersion);
}

enum DevicePlatform {
  ANDROID, IOS
}

class DeviceOsVersion {
  final int major, minor, patch;

  DeviceOsVersion(this.major, this.minor, this.patch);

  // Expects something like "10.0", or "11.2.3"
  factory DeviceOsVersion.fromVersionString(String versionString) {  
    var split = versionString
      .split(".");
  
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

class IosDeviceInfo extends DeviceInfo {
  IosDeviceInfo(String versionString) : super(DevicePlatform.IOS, DeviceOsVersion.fromVersionString(versionString));
}