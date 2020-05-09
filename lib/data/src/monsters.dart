part of '../tables.dart';

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
    LeaderSkillsForSearch,
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
    'childMonsterId': 'SELECT to_id AS "toMonsterId" FROM evolutions WHERE from_id = :monsterId',
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
    'baseForTransformation':
        'SELECT monster_id AS "monsterId" FROM monsters WHERE linked_monster_id = :monsterId',
    'targetForTransformation':
        'SELECT linked_monster_id AS "linkedMonsterId" FROM monsters WHERE monster_id = :monsterId AND linked_monster_id IS NOT NULL',
    // Looks like moor has a bug with multiple named params? Swapped to using ? instead.
    'statsAgainstRarity': '''
      SELECT
        SUM(CASE WHEN hp_max > ? THEN 1 ELSE 0 END) AS "hpGt",
        SUM(CASE WHEN hp_max <= ? THEN 1 ELSE 0 END) AS "hpLt",
        SUM(CASE WHEN atk_max > ? THEN 1 ELSE 0 END) AS "atkGt",
        SUM(CASE WHEN atk_max <= ? THEN 1 ELSE 0 END) AS "atkLt",
        SUM(CASE WHEN rcv_max > ? THEN 1 ELSE 0 END) AS "rcvGt",
        SUM(CASE WHEN rcv_max <= ? THEN 1 ELSE 0 END) AS "rcvLt",
        SUM(CASE WHEN (hp_max/10 + atk_max/5 + rcv_max/3) > ? THEN 1 ELSE 0 END) AS "weightedGt",
        SUM(CASE WHEN (hp_max/10 + atk_max/5 + rcv_max/3) <= ? THEN 1 ELSE 0 END) AS "weightedLt"
      FROM monsters
      WHERE rarity >= ?
      ''',
  },
)
class MonstersDao extends DatabaseAccessor<DadGuideDatabase> with _$MonstersDaoMixin {
  MonstersDao(DadGuideDatabase db) : super(db);

  Future<FullMonster> fullMonster(int monsterId, {int rarityForStats}) async {
    var s = new Stopwatch()..start();
    final query = (select(monsters)..where((m) => m.monsterId.equals(monsterId))).join([
      leftOuterJoin(activeSkills, activeSkills.activeSkillId.equalsExp(monsters.activeSkillId)),
      leftOuterJoin(leaderSkills, leaderSkills.leaderSkillId.equalsExp(monsters.leaderSkillId)),
      leftOuterJoin(series, series.seriesId.equalsExp(monsters.seriesId)),
    ]);

    final row = await query.getSingle();
    final resultMonster = row.readTable(monsters);
    final statHolder = StatHolder.monster(resultMonster);
    final resultSeries = await fullSeries(resultMonster.seriesId);

    final awakenings = await findAwakenings(monsterId);
    final prevMonsterResult = await prevMonsterId(monsterId).get();
    final nextMonsterResult = await nextMonsterId(monsterId).get();
    final skillUpMonsterIdsResult = resultMonster.activeSkillId == null
        ? <int>[]
        : await skillUpMonsterIds(resultMonster.activeSkillId).get();

    var skillUpDungeons = Map<int, List<BasicDungeon>>();
    for (var monsterId in skillUpMonsterIdsResult) {
      var skillUpMonsterDropLocations = await findDropDungeons(monsterId);
      skillUpDungeons[monsterId] = skillUpMonsterDropLocations;
    }

    final evolutionList = await allEvolutionsForTree(monsterId);

    var evoTreeIds = {monsterId};
    for (var e in evolutionList) {
      evoTreeIds.add(e.fromMonster.monsterId);
      evoTreeIds.add(e.toMonster.monsterId);
    }

    final transformationList = await allTransformationsForTree(evoTreeIds);

    var dropLocations = Map<int, List<BasicDungeon>>();
    for (var evoTreeId in evoTreeIds) {
      dropLocations[evoTreeId] = await findDropDungeons(evoTreeId);
    }
    dropLocations.removeWhere((k, v) => v.isEmpty);

    var materialForMonsters = await materialFor(monsterId);

    // We can optionally specify a rarity to search against, used in compare.
    rarityForStats ??= resultMonster.rarity;
    // Cap the rarity at 7, no point in comparing against 10* for example.
    rarityForStats = min(7, rarityForStats);
    var statResult = await statsAgainstRarity(
            resultMonster.hpMax,
            resultMonster.hpMax,
            resultMonster.atkMax,
            resultMonster.atkMax,
            resultMonster.rcvMax,
            resultMonster.rcvMax,
            statHolder.weighted,
            statHolder.weighted,
            rarityForStats)
        .get();
    var stats = statResult.first;

    var statComparison = StatComparison(
      rarityForStats,
      stats.hpGt,
      stats.hpLt,
      stats.atkGt,
      stats.atkLt,
      stats.rcvGt,
      stats.rcvLt,
      stats.weightedGt,
      stats.weightedLt,
    );

    var fullMonster = FullMonster(
      resultMonster,
      statHolder,
      row.readTable(activeSkills),
      row.readTable(leaderSkills),
      resultSeries,
      awakenings,
      prevMonsterResult.length > 0 ? prevMonsterResult.first : null,
      nextMonsterResult.length > 0 ? nextMonsterResult.first : null,
      skillUpMonsterIdsResult,
      skillUpDungeons,
      evolutionList,
      dropLocations,
      materialForMonsters,
      transformationList,
      statComparison,
    );

    Fimber.d('monster lookup complete in: ${s.elapsed}');
    return fullMonster;
  }

  Future<FullSeries> fullSeries(int seriesId) async {
    if (seriesId == null) return null;
    final s = new Stopwatch()..start();
    final seriesValue =
        await (select(series)..where((s) => s.seriesId.equals(seriesId))).getSingle();
    final seriesMonsters = (await seriesMonsterIds(seriesId).get());
    final result = FullSeries(seriesValue, seriesMonsters);
    Fimber.d('series lookup complete in: ${s.elapsed}');
    return result;
  }

  Future<List<Transformation>> allTransformationsForTree(Set<int> monsterIds) async {
    var seenIds = <int>{};
    var idsToSearch = Set.of(monsterIds);
    var results = <Transformation>[];

    while (idsToSearch.isNotEmpty) {
      final nextId = idsToSearch.first;
      idsToSearch.remove(nextId);
      final base = await loadMonster(nextId);

      final linkedMonsterId = base.linkedMonsterId;
      if (linkedMonsterId == null || seenIds.contains(linkedMonsterId)) {
        // Quit if the monster has no link or we've already seen the link.
        continue;
      }

      // Make sure we don't search the link again, but schedule it for sub-searching.
      seenIds.add(linkedMonsterId);
      idsToSearch.add(linkedMonsterId);

      // Then load the actual data and save it.
      final linked = await loadMonster(linkedMonsterId);
      var skill = await (select(activeSkills)
            ..where((as) => as.activeSkillId.equals(base.activeSkillId)))
          .getSingle();
      results.add(Transformation(base, linked, skill));
    }

    results.sort((l, r) => l.fromMonster.monsterId - r.fromMonster.monsterId);
    return results;
  }

  /// Extracts a list of IDs that the given monster transformation line could contain.
  ///
  /// This could go up or down from the monster, and could contain a loop.
  Future<Set<int>> extractTransformations(int monsterId) async {
    var results = <int>{monsterId};
    var searchId = monsterId;
    while (true) {
      var targets = await targetForTransformation(searchId).get();
      if (targets.isEmpty || results.contains(targets.first)) {
        break;
      }
      results.add(targets.first);
      searchId = targets.first;
    }
    searchId = monsterId;
    while (true) {
      var bases = await baseForTransformation(searchId).get();
      if (bases.isEmpty || results.contains(bases.first)) {
        break;
      }
      results.add(bases.first);
      searchId = bases.first;
    }
    return results;
  }

  Future<List<FullEvolution>> allEvolutionsForTree(int monsterId) async {
    // The monster could be a transformation. Find all the possible transformations, and see if
    // any of them contain a child or ancestor evolution.
    var transformations = await extractTransformations(monsterId);
    if (transformations.length > 1) {
      for (var tId in transformations) {
        if ((await ancestorMonsterId(tId).get()).isNotEmpty ||
            (await childMonsterId(tId).get()).isNotEmpty) {
          monsterId = tId;
          break;
        }
      }
    }

    var ancestorId = monsterId;
    while (true) {
      var possibleAncestor = await ancestorMonsterId(ancestorId).get();
      if (possibleAncestor.isNotEmpty) {
        ancestorId = possibleAncestor.first;
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
    var x = await dropDungeons(monsterId).get();
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
    return await materialForIds(materialMonsterId).get();
  }

  Future<Monster> loadMonster(int monsterId) async {
    return await (select(monsters)..where((m) => m.monsterId.equals(monsterId))).getSingle();
  }
}
