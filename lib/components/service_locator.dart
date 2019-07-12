import 'package:dadguide2/components/cache.dart';
import 'package:dadguide2/services/endpoints.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

GetIt getIt = GetIt();

void initializeServiceLocator({bool dev: true}) async {
  getIt.registerSingleton<PermanentCacheManager>(PermanentCacheManager());
  var dio = Dio();
  if (dev) {
    dio.interceptors.add(LogInterceptor());
  }
  getIt.registerSingleton(dio);

  var endpoints = dev ? DevEndpoints() : ProdEndpoints();
  getIt.registerSingleton<Endpoints>(endpoints);
}
