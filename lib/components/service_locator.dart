import 'dart:io' show HttpHeaders;

import 'package:dadguide2/components/cache.dart';
import 'package:dadguide2/components/resources.dart';
import 'package:dadguide2/components/version_info.dart';
import 'package:dadguide2/data/database.dart';
import 'package:dadguide2/data/tables.dart';
import 'package:dadguide2/components/notifications.dart';
import 'package:dadguide2/services/device_utils.dart';
import 'package:dadguide2/services/endpoints.dart';
import 'package:dio/dio.dart';
import 'package:flutter_fimber/flutter_fimber.dart';
import 'package:get_it/get_it.dart';

/// Global service locator singleton.
GetIt getIt = GetIt();

/// Initialize global singleton dependencies and register with getIt.
Future<void> initializeServiceLocator(
    {bool useDevEndpoints: false, bool logHttpRequests: false}) async {
  getIt.registerSingleton<PermanentCacheManager>(PermanentCacheManager());
  var dio = Dio();
  if (logHttpRequests) {
    dio.interceptors.add(LogInterceptor());
  }
  getIt.registerSingleton(dio);

  var endpoints = useDevEndpoints ? DevEndpoints() : ProdEndpoints();
  getIt.registerSingleton<Endpoints>(endpoints);

  var versionInfo = await getVersionInfo();
  getIt.registerSingleton(versionInfo);

  var deviceInfo = await createDeviceInfo();
  getIt.registerSingleton(deviceInfo);

  dio.options.headers = {
    HttpHeaders.userAgentHeader:
        'DadGuide v${versionInfo.projectCode} - ${versionInfo.platformVersion}',
  };

  // Initialize Notifications Plugin
  var notifications = NotificationInit();
  getIt.registerSingleton<NotificationInit>(notifications);
}

/// Try to initialize DB dependencies and register them with getIt.
///
/// This may fail if the database has not been downloaded.
Future<void> tryInitializeServiceLocatorDb(bool throwOnFailure) async {
  if (!await ResourceHelper.checkDbExists()) {
    return;
  }
  try {
    var db = await DatabaseHelper.instance.database;
    getIt.registerSingleton<DadGuideDatabase>(db);
    getIt.registerSingleton<MonstersDao>(db.monstersDao);
    getIt.registerSingleton<DungeonsDao>(db.dungeonsDao);
    getIt.registerSingleton<ScheduleDao>(db.scheduleDao);
  } catch (e) {
    if (throwOnFailure) {
      throw e;
    }
  }
}
