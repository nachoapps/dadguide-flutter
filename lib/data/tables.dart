import 'dart:convert';

import 'package:dadguide2/components/config/settings_manager.dart';
import 'package:dadguide2/components/models/data_objects.dart';
import 'package:dadguide2/components/models/enums.dart';
import 'package:dadguide2/proto/utils/enemy_skills_utils.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/foundation.dart';
import 'package:moor/src/runtime/expressions/expression.dart'; // ignore: implementation_imports
import 'package:moor_flutter/moor_flutter.dart';

part 'tables.g.dart';

// The first part of this file contains the classes used for database code generation.
//
// Later on is the database definition, and the Event, Monster, and Dungeon DAOs.
// Each DAO also has at least one SearchArg class associated for data lookups.
//
// There's not really any documentation on what is in these fields. For that you should
// either set up your own personal MySQL instance using the export, or you can refer
// to the python data loader.
//
// You need to run `flutter packages pub run build_runner watch` as described in the README.md
// in order to ensure code gen is executed on update.
//
// TODO: would be nice to split this file up a bit, but I couldn't figure out how to do that.

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

  TextColumn get tags => text()();

  IntColumn get tstamp => integer()();
}

/// This class is a hack; for some queries we only care about a subset of columns (the turn min/max
/// and tags) so there's no need to retrieve them.
class ActiveSkillsNoText extends Table {
  IntColumn get activeSkillId => integer().autoIncrement()();

  IntColumn get turnMax => integer()();

  IntColumn get turnMin => integer()();

  TextColumn get tags => text()();

  IntColumn get tstamp => integer()();

  @override
  String get tableName => 'active_skills';
}

class ActiveSkillTags extends Table {
  IntColumn get activeSkillTagId => integer().autoIncrement()();

  TextColumn get nameJp => text()();

  TextColumn get nameNa => text()();

  TextColumn get nameKr => text()();

  IntColumn get orderIdx => integer()();

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

  IntColumn get iconId => integer().nullable()();

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

class EggMachines extends Table {
  IntColumn get eggMachineId => integer().autoIncrement()();

  IntColumn get serverId => integer()();

  IntColumn get eggMachineTypeId => integer()();

  IntColumn get startTimestamp => integer()();

  IntColumn get endTimestamp => integer()();

  IntColumn get machineRow => integer()();

  IntColumn get machineType => integer()();

  TextColumn get name => text()();

  IntColumn get cost => integer()();

  TextColumn get contents => text()();

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

@DataClassName("EnemyDataItem")
class EnemyData extends Table {
  IntColumn get enemyId => integer().autoIncrement()();

  IntColumn get status => integer()();

  BlobColumn get behavior => blob()();

  IntColumn get tstamp => integer()();
}

class EnemySkills extends Table {
  IntColumn get enemySkillId => integer().autoIncrement()();

  TextColumn get nameJp => text()();

  TextColumn get nameNa => text()();

  TextColumn get nameKr => text()();

  TextColumn get descJp => text()();

  TextColumn get descNa => text()();

  TextColumn get descKr => text()();

  IntColumn get minHits => integer()();

  IntColumn get maxHits => integer()();

  IntColumn get atkMult => integer()();

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

class Exchanges extends Table {
  IntColumn get exchangeId => integer().autoIncrement()();

  IntColumn get tradeId => integer()();

  IntColumn get serverId => integer()();

  IntColumn get targetMonsterId => integer()();

  TextColumn get requiredMonsterIds => text()();

  IntColumn get requiredCount => integer()();

  IntColumn get startTimestamp => integer()();

  IntColumn get endTimestamp => integer()();

  BoolColumn get permanent => boolean()();

  IntColumn get menuIdx => integer()();

  IntColumn get orderIdx => integer()();

  IntColumn get flags => integer()();

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

  TextColumn get tags => text()();

  IntColumn get tstamp => integer()();
}

class LeaderSkillTags extends Table {
  IntColumn get leaderSkillTagId => integer().autoIncrement()();

  TextColumn get nameJp => text()();

  TextColumn get nameNa => text()();

  TextColumn get nameKr => text()();

  IntColumn get orderIdx => integer()();

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

  IntColumn get seriesId => integer()();

  BoolColumn get hasAnimation => boolean()();

  BoolColumn get hasHqimage => boolean()();

  IntColumn get orbSkinId => integer().nullable()();

  IntColumn get voiceIdJp => integer().nullable()();

  IntColumn get voiceIdNa => integer().nullable()();

  IntColumn get linkedMonsterId => integer().nullable()();

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

  BoolColumn get technical => boolean()();

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
    EggMachinesDao,
    ExchangesDao,
    MonstersDao,
    ScheduleDao,
  ],
  tables: [
    ActiveSkills,
    ActiveSkillsNoText,
    ActiveSkillTags,
    Awakenings,
    AwokenSkills,
    Drops,
    Dungeons,
    EggMachines,
    Encounters,
    EnemyData,
    EnemySkills,
    Exchanges,
    Evolutions,
    LeaderSkills,
    LeaderSkillTags,
    Monsters,
    Series,
    Schedule,
    SubDungeons,
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

class EventSearchArgs {
  List<Country> servers = Country.all;
  List<StarterDragon> starters = StarterDragon.all;
  ScheduleTabKey tab = ScheduleTabKey.all;
  DateTime dateStart = DateTime.now();
  DateTime dateEnd = DateTime.now().add(Duration(days: 1));
  bool hideClosed = false;

  EventSearchArgs();
  EventSearchArgs.from(
      this.servers, this.starters, this.tab, this.dateStart, this.dateEnd, this.hideClosed);

  List<int> get serverIds => servers.map((c) => c.id).toList();
  List<String> get starterNames => starters.map((s) => s.nameCode).toList();
}

@UseDao(
  tables: [
    Dungeons,
    Schedule,
  ],
)
class ScheduleDao extends DatabaseAccessor<DadGuideDatabase> with _$ScheduleDaoMixin {
  ScheduleDao(DadGuideDatabase db) : super(db);

  Future<List<ListEvent>> findListEvents(EventSearchArgs args) async {
    var s = new Stopwatch()..start();
    final query = (select(schedule).join([
      leftOuterJoin(dungeons, dungeons.dungeonId.equalsExp(schedule.dungeonId)),
    ]));

    if (args.serverIds.isNotEmpty) {
      query.where(isIn(schedule.serverId, args.serverIds));
    }

    int dateStartTimestamp = args.dateStart.millisecondsSinceEpoch ~/ 1000;
    int dateEndTimestamp = args.dateEnd.millisecondsSinceEpoch ~/ 1000;
    var inDateRangePredicate = and(schedule.startTimestamp.isSmallerThanValue(dateEndTimestamp),
        schedule.endTimestamp.isBiggerThanValue(dateStartTimestamp));

    var nowTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    var finalPredicate = args.hideClosed
        ? and(inDateRangePredicate, schedule.endTimestamp.isBiggerThanValue(nowTimestamp))
        : inDateRangePredicate;

    query.where(finalPredicate);

    var results = await query.get().then((rows) {
      return rows.map((row) {
        return ListEvent(row.readTable(schedule), row.readTable(dungeons));
      }).toList();
    });

    results = results.where((e) {
      var groupName = e.event.groupName;
      var isSpecial = groupName == null;
      var passesGroupFilter = isSpecial || args.starterNames.contains(groupName);
      if (args.tab == ScheduleTabKey.all) {
        return passesGroupFilter;
      } else if (args.tab == ScheduleTabKey.special) {
        return isSpecial;
      } else if (args.tab == ScheduleTabKey.guerrilla) {
        return !isSpecial && passesGroupFilter;
      } else {
        return false;
      }
    }).toList();

    Fimber.d('events lookup complete in: ${s.elapsed} with ${results.length} values');
    return results;
  }
}

class DungeonSearchArgs {
  String text;
  List<DungeonType> dungeonTypes;
  var visibleOnly = true;

  DungeonSearchArgs({this.text = '', this.dungeonTypes = const []});

  List<int> get dungeonTypeIds => dungeonTypes.map((dt) => dt.id).toList();
}

@UseDao(
  tables: [
    Awakenings,
    Drops,
    Dungeons,
    Encounters,
    EnemyData,
    EnemySkills,
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

  Future<List<ListDungeon>> findListDungeons(DungeonSearchArgs args) async {
    var s = new Stopwatch()..start();
    final query = select(dungeons).join([
      leftOuterJoin(monsters, dungeons.iconId.equalsExp(monsters.monsterId)),
    ])
      ..orderBy([OrderingTerm(mode: OrderingMode.desc, expression: dungeons.dungeonId)]);

    if (args.visibleOnly) {
      query.where(dungeons.visible.equals(true));
    }

    if (args.text.isNotEmpty) {
      query.where(
        or(
            or(
              dungeons.nameJp.like('%${args.text}%'),
              dungeons.nameNa.like('%${args.text}%'),
            ),
            dungeons.nameKr.like('%${args.text}%')),
      );
    }

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

  Future<FullDungeon> lookupFullDungeon(int dungeonId, [int subDungeonId]) async {
    var s = new Stopwatch()..start();
    Fimber.d('doing full dungeon lookup for $dungeonId / $subDungeonId');
    final dungeonQuery = select(dungeons)..where((d) => d.dungeonId.equals(dungeonId));
    final dungeonItem = (await dungeonQuery.get()).first;

    final subDungeonsQuery = select(subDungeons)..where((sd) => sd.dungeonId.equals(dungeonId));
    var subDungeonList = await subDungeonsQuery.get();
    subDungeonList.sort((l, r) => r.subDungeonId - l.subDungeonId);

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

    // Scan through all the enemy skill ids for the behavior of every encounter and load them.
    var esLibrary = Map<int, EnemySkill>();
    for (var e in fullEncountersList) {
      for (var esId in extractSkillIds(e.levelBehaviors)) {
        if (esLibrary.containsKey(esId)) {
          continue;
        }
        try {
          esLibrary[esId] = await lookupEnemySkill(esId);
        } catch (ex) {
          Fimber.e('Failed to find enemy skill $esId');
        }
      }
    }

    Fimber.d('subdungeon lookup complete in: ${s.elapsed}');

    return FullSubDungeon(subDungeonItem, fullEncountersList, esLibrary);
  }

  Future<List<FullEncounter>> lookupFullEncounters(int subDungeonId) async {
    var s = new Stopwatch()..start();
    final query = (select(encounters)..where((sd) => sd.subDungeonId.equals(subDungeonId))).join([
      leftOuterJoin(monsters, monsters.monsterId.equalsExp(encounters.monsterId)),
      leftOuterJoin(enemyData, enemyData.enemyId.equalsExp(encounters.enemyId)),
    ]);

    var results = await query.get().then((rows) {
      return Future.wait(rows.map((row) async {
        var encounter = row.readTable(encounters);
        var monster = row.readTable(monsters);
        var enemyDataItem = row.readTable(enemyData);
        var dropList = await findDrops(encounter.encounterId);
        return FullEncounter(encounter, monster, enemyDataItem, dropList);
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

  Future<EnemySkill> lookupEnemySkill(int enemySkillId) async {
    var query = select(enemySkills)..where((es) => es.enemySkillId.equals(enemySkillId));
    return await query.getSingle();
  }
}

class MonsterSortArgs {
  bool sortAsc = false;
  MonsterSortType sortType = MonsterSortType.released;
}

class MinMax {
  int min;
  int max;

  bool get modified => min != null || max != null;
}

class MonsterFilterArgs {
  List<int> mainAttr = [];
  List<int> subAttr = [];
  MinMax rarity = MinMax();
  MinMax cost = MinMax();
  List<int> types = [];
  List<int> awokenSkills = [];
  Set<ActiveSkillTag> activeTags = {};
  Set<LeaderSkillTag> leaderTags = {};
  String series = '';

  bool get modified =>
      mainAttr.isNotEmpty ||
      subAttr.isNotEmpty ||
      rarity.modified ||
      cost.modified ||
      types.isNotEmpty ||
      awokenSkills.isNotEmpty ||
      activeTags.isNotEmpty ||
      leaderTags.isNotEmpty ||
      series != '';
}

class MonsterSearchArgs {
  final String text;
  final MonsterSortArgs sort;
  final MonsterFilterArgs filter;
  final bool awakeningsRequired;

  MonsterSearchArgs(
      {@required this.text,
      @required this.sort,
      @required this.filter,
      @required this.awakeningsRequired});

  MonsterSearchArgs.defaults()
      : text = '',
        sort = MonsterSortArgs(),
        filter = MonsterFilterArgs(),
        awakeningsRequired = false;
}

@UseDao(
  tables: [
    ActiveSkills,
    ActiveSkillsNoText,
    ActiveSkillTags,
    Awakenings,
    AwokenSkills,
    Drops,
    Dungeons,
    Encounters,
    Evolutions,
    LeaderSkills,
    LeaderSkillTags,
    Monsters,
    Series,
    SubDungeons,
  ],
  queries: {
    'prevMonsterId':
        'SELECT MAX(monster_no_jp) AS "monsterId" FROM monsters WHERE monster_no_jp < :monsterId',
    'nextMonsterId':
        'SELECT MIN(monster_no_jp) AS "monsterId" FROM monsters WHERE monster_no_jp > :monsterId',
    'skillUpMonsterIds':
        'SELECT monster_id AS "monsterId" FROM monsters WHERE active_skill_id = :activeSkillId',
    'seriesMonsterIds':
        'SELECT monster_id AS "monsterId" FROM monsters WHERE series_id = :series LIMIT 300',
    'ancestorMonsterId':
        'SELECT from_id AS "fromMonsterId" FROM evolutions WHERE to_id = :monsterId',
    'dropDungeons':
        ('SELECT dungeons.dungeon_id AS "dungeonId", name_jp AS "nameJp", name_na AS "nameNa", name_kr AS "nameKr"' +
            ' FROM dungeons' +
            ' INNER JOIN encounters USING (dungeon_id)' +
            ' INNER JOIN drops USING (encounter_id)' +
            ' WHERE drops.monster_id = :monsterId' +
            ' GROUP BY 1, 2, 3, 4'),
    'materialForIds': ('SELECT to_id as "monsterId" FROM evolutions' +
        ' WHERE mat_1_id = :monsterId' +
        ' OR mat_2_id = :monsterId' +
        ' OR mat_3_id = :monsterId' +
        ' OR mat_4_id = :monsterId' +
        ' OR mat_5_id = :monsterId'
            ' GROUP BY 1'),
  },
)
class MonstersDao extends DatabaseAccessor<DadGuideDatabase> with _$MonstersDaoMixin {
  MonstersDao(DadGuideDatabase db) : super(db);

  Future<List<ListMonster>> findListMonsters(MonsterSearchArgs args) async {
    Fimber.d('doing list monster lookup');
    var s = new Stopwatch()..start();

    // Loading awakenings is currently pretty slow (~1s) so avoid it if possible.
    var awakeningResults = [];
    if (args.awakeningsRequired) {
      awakeningResults = await select(awakenings).get();
    }

    var monsterAwakenings = Map<int, List<Awakening>>();
    awakeningResults.forEach((a) {
      monsterAwakenings.putIfAbsent(a.monsterId, () => []).add(a);
    });

    var hasLeaderSkillTagFilter = args.filter.leaderTags.isNotEmpty;

    var joins = [
      // Join the limited AS table since we only need id, min/max cd, and tags.
      leftOuterJoin(
          activeSkillsNoText, activeSkillsNoText.activeSkillId.equalsExp(monsters.activeSkillId)),
    ];

    // Optimization to avoid joining leader table if not necessary.
    if (hasLeaderSkillTagFilter) {
      joins.add(leftOuterJoin(
          leaderSkills, leaderSkills.leaderSkillId.equalsExp(monsters.leaderSkillId)));
    }

    if (args.filter.series != '') {
      joins.add(leftOuterJoin(series, series.seriesId.equalsExp(monsters.seriesId)));
    }
    var query = select(monsters).join(joins);

    var orderingMode = args.sort.sortAsc ? OrderingMode.asc : OrderingMode.desc;
    var orderMapping = {
      MonsterSortType.released: monsters.regDate,
      MonsterSortType.no: monsters.monsterNoJp,
      MonsterSortType.atk: monsters.atkMax,
      MonsterSortType.hp: monsters.hpMax,
      MonsterSortType.rcv: monsters.rcvMax,
      MonsterSortType.type: monsters.type1Id,
      MonsterSortType.rarity: monsters.rarity,
      MonsterSortType.cost: monsters.cost,
      MonsterSortType.mp: monsters.sellMp,
      MonsterSortType.skillTurn: activeSkills.turnMin,
    };
    var orderExpression = orderMapping[args.sort.sortType];
    if (args.sort.sortType == MonsterSortType.total) {
      orderExpression = CustomExpression('hp_max/10 + atk_max/5 + rcv_max/3');
    } else if (args.sort.sortType == MonsterSortType.limitTotal) {
      orderExpression =
          CustomExpression('(hp_max/10 + atk_max/5 + rcv_max/3) * (100 + limit_mult)');
    }

    List<OrderingTerm> orderingTerms;

    // Special handling for attribute and subattribute; append extra sorting terms to improve
    // quality of display.
    if (args.sort.sortType == MonsterSortType.attribute) {
      orderingTerms = [
        OrderingTerm(mode: OrderingMode.asc, expression: monsters.attribute1Id),
        OrderingTerm(mode: OrderingMode.asc, expression: monsters.attribute2Id),
        OrderingTerm(mode: orderingMode, expression: monsters.monsterNoJp),
      ];
    } else if (args.sort.sortType == MonsterSortType.subAttribute) {
      orderingTerms = [
        OrderingTerm(mode: OrderingMode.asc, expression: monsters.attribute2Id),
        OrderingTerm(mode: orderingMode, expression: monsters.monsterNoJp),
      ];
    } else {
      orderingTerms = [OrderingTerm(mode: orderingMode, expression: orderExpression)];
    }

    query.orderBy(orderingTerms);

    if (args.sort.sortType == MonsterSortType.skillTurn) {
      // Special handling; we don't want to sort by monsters with no skill
      query.where(monsters.activeSkillId.isBiggerThanValue(0));
    }

    var filter = args.filter;
    if (filter.mainAttr.isNotEmpty) {
      query.where(isIn(monsters.attribute1Id, filter.mainAttr));
    }
    if (filter.subAttr.isNotEmpty) {
      query.where(isIn(monsters.attribute2Id, filter.subAttr));
    }
    if (filter.rarity.min != null) {
      query.where(monsters.rarity.isBiggerOrEqualValue(filter.rarity.min));
    }
    if (filter.rarity.max != null) {
      query.where(monsters.rarity.isSmallerOrEqualValue(filter.rarity.max));
    }
    if (filter.cost.min != null) {
      query.where(monsters.cost.isBiggerOrEqualValue(filter.cost.min));
    }
    if (filter.cost.max != null) {
      query.where(monsters.cost.isSmallerOrEqualValue(filter.cost.max));
    }
    if (filter.types.isNotEmpty) {
      query.where(orList(
        [
          isIn(monsters.type1Id, filter.types),
          isIn(monsters.type2Id, filter.types),
          isIn(monsters.type3Id, filter.types),
        ],
      ));
    }

    if (args.text.isNotEmpty) {
      var intValue = int.tryParse(args.text);
      if (intValue != null) {
        query.where(or(
          monsters.monsterNoJp.equals(intValue),
          monsters.monsterNoNa.equals(intValue),
        ));
      } else {
        var searchText = '%${args.text}%';
        query.where(orList(
          [
            monsters.nameJp.like(searchText),
            monsters.nameNa.like(searchText),
            monsters.nameNaOverride.like(searchText),
            monsters.nameKr.like(searchText),
          ],
        ));
      }
    }

    if (hasLeaderSkillTagFilter) {
      var expr;
      for (var curTag in args.filter.leaderTags) {
        var searchText = '%(${curTag.leaderSkillTagId})%';
        var curExpr = leaderSkills.tags.like(searchText);
        if (expr == null) {
          expr = curExpr;
        } else {
          expr = or(expr, curExpr);
        }
      }
      query.where(expr);
    }

    if (args.filter.activeTags.isNotEmpty) {
      var expr;
      for (var curTag in args.filter.activeTags) {
        var searchText = '%(${curTag.activeSkillTagId})%';
        var curExpr = activeSkills.tags.like(searchText);
        if (expr == null) {
          expr = curExpr;
        } else {
          expr = or(expr, curExpr);
        }
      }
      query.where(expr);
    }

    if (args.filter.series != '') {
      var seriesText = '%${args.filter.series}%';
      query.where(orList(
        [
          series.nameJp.like(seriesText),
          series.nameNa.like(seriesText),
          series.nameKr.like(seriesText),
        ],
      ));
    }

    if (Prefs.hideUnreleasedMonsters) {
      var country = Prefs.gameCountry;
      if (country == Country.jp) {
        query.where(monsters.onJp.equals(true));
      } else if (country == Country.na) {
        query.where(monsters.onNa.equals(true));
      } else if (country == Country.kr) {
        query.where(monsters.onKr.equals(true));
      } else {
        Fimber.e('Unexpected country value: $country');
      }
    }

    var results = <ListMonster>[];
    for (var row in await query.get()) {
      var m = row.readTable(monsters);
      var as = row.readTable(activeSkills);

      var awakeningList = (monsterAwakenings[m.monsterId] ?? [])
        ..sort((a, b) => a.orderIdx - b.orderIdx);

      // Fix for bug in pipeline; duplicate awakenings
      // TODO: remove me once pipeline is repaired
      var map = <int, Awakening>{};
      for (var r in awakeningList) {
        var item = map[r.orderIdx];
        if (item == null || r.tstamp > item.tstamp) {
          item = r;
        }
        map[item.orderIdx] = r;
      }

      awakeningList = map.values.toList()..sort((l, r) => l.orderIdx - r.orderIdx);

      // It's too hard to apply this filter during the query, so once we have the awakenings,
      // strip the IDs of those awakenings out of a copy of the filter. If the filter is now empty,
      // it's a good match, otherwise skip this row.
      if (filter.awokenSkills.isNotEmpty) {
        var copy = List.of(filter.awokenSkills);
        var regularAwakenings = List.of(awakeningList).where((a) => !a.isSuper);
        var superAwakenings = List.of(awakeningList).where((a) => a.isSuper);

        for (var awakening in regularAwakenings) {
          copy.remove(awakening.awokenSkillId);
        }
        for (var awakening in superAwakenings) {
          if (copy.contains(awakening.awokenSkillId)) {
            copy.remove(awakening.awokenSkillId);
            // Only match one super awakening.
            break;
          }
        }
        if (copy.isNotEmpty) {
          continue;
        }
      }

      results.add(ListMonster(m, awakeningList, as));
    }

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

    var skillUpDungeons = Map<int, List<BasicDungeon>>();
    for (var monsterId in skillUpMonsterIdsResult) {
      var skillUpMonsterDropLocations = await findDropDungeons(monsterId);
      skillUpDungeons[monsterId] = skillUpMonsterDropLocations;
    }

    final evolutionList = await allEvolutionsForTree(resultMonster.monsterId);

    var evoTreeIds = {monsterId};
    for (var e in evolutionList) {
      evoTreeIds.add(e.fromMonster.monsterId);
      evoTreeIds.add(e.toMonster.monsterId);
    }

    var dropLocations = Map<int, List<BasicDungeon>>();
    for (var evoTreeId in evoTreeIds) {
      dropLocations[evoTreeId] = await findDropDungeons(evoTreeId);
    }
    dropLocations.removeWhere((k, v) => v.isEmpty);

    var materialForMonsters = await materialFor(monsterId);

    var fullMonster = FullMonster(
      resultMonster,
      row.readTable(activeSkills),
      row.readTable(leaderSkills),
      resultSeries,
      awakenings,
      prevMonsterResult.length > 0 ? prevMonsterResult.first.monsterId : null,
      nextMonsterResult.length > 0 ? nextMonsterResult.first.monsterId : null,
      skillUpMonsterIdsResult,
      skillUpDungeons,
      evolutionList,
      dropLocations,
      materialForMonsters,
    );

    Fimber.d('monster lookup complete in: ${s.elapsed}');
    return fullMonster;
  }

  Future<FullSeries> fullSeries(int seriesId) async {
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

  Future<List<FullAwakening>> findAwakenings(int monsterId) async {
    final query = (select(awakenings)..where((a) => a.monsterId.equals(monsterId))).join([
      leftOuterJoin(awokenSkills, awokenSkills.awokenSkillId.equalsExp(awakenings.awokenSkillId)),
    ])
      ..orderBy([OrderingTerm(mode: OrderingMode.asc, expression: awakenings.orderIdx)]);

    var results = await query.get().then((rows) {
      return Future.wait(rows.map((row) async {
        var awakening = row.readTable(awakenings);
        var awokenSkill = row.readTable(awokenSkills);
        return FullAwakening(awakening, awokenSkill);
      }));
    });

    // Fix for bug in pipeline; duplicate awakenings
    // TODO: remove me once pipeline is repaired
    var map = <int, FullAwakening>{};
    for (var r in results) {
      var item = map[r.awakening.orderIdx];
      if (item == null || r.awakening.tstamp > item.awakening.tstamp) {
        item = r;
      }

      map[item.awakening.orderIdx] = r;
    }
    var revisedAwakenings = map.values.toList()
      ..sort((l, r) => l.awakening.orderIdx - r.awakening.orderIdx);

    return revisedAwakenings;
  }

  Future<List<BasicDungeon>> findDropDungeons(int monsterId) async {
    var x = await dropDungeons(monsterId);
    return x.map((ddr) => BasicDungeon(ddr.dungeonId, ddr.nameJp, ddr.nameNa, ddr.nameKr)).toList();
  }

  Future<List<AwokenSkill>> allAwokenSkills() async {
    final query = select(awokenSkills)..orderBy([(a) => OrderingTerm(expression: a.awokenSkillId)]);
    return query.get();
  }

  Future<List<ActiveSkillTag>> allActiveSkillTags() async {
    final query = select(activeSkillTags)..orderBy([(a) => OrderingTerm(expression: a.orderIdx)]);
    return query.get();
  }

  Future<List<LeaderSkillTag>> allLeaderSkillTags() async {
    final query = select(leaderSkillTags)..orderBy([(l) => OrderingTerm(expression: l.orderIdx)]);
    return query.get();
  }

  Future<List<int>> materialFor(int materialMonsterId) async {
    var x = await materialForIds(materialMonsterId);
    return x.map((e) => e.monsterId).toList();
  }
}

@UseDao(
  tables: [
    EggMachines,
    Monsters,
  ],
)
class EggMachinesDao extends DatabaseAccessor<DadGuideDatabase> with _$EggMachinesDaoMixin {
  EggMachinesDao(DadGuideDatabase db) : super(db);

  Future<List<FullEggMachine>> findEggMachines() async {
    var s = new Stopwatch()..start();
    final query = select(eggMachines);

    var nowTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    query.where((em) => em.endTimestamp.isBiggerThanValue(nowTimestamp));

    var results = <FullEggMachine>[];
    var queryResults = await query.get();
    for (var em in queryResults) {
      var eggMonsters = <EggMachineMonster>[];
      try {
        var contents = json.decode(em.contents);
        for (var entry in contents.entries) {
          try {
            var monsterIdStr = entry.key as String;
            var rate = entry.value as num;
            var monsterId = int.parse(monsterIdStr.replaceAll(new RegExp(r'\(|\)'), ''));
            var monsterQuery = select(monsters)..where((m) => m.monsterId.equals(monsterId));
            var loadedMonster = await monsterQuery.getSingle();
            eggMonsters.add(EggMachineMonster(loadedMonster, rate.toDouble()));
          } catch (ex) {
            Fimber.e('Failed to parse monster in egg machine $entry', ex: ex);
          }
        }
        results.add(FullEggMachine(em, eggMonsters));
      } catch (ex) {
        Fimber.e('Could not decode egg machine json', ex: ex);
      }
    }

    Fimber.d('egg machine lookup complete in: ${s.elapsed}');
    return results;
  }
}

@UseDao(
  tables: [
    Exchanges,
    Monsters,
  ],
)
class ExchangesDao extends DatabaseAccessor<DadGuideDatabase> with _$ExchangesDaoMixin {
  ExchangesDao(DadGuideDatabase db) : super(db);

  Future<List<FullExchange>> findExchanges() async {
    var s = new Stopwatch()..start();
    final query = select(exchanges);

    var nowTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    query.where(
        (ex) => or(ex.endTimestamp.isBiggerThanValue(nowTimestamp), ex.permanent.equals(true)));

    var results = await query.get();
    Fimber.d('exchange lookup complete in: ${s.elapsed}');
    return results.map((e) => FullExchange(e)).toList();
  }
}

Expression<bool, BoolType> orList(List<Expression<bool, BoolType>> parts) {
  if (parts.isEmpty) {
    Fimber.e('Critical error; tried to OR an empty list');
    return null;
  } else if (parts.length == 1) {
    return parts.first;
  } else {
    return or(parts[0], orList(parts.sublist(1)));
  }
}
