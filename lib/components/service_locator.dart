import 'package:dadguide2/components/cache.dart';
import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get_it/get_it.dart';

GetIt getIt = GetIt();

void initializeServiceLocator({bool dev: true}) {
  getIt.registerSingleton<PermanentCacheManager>(PermanentCacheManager());
  var dio = Dio();
  if (dev) {
    dio.interceptors.add(LogInterceptor());
  }
  getIt.registerSingleton(dio);
}
