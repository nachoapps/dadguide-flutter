import 'tables.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();

  DadGuideDatabase _database;
  DatabaseHelper._internal();

  // only have a single app-wide reference to the database
  Future<DadGuideDatabase> get database async {
    if (_database == null) {
      // lazily instantiate the db the first time it is accessed
      _database = await DadGuideDatabase.fromAsset();
    }
    return _database;
  }
}
