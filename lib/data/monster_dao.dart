import 'package:sqflite/sqflite.dart';
import 'package:stack_trace/stack_trace.dart';

import 'database.dart';
import 'monster.dart';

class MonsterDao {
  static final table = 'monster';
  static final columnId = 'monster_no';

  final DatabaseHelper _dbHelper;

  MonsterDao(this._dbHelper);

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
//  Future<int> insert(Map<String, dynamic> row) async {
//    Database db = await instance.database;
//    return await db.insert(table, row);
//  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<MonsterListModel>> queryAllRows() async {
    print('querying!');
    try {
      Database db = await _dbHelper.database;
      var results = await db.query(table, orderBy: 'monster_no_jp DESC');

      return results.isEmpty
          ? []
          : results
              .map((row) => MonsterListModel(monsterFromJson(row)))
              .toList();
    } catch (e, stackTrace) {
      print(e);
      print(Trace.from(stackTrace).terse);
    }
    print('done querying!');

    return [];
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
//  Future<int> queryRowCount() async {
//    Database db = await instance.database;
//    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table'));
//  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
//  Future<int> update(Map<String, dynamic> row) async {
//    Database db = await instance.database;
//    int id = row[columnId];
//    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
//  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
//  Future<int> delete(int id) async {
//    Database db = await instance.database;
//    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
//  }
}
