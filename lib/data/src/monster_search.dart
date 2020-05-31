part of '../tables.dart';

@json_annotation.JsonSerializable(nullable: false)
class MonsterSortArgs {
  bool sortAsc;

  @json_annotation.JsonKey(fromJson: MonsterSortType.byId, toJson: MonsterSortType.toId)
  MonsterSortType sortType;

  MonsterSortArgs({this.sortAsc = false, MonsterSortType sortType})
      : sortType = sortType ?? MonsterSortType.released;
  factory MonsterSortArgs.fromJson(Map<String, dynamic> json) => _$MonsterSortArgsFromJson(json);
  Map<String, dynamic> toJson() => _$MonsterSortArgsToJson(this);
}

@json_annotation.JsonSerializable(nullable: false)
class MinMax {
  int min;
  int max;

  bool get modified => min != null || max != null;

  MinMax({this.min, this.max});
  factory MinMax.fromJson(Map<String, dynamic> json) => _$MinMaxFromJson(json);
  Map<String, dynamic> toJson() => _$MinMaxToJson(this);
}

@json_annotation.JsonSerializable()
class MonsterFilterArgs {
  Set<int> mainAttr;
  Set<int> subAttr;
  MinMax rarity;
  MinMax cost;
  Set<int> types;
  List<int> awokenSkills;
  bool searchSuperAwakenings;
  String series;
  bool favoritesOnly;

  /// Must contain active_skill_tag_id's
  Set<int> activeTags;

  /// Must contain leader_skill_tag_id's
  Set<int> leaderTags;

  bool get modified =>
      mainAttr.isNotEmpty ||
      subAttr.isNotEmpty ||
      rarity.modified ||
      cost.modified ||
      types.isNotEmpty ||
      awokenSkills.isNotEmpty ||
      searchSuperAwakenings == false ||
      activeTags.isNotEmpty ||
      leaderTags.isNotEmpty ||
      series != '' ||
      favoritesOnly;

  MonsterFilterArgs(
      {Set<int> mainAttr,
      Set<int> subAttr,
      MinMax rarity,
      MinMax cost,
      Set<int> types,
      List<int> awokenSkills,
      this.searchSuperAwakenings = true,
      this.series = '',
      this.favoritesOnly = false,
      Set<int> activeTags,
      Set<int> leaderTags})
      : mainAttr = mainAttr ?? {},
        subAttr = subAttr ?? {},
        rarity = rarity ?? MinMax(),
        cost = cost ?? MinMax(),
        types = types ?? {},
        awokenSkills = awokenSkills ?? [],
        activeTags = activeTags ?? {},
        leaderTags = leaderTags ?? {};

  factory MonsterFilterArgs.fromJson(Map<String, dynamic> json) =>
      _$MonsterFilterArgsFromJson(json);
  Map<String, dynamic> toJson() => _$MonsterFilterArgsToJson(this);
}

@json_annotation.JsonSerializable(explicitToJson: true, nullable: false)
class MonsterSearchArgs {
  final String text;
  final MonsterSortArgs sort;
  final MonsterFilterArgs filter;
  final bool awakeningsRequired;

  bool get shouldRequestAwakenings => awakeningsRequired || filter.awokenSkills.isNotEmpty;

  MonsterSearchArgs.defaults()
      : text = '',
        sort = MonsterSortArgs(),
        filter = MonsterFilterArgs(),
        awakeningsRequired = false;

  MonsterSearchArgs(
      {@required this.text,
      @required this.sort,
      @required this.filter,
      @required this.awakeningsRequired});
  factory MonsterSearchArgs.fromJson(Map<String, dynamic> json) =>
      _$MonsterSearchArgsFromJson(json);
  Map<String, dynamic> toJson() => _$MonsterSearchArgsToJson(this);

  factory MonsterSearchArgs.fromJsonString(String jsonStr) {
    try {
      return MonsterSearchArgs.fromJson(jsonDecode(jsonStr));
    } catch (ex) {
      Fimber.e('failed to decode:', ex: ex);
    }
    return MonsterSearchArgs.defaults();
  }

  String toJsonString() {
    try {
      return jsonEncode(toJson());
    } catch (ex) {
      Fimber.e('failed to encode:', ex: ex);
    }
    return '{}';
  }
}

@UseDao(
  tables: [
    ActiveSkillsForSearch,
    Awakenings,
    LeaderSkillsForSearch,
    Monsters,
    Series,
  ],
  queries: {},
)
class MonsterSearchDao extends DatabaseAccessor<DadGuideDatabase> with _$MonsterSearchDaoMixin {
  MonsterSearchDao(DadGuideDatabase db) : super(db);

  Future<List<ListMonster>> findListMonsters(MonsterSearchArgs args) async {
    Fimber.d('doing list monster lookup');
    var s = Stopwatch()..start();

    var filter = args.filter;
    var sort = args.sort;

    var query = select(monsters).join(_computeJoins(filter, sort));
    query.where(_computeFilters(filter, sort));
    query.orderBy(_computeOrdering(sort));

    // Loading awakenings is currently pretty slow (~1s) so avoid it if possible.
    var monsterAwakenings = await _maybeLoadAwakenings(args.shouldRequestAwakenings);

    // Read each result, optionally check awakenings, and create a ListMonster result.
    var results = <ListMonster>[];
    for (var row in await query.get()) {
      var monster = row.readTable(monsters);
      var active = row.readTable(activeSkillsForSearch);
      // We join against other tables, but they're used for filtering or sorting.

      // Optionally find/compare awakenings.
      var awakeningList = (monsterAwakenings[monster.monsterId] ?? [])
        ..sort((a, b) => a.orderIdx - b.orderIdx);
      if (!isAwakeningMatch(filter, awakeningList)) {
        continue;
      }

      results.add(ListMonster(monster, awakeningList, active));
    }

    Fimber.d('mwa lookup complete in: ${s.elapsed} with result count ${results.length}');
    return results;
  }

  /// Determines which tables we need to join to monsters in order to compute the results.
  /// We minimize the number of tables because it improves performance.
  List<Join> _computeJoins(MonsterFilterArgs filter, MonsterSortArgs sort) {
    var hasLeaderSkillTagFilter = filter.leaderTags.isNotEmpty;

    var hasLeaderSkillSort = [
      MonsterSortType.lsAtk,
      MonsterSortType.lsHp,
      MonsterSortType.lsRcv,
      MonsterSortType.lsShield
    ].contains(sort.sortType);

    var joins = [
      // Join the limited AS table since we only need id, min/max cd, and tags.
      leftOuterJoin(activeSkillsForSearch,
          activeSkillsForSearch.activeSkillId.equalsExp(monsters.activeSkillId)),
    ];

    // Optimization to avoid joining leader table if not necessary.
    if (hasLeaderSkillTagFilter || hasLeaderSkillSort) {
      joins.add(leftOuterJoin(leaderSkillsForSearch,
          leaderSkillsForSearch.leaderSkillId.equalsExp(monsters.leaderSkillId)));
    }

    // Optimization to avoid joining the series table if not necessary.
    if (filter.series != '') {
      joins.add(leftOuterJoin(series, series.seriesId.equalsExp(monsters.seriesId)));
    }

    return joins;
  }

  /// Apply a series of where clauses to the query based on the filter, sort, and search text.
  Expression _computeFilters(MonsterFilterArgs filter, MonsterSortArgs sort) {
    Expression<bool> fullExpr = Constant(true);
    if (filter.favoritesOnly) {
      fullExpr &= monsters.monsterId.isIn(Prefs.favoriteMonsters);
    }

    if (sort.sortType == MonsterSortType.skillTurn) {
      // Special handling; we don't want to sort by monsters with no skill
      fullExpr &= monsters.activeSkillId.isBiggerThanValue(0);
    }

    if (filter.mainAttr.isNotEmpty) {
      fullExpr &= monsters.attribute1Id.isIn(filter.mainAttr);
    }
    if (filter.subAttr.isNotEmpty) {
      fullExpr &= monsters.attribute2Id.isIn(filter.subAttr);
    }
    if (filter.rarity.min != null) {
      fullExpr &= monsters.rarity.isBiggerOrEqualValue(filter.rarity.min);
    }
    if (filter.rarity.max != null) {
      fullExpr &= monsters.rarity.isSmallerOrEqualValue(filter.rarity.max);
    }
    if (filter.cost.min != null) {
      fullExpr &= monsters.cost.isBiggerOrEqualValue(filter.cost.min);
    }
    if (filter.cost.max != null) {
      fullExpr &= monsters.cost.isSmallerOrEqualValue(filter.cost.max);
    }
    if (filter.types.isNotEmpty) {
      fullExpr &= monsters.type1Id.isIn(filter.types) |
          monsters.type2Id.isIn(filter.types) |
          monsters.type3Id.isIn(filter.types);
    }

    if (filter.leaderTags.isNotEmpty) {
      Expression<bool> expr = Constant(false);
      filter.leaderTags.forEach((tag) {
        expr = expr | leaderSkillsForSearch.tags.contains('($tag)');
      });
      fullExpr &= expr;
    }

    if (filter.activeTags.isNotEmpty) {
      Expression<bool> expr = Constant(false);
      filter.activeTags.forEach((tag) {
        expr = expr | activeSkillsForSearch.tags.contains('($tag)');
      });
      fullExpr &= expr;
    }

    var seriesText = filter.series;
    if (seriesText.isNotEmpty) {
      fullExpr &= orList(
        [
          series.nameJp.contains(seriesText),
          if (containsHiragana(seriesText)) series.nameJp.contains(hiraganaToKatakana(seriesText)),
          if (containsKatakana(seriesText)) series.nameJp.contains(katakanaToHiragana(seriesText)),
          series.nameNa.contains(seriesText),
          series.nameKr.contains(seriesText),
        ],
      );
    }

    if (Prefs.hideUnreleasedMonsters) {
      var country = Prefs.gameCountry;
      if (country == Country.jp) {
        fullExpr &= monsters.onJp.equals(true);
      } else if (country == Country.na) {
        fullExpr &= monsters.onNa.equals(true);
      } else if (country == Country.kr) {
        fullExpr &= monsters.onKr.equals(true);
      } else {
        Fimber.e('Unexpected country value: $country');
      }
    }

    return fullExpr;
  }

  /// Creates the sort Expression necessary for the given MonsterSortType.
  Expression simpleOrderExpression(MonsterSortType sortType) {
    // These sorts need special handling.
    if (sortType == MonsterSortType.total) {
      return CustomExpression('hp_max/10 + atk_max/5 + rcv_max/3');
    } else if (sortType == MonsterSortType.limitTotal) {
      return CustomExpression('(hp_max/10 + atk_max/5 + rcv_max/3) * (100 + limit_mult)');
    }

    // These sorts are straight column orderings.
    final mapping = {
      MonsterSortType.released: monsters.regDate,
      MonsterSortType.no: monsters.monsterNoJp,
      MonsterSortType.atk: monsters.atkMax,
      MonsterSortType.hp: monsters.hpMax,
      MonsterSortType.rcv: monsters.rcvMax,
      MonsterSortType.type: monsters.type1Id,
      MonsterSortType.rarity: monsters.rarity,
      MonsterSortType.cost: monsters.cost,
      MonsterSortType.mp: monsters.sellMp,
      MonsterSortType.skillTurn: activeSkillsForSearch.turnMin,
      MonsterSortType.lsHp: leaderSkillsForSearch.maxHp,
      MonsterSortType.lsAtk: leaderSkillsForSearch.maxAtk,
      MonsterSortType.lsRcv: leaderSkillsForSearch.maxRcv,
      MonsterSortType.lsShield: leaderSkillsForSearch.maxShield,
    };
    return mapping[sortType];
  }

  /// Create the list of orderings that should be applied to the results.
  /// This could also have been done in memory, and possibly should be?
  List<OrderingTerm> _computeOrdering(MonsterSortArgs sort) {
    var orderingMode = sort.sortAsc ? OrderingMode.asc : OrderingMode.desc;

    List<OrderingTerm> orderingTerms;

    // Special handling for attribute and subattribute; append extra sorting terms to improve
    // quality of display.
    if (sort.sortType == MonsterSortType.attribute) {
      orderingTerms = [
        OrderingTerm(mode: OrderingMode.asc, expression: monsters.attribute1Id),
        OrderingTerm(mode: OrderingMode.asc, expression: monsters.attribute2Id),
      ];
    } else if (sort.sortType == MonsterSortType.subAttribute) {
      orderingTerms = [
        OrderingTerm(mode: OrderingMode.asc, expression: monsters.attribute2Id),
      ];
    } else {
      orderingTerms = [
        OrderingTerm(mode: orderingMode, expression: simpleOrderExpression(sort.sortType)),
      ];
    }
    // Always subsequently sort by monsterNoJp descending.
    orderingTerms.add(OrderingTerm(mode: orderingMode, expression: monsters.monsterNoJp));

    return orderingTerms;
  }

  /// Loads and organizes awakenings for every monster in the DB (if requested), else an empty map.
  /// This is a performance drain, which is why it is optional. We should add an 'awakenings'
  /// field to monster to eliminate this join.
  Future<Map<int, List<Awakening>>> _maybeLoadAwakenings(bool shouldRequestAwakenings) async {
    var monsterAwakenings = <int, List<Awakening>>{};
    if (!shouldRequestAwakenings) return monsterAwakenings;

    var awakeningResults = [];
    if (shouldRequestAwakenings) {
      awakeningResults = await select(awakenings).get();
    }

    awakeningResults.forEach((a) {
      monsterAwakenings.putIfAbsent(a.monsterId, () => []).add(a);
    });

    return monsterAwakenings;
  }

  /// It's too hard to apply this filter during the query, so once we have the awakenings,
  /// strip the IDs of those awakenings out of a copy of the filter. If the filter is now empty,
  /// it's a good match, otherwise skip this row.
  bool isAwakeningMatch(MonsterFilterArgs filter, List<Awakening> monsterSkills) {
    var filterSkills = filter.awokenSkills;
    if (filterSkills.isEmpty) {
      return true;
    }

    // Copy the filter to avoid mutating it.
    var filterCopy = List.of(filterSkills);
    var regularAwakenings = monsterSkills.where((a) => !a.isSuper).toList();
    var superAwakenings =
        filter.searchSuperAwakenings ? monsterSkills.where((a) => a.isSuper).toList() : [];

    for (var awakening in regularAwakenings) {
      filterCopy.remove(awakening.awokenSkillId);
    }
    for (var awakening in superAwakenings) {
      if (filterCopy.contains(awakening.awokenSkillId)) {
        filterCopy.remove(awakening.awokenSkillId);
        // Only match one super awakening.
        break;
      }
    }

    // If the list of filters is empty, this monster is a match.
    return filterCopy.isEmpty;
  }
}
