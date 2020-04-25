part of 'tables.dart';

// TODO: split out a MonsterSearchDao this is too complicated.

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
  bool favoritesOnly = false;

  bool get modified =>
      mainAttr.isNotEmpty ||
      subAttr.isNotEmpty ||
      rarity.modified ||
      cost.modified ||
      types.isNotEmpty ||
      awokenSkills.isNotEmpty ||
      activeTags.isNotEmpty ||
      leaderTags.isNotEmpty ||
      series != '' ||
      favoritesOnly;
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

    if (args.filter.favoritesOnly) {
      query.where(isIn(monsters.monsterId, Prefs.favoriteMonsters));
    }

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
            if (containsHiragana(searchText)) monsters.nameJp.like(hiraganaToKatakana(searchText)),
            if (containsKatakana(searchText)) monsters.nameJp.like(katakanaToHiragana(searchText)),
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
      var searchText = '%${args.filter.series}%';
      query.where(orList(
        [
          series.nameJp.like(searchText),
          if (containsHiragana(searchText)) series.nameJp.like(hiraganaToKatakana(searchText)),
          if (containsKatakana(searchText)) series.nameJp.like(katakanaToHiragana(searchText)),
          series.nameNa.like(searchText),
          series.nameKr.like(searchText),
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
    var statResult = (await statsAgainstRarity(
        resultMonster.hpMax,
        resultMonster.hpMax,
        resultMonster.atkMax,
        resultMonster.atkMax,
        resultMonster.rcvMax,
        resultMonster.rcvMax,
        statHolder.weighted,
        statHolder.weighted,
        rarityForStats));
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
      prevMonsterResult.length > 0 ? prevMonsterResult.first.monsterId : null,
      nextMonsterResult.length > 0 ? nextMonsterResult.first.monsterId : null,
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
    final seriesMonsters = (await seriesMonsterIds(seriesId)).map((r) => r.monsterId).toList();
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
      var targets = (await targetForTransformation(searchId)).map((v) => v.linkedMonsterId);
      if (targets.isEmpty || results.contains(targets.first)) {
        break;
      }
      results.add(targets.first);
      searchId = targets.first;
    }
    searchId = monsterId;
    while (true) {
      var bases = (await baseForTransformation(searchId)).map((v) => v.monsterId);
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
        if ((await ancestorMonsterId(tId)).isNotEmpty || (await childMonsterId(tId)).isNotEmpty) {
          monsterId = tId;
          break;
        }
      }
    }

    var ancestorId = monsterId;
    while (true) {
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

  Future<Monster> loadMonster(int monsterId) async {
    return await (select(monsters)..where((m) => m.monsterId.equals(monsterId))).getSingle();
  }
}
