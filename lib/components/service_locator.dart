import 'package:dadguide2/components/cache.dart';
import 'package:dadguide2/data/database.dart';
import 'package:dadguide2/data/tables.dart';
import 'package:dadguide2/services/endpoints.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

GetIt getIt = GetIt();

void initializeServiceLocator({bool dev: true}) {
  getIt.registerSingleton<PermanentCacheManager>(PermanentCacheManager());
  var dio = Dio();
  if (dev) {
    dio.interceptors.add(LogInterceptor());
  }
  getIt.registerSingleton(dio);

  var endpoints = dev ? DevEndpoints() : ProdEndpoints();
  getIt.registerSingleton<Endpoints>(endpoints);
}

Future<void> tryInitializeServiceLocatorDb(bool throwOnFailure) async {
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
