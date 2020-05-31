import 'package:dadguide2/data/local_tables.dart';
import 'package:moor/isolate.dart';
import 'package:moor/moor.dart';

import 'moor_isolate.dart';

/// Create the LocalStorageDatabase on an isolate.
Future<LocalStorageDatabase> createLocalStorageDatabase() async {
  MoorIsolate isolate = await createMoorIsolate('local_data.sqlite');
  DatabaseConnection connection = await isolate.connect();
  return LocalStorageDatabase.connect(connection);
}
