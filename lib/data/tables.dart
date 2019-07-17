import 'package:fimber/fimber.dart';
import 'package:flutter/foundation.dart';
import 'package:moor_flutter/moor_flutter.dart';

import 'data_objects.dart';

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

  IntColumn get iconId => integer()();

  TextColumn get rewardJp => text().nullable()();

  TextColumn get rewardNa => text().nullable()();

  TextColumn get rewardKr => text().nullable()();

  TextColumn get rewardIconIds => text().nullable()();

  BoolColumn get visible => boolean()();

  IntColumn get tstamp => integer()();
}

class Drops extends Table {
  IntColumn get dropId => integer().autoIncrement()();

  IntColumn get encounterId => integer()();

  IntColumn get monsterId => integer()();

  IntColumn get tstamp => integer()();
}

class Encounters extends Table {
  IntColumn get encounterId => integer().autoIncrement()();

  IntColumn get dungeonId => integer()();

  IntColumn get subDungeonId => integer()();

  IntColumn get enemyId => integer()();

  IntColumn get monsterId => integer()();

  IntColumn get stage => integer()();

  TextColumn get commentJp => text().nullable()();

  TextColumn get commentNa => text().nullable()();

  TextColumn get commentKr => text().nullable()();

  IntColumn get amount => integer().nullable()();

  IntColumn get orderIdx => integer()();

  IntColumn get turns => integer()();

  IntColumn get level => integer()();

  IntColumn get hp => integer()();

  IntColumn get atk => integer()();

  IntColumn get defence => integer()();

  IntColumn get tstamp => integer()();
}

class Evolutions extends Table {
  IntColumn get evolutionId => integer().autoIncrement()();

  IntColumn get evolutionType => integer()();

  IntColumn get fromId => integer()();

  IntColumn get toId => integer()();

  IntColumn get mat1Id => integer().named('mat_1_id')();

  IntColumn get mat2Id => integer().named('mat_2_id').nullable()();

  IntColumn get mat3Id => integer().named('mat_3_id').nullable()();

  IntColumn get mat4Id => integer().named('mat_4_id').nullable()();

  IntColumn get mat5Id => integer().named('mat_5_id').nullable()();

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

  IntColumn get buyMp => integer().nullable()();

  TextColumn get regDate => text()();

  BoolColumn get onJp => boolean()();

  BoolColumn get onNa => boolean()();

  BoolColumn get onKr => boolean()();

  BoolColumn get palEgg => boolean()();

  BoolColumn get remEgg => boolean()();

  IntColumn get seriesId => integer().nullable()();

  TextColumn get nameNaOverride => text().nullable()();

  IntColumn get tstamp => integer()();
}

@DataClassName("ScheduleEvent")
class Schedule extends Table {
  IntColumn get eventId => integer().autoIncrement()();

  IntColumn get serverId => integer()();

  IntColumn get eventTypeId => integer()();

  IntColumn get startTimestamp => integer()();

  IntColumn get endTimestamp => integer()();

  IntColumn get iconId => integer().nullable()();

  TextColumn get groupName => text().nullable()();

  IntColumn get dungeonId => integer().nullable()();

  TextColumn get url => text().nullable()();

  TextColumn get infoJp => text().nullable()();

  TextColumn get infoNa => text().nullable()();

  TextColumn get infoKr => text().nullable()();

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

class SubDungeons extends Table {
  IntColumn get subDungeonId => integer().autoIncrement()();

  IntColumn get dungeonId => integer()();

  TextColumn get nameJp => text()();

  TextColumn get nameNa => text()();

  TextColumn get nameKr => text()();

  TextColumn get rewardJp => text().nullable()();

  TextColumn get rewardNa => text().nullable()();

  TextColumn get rewardKr => text().nullable()();

  TextColumn get rewardIconIds => text().nullable()();

  IntColumn get coinMax => integer().nullable()();

  IntColumn get coinMin => integer().nullable()();

  IntColumn get coinAvg => integer().nullable()();

  IntColumn get expMax => integer().nullable()();

  IntColumn get expMin => integer().nullable()();

  IntColumn get expAvg => integer().nullable()();

  IntColumn get mpAvg => integer().nullable()();

  IntColumn get iconId => integer().nullable()();

  IntColumn get floors => integer()();

  IntColumn get stamina => integer()();

  RealColumn get hpMult => real()();

  RealColumn get atkMult => real()();

  RealColumn get defMult => real()();

  IntColumn get sRank => integer().nullable()();

  TextColumn get rewards => text().nullable()();

  IntColumn get tstamp => integer()();
}

class Timestamps extends Table {
  TextColumn get name => text()();

  IntColumn get tstamp => integer()();

  @override
  Set<Column> get primaryKey => {name};
}

@UseMoor(
  daos: [
    DungeonsDao,
    MonstersDao,
    ScheduleDao,
  ],
  tables: [
    ActiveSkills,
    Awakenings,
    AwokenSkills,
    Drops,
    Dungeons,
    Encounters,
    Evolutions,
    LeaderSkills,
    Monsters,
    Series,
    Schedule,
    SubDungeons,
//  SkillCondition,
    Timestamps,
  ],
  queries: {},
)
class DadGuideDatabase extends _$DadGuideDatabase {
  DadGuideDatabase(String dbPath) : super(FlutterQueryExecutor(path: dbPath, logStatements: false));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(onCreate: (Migrator m) {
      Fimber.i('Initial database creation; skipping onCreate');
      return null;
    });
  }

  Future<int> maxTstamp(TableInfo info) async {
    var result = await customSelect('SELECT MAX(tstamp) AS tstamp from ${info.actualTableName}');
    return result.first.readInt('tstamp');
  }

  Future<void> upsertData<TD extends Table, D extends DataClass>(
      TableInfo<TD, D> info, Insertable<D> entity) async {
    await into(info).insert(entity, orReplace: true);
  }
}

@UseDao(
  tables: [
    Dungeons,
    Schedule,
  ],
)
class ScheduleDao extends DatabaseAccessor<DadGuideDatabase> with _$ScheduleDaoMixin {
  ScheduleDao(DadGuideDatabase db) : super(db);

  Future<List<FullEvent>> fullEvents() {
    var s = new Stopwatch()..start();
    final query = (select(schedule).join([
      leftOuterJoin(dungeons, dungeons.dungeonId.equalsExp(schedule.dungeonId)),
    ]));

    var results = query.get().then((rows) {
      return rows.map((row) {
        return FullEvent(row.readTable(schedule), row.readTable(dungeons));
      }).toList();
    });

    Fimber.d('events lookup complete in: ${s.elapsed}');
    return results;
  }

  Future<List<ScheduleEvent>> get currentEvents => select(schedule).get();
}

@UseDao(
  tables: [
    Awakenings,
    Drops,
    Dungeons,
    Encounters,
    Evolutions,
    Monsters,
    SubDungeons,
  ],
  queries: {
    'mpAndSrankForDungeons':
        'SELECT dungeon_id AS "dungeonId", MAX(mp_avg) AS "mpAvg", MAX(s_rank) AS "sRank" FROM sub_dungeons GROUP BY dungeon_id',
  },
)
class DungeonsDao extends DatabaseAccessor<DadGuideDatabase> with _$DungeonsDaoMixin {
  DungeonsDao(DadGuideDatabase db) : super(db);

  Future<List<ListDungeon>> get allListDungeons async {
    var s = new Stopwatch()..start();
    final query = select(dungeons).join([
      leftOuterJoin(monsters, dungeons.iconId.equalsExp(monsters.monsterId)),
    ]);

    var mpAndSrankResults =
        Map.fromIterable(await mpAndSrankForDungeons(), key: (r) => r.dungeonId);

    var results = await query.get().then((rows) {
      return Future.wait(rows.map((row) async {
        var dungeon = row.readTable(dungeons);
        var iconMonster = row.readTable(monsters);

        var mpAndSrankValue = mpAndSrankResults[dungeon.dungeonId];
        var mpAvgValue = mpAndSrankValue?.mpAvg;
        var sRankValue = mpAndSrankValue?.sRank;

        return ListDungeon(dungeon, iconMonster, sRankValue, mpAvgValue);
      }));
    });

    Fimber.d('list dungeon lookup complete in: ${s.elapsed}');
    return results;
  }

  Future<List<Dungeon>> get allDungeons => select(dungeons).get();

  Future<FullDungeon> lookupFullDungeon(int dungeonId, [int subDungeonId]) async {
    var s = new Stopwatch()..start();
    Fimber.d('doing full dungeon lookup');
    final dungeonQuery = select(dungeons)..where((d) => d.dungeonId.equals(dungeonId));
    final dungeonItem = (await dungeonQuery.get()).first;

    final subDungeonsQuery = select(subDungeons)..where((sd) => sd.dungeonId.equals(dungeonId));
    var subDungeonList = await subDungeonsQuery.get();

    subDungeonId = subDungeonId ?? subDungeonList.first.subDungeonId;
    var fullSubDungeon = await lookupFullSubDungeon(subDungeonId);
    Fimber.d('dungeon lookup complete in: ${s.elapsed}');

    return FullDungeon(dungeonItem, subDungeonList, fullSubDungeon);
  }

  Future<FullSubDungeon> lookupFullSubDungeon(int subDungeonId) async {
    var s = new Stopwatch()..start();
    final subDungeonQuery = select(subDungeons)
      ..where((sd) => sd.subDungeonId.equals(subDungeonId));
    final subDungeonItem = (await subDungeonQuery.get()).first;
    final fullEncountersList = await lookupFullEncounters(subDungeonId);

    Fimber.d('subdungeon lookup complete in: ${s.elapsed}');

    return FullSubDungeon(subDungeonItem, fullEncountersList);
  }

  Future<List<FullEncounter>> lookupFullEncounters(int subDungeonId) async {
    var s = new Stopwatch()..start();
    final query = (select(encounters)..where((sd) => sd.subDungeonId.equals(subDungeonId))).join([
      leftOuterJoin(monsters, monsters.monsterId.equalsExp(encounters.monsterId)),
    ]);

    var results = await query.get().then((rows) {
      return Future.wait(rows.map((row) async {
        var encounter = row.readTable(encounters);
        var monster = row.readTable(monsters);
        var dropList = await findDrops(encounter.encounterId);
        return FullEncounter(encounter, monster, dropList);
      }).toList());
    });

    Fimber.d('encounter lookup complete in: ${s.elapsed}');

    return results;
  }

  Future<List<Drop>> findDrops(int encounterId) async {
    var query = select(drops)
      ..where((d) => d.encounterId.equals(encounterId))
      ..orderBy([(d) => OrderingTerm(expression: d.monsterId)]);
    return (await query.get()).toList();
  }
}

class MonsterSearchArgs {
  String text;

  MonsterSearchArgs({this.text = ''});
}

@UseDao(
  tables: [
    ActiveSkills,
    Awakenings,
    Evolutions,
    LeaderSkills,
    Monsters,
    Series,
  ],
  queries: {
    'mpAndSrankForDungeons':
        'SELECT dungeon_id AS "dungeonId", MAX(mp_avg) AS "mpAvg", MAX(s_rank) AS "sRank" FROM sub_dungeons GROUP BY dungeon_id',
    'prevMonsterId':
        'SELECT MAX(monster_no_jp) AS "monsterId" FROM monsters WHERE monster_no_jp < :monsterId',
    'nextMonsterId':
        'SELECT MIN(monster_no_jp) AS "monsterId" FROM monsters WHERE monster_no_jp > :monsterId',
    'skillUpMonsterIds':
        'SELECT monster_id AS "monsterId" FROM monsters WHERE active_skill_id = :activeSkillId',
    'seriesMonsterIds':
        'SELECT monster_id AS "monsterId" FROM monsters WHERE series_id = :series LIMIT 300',
    'ancestorMonsterId':
        'SELECT from_id as "fromMonsterId" FROM evolutions WHERE to_id = :monsterId',
  },
)
class MonstersDao extends DatabaseAccessor<DadGuideDatabase> with _$MonstersDaoMixin {
  MonstersDao(DadGuideDatabase db) : super(db);

  Future<List<ListMonster>> findListMonsters(MonsterSearchArgs args) async {
    Fimber.d('doing list monster lookup');
    var s = new Stopwatch()..start();

    final awakeningResults = await select(awakenings).get();

    var monsterAwakenings = Map<int, List<Awakening>>();
    awakeningResults.forEach((a) {
      monsterAwakenings.putIfAbsent(a.monsterId, () => []).add(a);
    });

    var query = select(monsters)
      ..orderBy([(m) => OrderingTerm(mode: OrderingMode.desc, expression: m.monsterNoJp)]);

    if (args.text.isNotEmpty) {
      query.where((m) => m.nameNa.like('%${args.text}%'));
    }

    var results = await query.get().then((rows) => rows.map((m) {
          var awakeningList = (monsterAwakenings[m.monsterId] ?? [])
            ..sort((a, b) => a.orderIdx - b.orderIdx);
          return ListMonster(m, awakeningList);
        }).toList());

    Fimber.d('mwa lookup complete in: ${s.elapsed} with result count ${results.length}');

    return results;
  }

  Future<FullMonster> fullMonster(int monsterId) async {
    var s = new Stopwatch()..start();
    final query = (select(monsters)..where((m) => m.monsterId.equals(monsterId))).join([
      leftOuterJoin(activeSkills, activeSkills.activeSkillId.equalsExp(monsters.activeSkillId)),
      leftOuterJoin(leaderSkills, leaderSkills.leaderSkillId.equalsExp(monsters.leaderSkillId)),
      leftOuterJoin(series, series.seriesId.equalsExp(monsters.seriesId)),
    ]);

    final row = await query.getSingle();
    final resultMonster = row.readTable(monsters);
    final resultSeries = await fullSeries(resultMonster.seriesId);

    final awakenings = await findAwakenings(monsterId);
    final prevMonsterResult = await prevMonsterId(monsterId);
    final nextMonsterResult = await nextMonsterId(monsterId);
    final skillUpMonsterIdsResult = resultMonster.activeSkillId == null
        ? []
        : (await skillUpMonsterIds(resultMonster.activeSkillId)).map((x) => x.monsterId).toList();

    final evolutionList = await allEvolutionsForTree(resultMonster.monsterId);

    var fullMonster = FullMonster(
      resultMonster,
      row.readTable(activeSkills),
      row.readTable(leaderSkills),
      resultSeries,
      awakenings,
      prevMonsterResult.length > 0 ? prevMonsterResult.first.monsterId : null,
      nextMonsterResult.length > 0 ? nextMonsterResult.first.monsterId : null,
      skillUpMonsterIdsResult,
      evolutionList,
    );

    Fimber.d('monster lookup complete in: ${s.elapsed}');
    return fullMonster;
  }

  Future<FullSeries> fullSeries(int seriesId) async {
    // TODO: probably make series non-nullable?
    if (seriesId == null) return null;
    final s = new Stopwatch()..start();
    final seriesValue =
        await (select(series)..where((s) => s.seriesId.equals(seriesId))).getSingle();
    final seriesMonsters = (await seriesMonsterIds(seriesId)).map((r) => r.monsterId).toList();
    final result = FullSeries(seriesValue, seriesMonsters);
    Fimber.d('series lookup complete in: ${s.elapsed}');
    return result;
  }

  Future<List<FullEvolution>> allEvolutionsForTree(int monsterId) async {
    var ancestorId = monsterId;
    while (true) {
      print(ancestorId);
      var possibleAncestor = await ancestorMonsterId(ancestorId);
      if (possibleAncestor.isNotEmpty) {
        ancestorId = possibleAncestor.first.fromMonsterId;
      } else {
        break;
      }
    }

    var ancestorMonster =
        await (select(monsters)..where((m) => m.monsterId.equals(ancestorId))).getSingle();

    List<FullEvolution> results = [];
    var toSearch = [ancestorMonster];

    while (toSearch.isNotEmpty) {
      var fromMonster = toSearch.first;
      toSearch.remove(fromMonster);

      final query = (select(evolutions)..where((e) => e.fromId.equals(fromMonster.monsterId)))
          .join([innerJoin(monsters, monsters.monsterId.equalsExp(evolutions.toId))]);

      for (var evoRow in await query.get()) {
        final toMonster = evoRow.readTable(monsters);
        final evolution = evoRow.readTable(evolutions);

        toSearch.add(toMonster);
        results.add(FullEvolution(evolution, fromMonster, toMonster));
      }
    }

    return results;
  }

  Future<List<Awakening>> findAwakenings(int monsterId) async {
    final query = select(awakenings)
      ..where((a) => a.monsterId.equals(monsterId))
      ..orderBy([(a) => OrderingTerm(expression: a.orderIdx)]);
    return (await query.get()).toList();
  }
}
