import 'package:dadguide2/data/local_tables.dart';

import 'moor_isolate.dart';

/// Create the LocalStorageDatabase on an isolate.
Future<LocalStorageDatabase> createLocalStorageDatabase() async {
  final isolate = await createMoorIsolate('local_data.sqlite');
  final connection = await isolate.connect();
  return LocalStorageDatabase.connect(connection);
}
