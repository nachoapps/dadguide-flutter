import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:moor_flutter/moor_flutter.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'tables.g.dart';

class ActiveSkills extends Table {
  IntColumn get activeSkillId => integer().autoIncrement()();

  TextColumn get nameJp => text()();
  TextColumn get nameNa => text()();
  TextColumn get nameKr => text()();

  TextColumn get descJp => text()();
  TextColumn get descNa => text()();
  TextColumn get descKr => text()();

  IntColumn get turnMax => integer()();
  IntColumn get turnMin => integer()();

  IntColumn get tstamp => integer()();
}

class Awakenings extends Table {
  IntColumn get awakeningId => integer().autoIncrement()();

  IntColumn get monsterId => integer()();
  IntColumn get awokenSkillId => integer()();

  BoolColumn get isSuper => boolean()();
  IntColumn get orderIdx => integer()();

  IntColumn get tstamp => integer()();
}

class AwokenSkills extends Table {
  IntColumn get awokenSkillId => integer().autoIncrement()();

  TextColumn get nameJp => text()();
  TextColumn get nameNa => text()();
  TextColumn get nameKr => text()();

  TextColumn get descJp => text()();
  TextColumn get descNa => text()();
  TextColumn get descKr => text()();

  IntColumn get adjHp => integer()();
  IntColumn get adjAtk => integer()();
  IntColumn get adjRcv => integer()();

  IntColumn get tstamp => integer()();
}

class Dungeons extends Table {
  IntColumn get dungeonId => integer().autoIncrement()();

  TextColumn get nameJp => text()();
  TextColumn get nameNa => text()();
  TextColumn get nameKr => text()();

  IntColumn get dungeonType => integer()();
  IntColumn get seriesId => integer()();

  TextColumn get commentJp => text()();
  TextColumn get commentNa => text()();
  TextColumn get commentKr => text()();

  BoolColumn get visible => boolean()();
  IntColumn get tstamp => integer()();
}

class Evolutions extends Table {
  IntColumn get evolutionId => integer().autoIncrement()();
  IntColumn get evolutionType => integer()();

  IntColumn get fromId => integer()();
  IntColumn get toId => integer()();

  IntColumn get mat1Id => integer()();
  IntColumn get mat2Id => integer().nullable()();
  IntColumn get mat3Id => integer().nullable()();
  IntColumn get mat4Id => integer().nullable()();
  IntColumn get mat5Id => integer().nullable()();

  IntColumn get tstamp => integer()();
}

class LeaderSkills extends Table {
  IntColumn get leaderSkillId => integer().autoIncrement()();

  TextColumn get nameJp => text()();
  TextColumn get nameNa => text()();
  TextColumn get nameKr => text()();

  TextColumn get descJp => text()();
  TextColumn get descNa => text()();
  TextColumn get descKr => text()();

  RealColumn get maxHp => real()();
  RealColumn get maxAtk => real()();
  RealColumn get maxRcv => real()();
  RealColumn get maxShield => real()();

  IntColumn get tstamp => integer()();
}

class Monsters extends Table {
  IntColumn get monsterId => integer().autoIncrement()();
  IntColumn get monsterNoJp => integer()();
  IntColumn get monsterNoNa => integer()();
  IntColumn get monsterNoKr => integer()();

  TextColumn get nameJp => text()();
  TextColumn get nameNa => text()();
  TextColumn get nameKr => text()();
  TextColumn get pronunciationJp => text()();

  IntColumn get hpMax => integer()();
  IntColumn get hpMin => integer()();
  RealColumn get hpScale => real()();

  IntColumn get atkMax => integer()();
  IntColumn get atkMin => integer()();
  RealColumn get atkScale => real()();

  IntColumn get rcvMax => integer()();
  IntColumn get rcvMin => integer()();
  RealColumn get rcvScale => real()();

  IntColumn get cost => integer()();
  IntColumn get exp => integer()();
  IntColumn get level => integer()();
  IntColumn get rarity => integer()();
  IntColumn get limitMult => integer().nullable()();

  IntColumn get attribute1Id => integer().named('attribute_1_id')();
  IntColumn get attribute2Id => integer().named('attribute_2_id').nullable()();

  IntColumn get leaderSkillId => integer().nullable()();
  IntColumn get activeSkillId => integer().nullable()();

  IntColumn get type1Id => integer().named('type_1_id')();
  IntColumn get type2Id => integer().named('type_2_id').nullable()();
  IntColumn get type3Id => integer().named('type_3_id').nullable()();

  BoolColumn get inheritable => boolean()();
  IntColumn get fodderExp => integer()();
  IntColumn get sellGold => integer()();
  IntColumn get sellMp => integer()();
  IntColumn get buyMp => integer()();
  TextColumn get regDate => text()();

  BoolColumn get onJp => boolean()();
  BoolColumn get onNa => boolean()();
  BoolColumn get onKr => boolean()();

  BoolColumn get palEgg => boolean()();
  BoolColumn get remEgg => boolean()();
  IntColumn get seriesId => integer().nullable()();

  TextColumn get name_na_override => text().nullable()();

  IntColumn get tstamp => integer()();
}

class Schedule extends Table {
  IntColumn get eventId => integer().autoIncrement()();
  IntColumn get serverId => integer()();
  IntColumn get eventTypeId => integer()();
  IntColumn get startTimestamp => integer()();
  IntColumn get endTimestamp => integer()();

  TextColumn get groupName => text().nullable()();
  IntColumn get dungeonId => integer().nullable()();
  TextColumn get url => text()();
  TextColumn get info => text()();
  // TODO: infoNa/jp/kr

  IntColumn get tstamp => integer()();
}

@DataClassName("SeriesData")
class Series extends Table {
  IntColumn get seriesId => integer().autoIncrement()();

  TextColumn get nameJp => text()();
  TextColumn get nameNa => text()();
  TextColumn get nameKr => text()();

  IntColumn get tstamp => integer()();
}

//
//class SkillCondition extends Table {
//  IntColumn get conditionId => integer().autoIncrement()();
//  IntColumn get conditionType => integer()();
//
//  TextColumn get nameJp => text()();
//  TextColumn get nameNa => text()();
//  TextColumn get nameKr => text()();
//  IntColumn get orderIdx => integer()();
//
//  IntColumn get tstamp => integer()();
//}

class Timestamps extends Table {
  TextColumn get name => text()();
  IntColumn get tstamp => integer()();

  @override
  Set<Column> get primaryKey => {name};
}

class FullMonster {
  Monster _monster;
  ActiveSkill _activeSkill;
  LeaderSkill _leaderSkill;
  SeriesData _series;

  FullMonster(this._monster, this._activeSkill, this._leaderSkill, this._series);

  Monster get monster => _monster;
  ActiveSkill get activeSkill => _activeSkill;
  LeaderSkill get leaderSkill => _leaderSkill;
  SeriesData get series => _series;
}

@UseMoor(tables: [
  ActiveSkills,
  Awakenings,
  AwokenSkills,
  Evolutions,
  LeaderSkills,
  Monsters,
  Series,
//  SkillCondition,
  Timestamps,
])
class DadGuideDatabase extends _$DadGuideDatabase {
  static final _dbName = 'database.sqlite';

  static Future<DadGuideDatabase> fromAsset() async {
    var databasesPath = await sqflite.getDatabasesPath();
    var path = join(databasesPath, _dbName);

    await File(path).delete();
    // Only copy if the database doesn't exist
    if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound) {
      print('copying');
      // Load database from asset and copy
      ByteData data = await rootBundle.load(join('assets', 'data', _dbName));
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      print(bytes.length);

      // Save copied asset to documents
      await new File(path).writeAsBytes(bytes);
    }

    return DadGuideDatabase(path);
  }

  DadGuideDatabase(String dbPath) : super(FlutterQueryExecutor(path: dbPath, logStatements: true));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) {
        return m.createAllTables();
      },
//      onUpgrade: (Migrator m, int from, int to) async {
//        if (from == 1) {
//          await m.addColumn(todos, todos.targetDate);
//        }
//      },
    );
  }

  Future<List<Monster>> get allMonsters => select(monsters).get();

  Future<FullMonster> fullMonster(int monsterId) {
    final query = (select(monsters)..where((m) => m.monsterId.equals(monsterId))).join([
      leftOuterJoin(activeSkills, activeSkills.activeSkillId.equalsExp(monsters.activeSkillId)),
      leftOuterJoin(leaderSkills, leaderSkills.leaderSkillId.equalsExp(monsters.leaderSkillId)),
      leftOuterJoin(series, series.seriesId.equalsExp(monsters.seriesId)),
    ]);

    var fullMonster = query.get().then((rows) {
      return rows.map((row) {
        return FullMonster(
          row.readTable(monsters),
          row.readTable(activeSkills),
          row.readTable(leaderSkills),
          row.readTable(series),
        );
      }).first;
    });

    return fullMonster;
  }

//  Future<List<MonsterData>> get allMonsters => (select(monster)..where((m) => true)).watch();

//  Stream<List<CategoryWithCount>> categoriesWithCount() {
//    // select all categories and load how many associated entries there are for
//    // each category
//    return customSelectStream(
//      'SELECT c.*, (SELECT COUNT(*) FROM todos WHERE category = c.id) AS amount'
//      ' FROM categories c '
//      'UNION ALL SELECT null, null, '
//      '(SELECT COUNT(*) FROM todos WHERE category IS NULL)',
//      readsFrom: {todos, categories},
//    ).map((rows) {
//      // when we have the result set, map each row to the data class
//      return rows.map((row) {
//        final hasId = row.data['id'] != null;
//
//        return CategoryWithCount(
//          hasId ? Category.fromData(row.data, this) : null,
//          row.readInt('amount'),
//        );
//      }).toList();
//    });
//  }

  /// Watches all entries in the given [category]. If the category is null, all
  /// entries will be shown instead.
//  Stream<List<EntryWithCategory>> watchEntriesInCategory(Category category) {
//    final query = select(todos).join(
//        [leftOuterJoin(categories, categories.id.equalsExp(todos.category))]);
//
//    if (category != null) {
//      query.where(categories.id.equals(category.id));
//    } else {
//      query.where(isNull(categories.id));
//    }
//
//    return query.watch().map((rows) {
//      // read both the entry and the associated category for each row
//      return rows.map((row) {
//        return EntryWithCategory(
//          row.readTable(todos),
//          row.readTable(categories),
//        );
//      }).toList();
//    });
//  }

//  Future createEntry(TodoEntry entry) {
//    return into(todos).insert(entry);
//  }

  /// Updates the row in the database represents this entry by writing the
  /// updated data.
//  Future updateEntry(TodoEntry entry) {
//    return update(todos).replace(entry);
//  }
//
//  Future deleteEntry(TodoEntry entry) {
//    return delete(todos).delete(entry);
//  }
//
//  Future<int> createCategory(Category category) {
//    return into(categories).insert(category);
//  }
//
//  Future deleteCategory(Category category) {
//    return transaction((t) async {
//      await t.customUpdate(
//        'UPDATE todos SET category = NULL WHERE category = ?',
//        updates: {todos},
//        variables: [Variable.withInt(category.id)],
//      );
//
//      await t.delete(categories).delete(category);
//    });
//  }
}
