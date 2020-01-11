import 'package:get_version/get_version.dart';

/// Safely get version info for the current device and app.
Future<VersionInfo> getVersionInfo() async {
  var platformVersion = 'Unknown';
  var projectVersion = '';
  var projectCode = '';
  var projectAppID = '';
  var projectName = '';

  // Platform messages are asynchronous, so we initialize in an async method.
  try {
    platformVersion = await GetVersion.platformVersion;
  } catch (e) {
    platformVersion = 'Failed to get platform version.';
  }

  try {
    projectVersion = await GetVersion.projectVersion;
  } catch (e) {
    projectVersion = 'Failed to get project version.';
  }

  try {
    projectCode = await GetVersion.projectCode;
  } catch (e) {
    projectCode = 'Failed to get build number.';
  }

  try {
    projectAppID = await GetVersion.appID;
  } catch (e) {
    projectAppID = 'Failed to get app ID.';
  }

  try {
    projectName = await GetVersion.appName;
  } catch (e) {
    projectName = 'Failed to get app name.';
  }

  return VersionInfo._(platformVersion, projectVersion, projectCode, projectAppID, projectName);
}

/// Container for device and app version info.
class VersionInfo {
  final String platformVersion;
  final String projectVersion;
  final String projectCode;
  final String projectAppID;
  final String projectName;

  VersionInfo._(
    this.platformVersion,
    this.projectVersion,
    this.projectCode,
    this.projectAppID,
    this.projectName,
  );
}
