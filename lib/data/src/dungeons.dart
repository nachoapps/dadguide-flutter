part of '../tables.dart';

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
      final searchText = '%${args.text}%';
      query.where(orList(
        [
          dungeons.nameJp.like(searchText),
          if (containsHiragana(searchText)) dungeons.nameJp.like(hiraganaToKatakana(searchText)),
          if (containsKatakana(searchText)) dungeons.nameJp.like(katakanaToHiragana(searchText)),
          dungeons.nameNa.like(searchText),
          dungeons.nameKr.like(searchText),
        ],
      ));
    }

    var mpAndSrankResults =
        Map.fromIterable(await mpAndSrankForDungeons().get(), key: (r) => r.dungeonId);

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
