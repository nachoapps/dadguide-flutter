import 'package:dadguide2/components/cache.dart';
import 'package:dadguide2/data/database.dart';
import 'package:dadguide2/data/tables.dart';
import 'package:dadguide2/services/endpoints.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

/// Global service locator singleton.
GetIt getIt = GetIt();

/// Initialize global singleton dependencies and register with getIt.
void initializeServiceLocator({bool useDevEndpoints: false, bool logHttpRequests: false}) {
  getIt.registerSingleton<PermanentCacheManager>(PermanentCacheManager());
  var dio = Dio();
  if (logHttpRequests) {
    dio.interceptors.add(LogInterceptor());
  }
  getIt.registerSingleton(dio);

  var endpoints = useDevEndpoints ? DevEndpoints() : ProdEndpoints();
  getIt.registerSingleton<Endpoints>(endpoints);
}

/// Try to initialize DB dependencies and register them with getIt.
///
/// This may fail if the database has not been downloaded.
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
