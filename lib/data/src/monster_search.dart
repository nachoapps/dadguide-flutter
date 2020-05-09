part of '../tables.dart';

@json_annotation.JsonSerializable(nullable: false)
class MonsterSortArgs {
  bool sortAsc;

  @json_annotation.JsonKey(fromJson: MonsterSortType.byId, toJson: MonsterSortType.toId)
  MonsterSortType sortType;

  MonsterSortArgs({this.sortAsc = false, MonsterSortType sortType})
      : this.sortType = sortType ?? MonsterSortType.released;
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

@json_annotation.JsonSerializable(nullable: false)
class MonsterFilterArgs {
  Set<int> mainAttr;
  Set<int> subAttr;
  MinMax rarity;
  MinMax cost;
  Set<int> types;
  List<int> awokenSkills;
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
      this.series = '',
      this.favoritesOnly = false,
      Set<int> activeTags,
      Set<int> leaderTags})
      : this.mainAttr = mainAttr ?? {},
        this.subAttr = subAttr ?? {},
        this.rarity = rarity ?? MinMax(),
        this.cost = cost ?? MinMax(),
        this.types = types ?? {},
        this.awokenSkills = awokenSkills ?? [],
        this.activeTags = activeTags ?? {},
        this.leaderTags = leaderTags ?? {};

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
    return "{}";
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
    var s = new Stopwatch()..start();

    // Loading awakenings is currently pretty slow (~1s) so avoid it if possible.
    var awakeningResults = [];
    if (args.shouldRequestAwakenings) {
      awakeningResults = await select(awakenings).get();
    }

    var monsterAwakenings = Map<int, List<Awakening>>();
    awakeningResults.forEach((a) {
      monsterAwakenings.putIfAbsent(a.monsterId, () => []).add(a);
    });

    var hasLeaderSkillTagFilter = args.filter.leaderTags.isNotEmpty;
    var hasLeaderSkillSort = [
      MonsterSortType.lsAtk,
      MonsterSortType.lsHp,
      MonsterSortType.lsRcv,
      MonsterSortType.lsShield
    ].contains(args.sort.sortType);

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

    if (args.filter.series != '') {
      joins.add(leftOuterJoin(series, series.seriesId.equalsExp(monsters.seriesId)));
    }
    var query = select(monsters).join(joins);

    if (args.filter.favoritesOnly) {
      query.where(monsters.monsterId.isIn(Prefs.favoriteMonsters));
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
      MonsterSortType.skillTurn: activeSkillsForSearch.turnMin,
      MonsterSortType.lsHp: leaderSkillsForSearch.maxHp,
      MonsterSortType.lsAtk: leaderSkillsForSearch.maxAtk,
      MonsterSortType.lsRcv: leaderSkillsForSearch.maxRcv,
      MonsterSortType.lsShield: leaderSkillsForSearch.maxShield,
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
      ];
    } else if (args.sort.sortType == MonsterSortType.subAttribute) {
      orderingTerms = [
        OrderingTerm(mode: OrderingMode.asc, expression: monsters.attribute2Id),
      ];
    } else {
      orderingTerms = [
        OrderingTerm(mode: orderingMode, expression: orderExpression),
      ];
    }
    // Always subsequently sort by monsterNoJp descending.
    orderingTerms.add(OrderingTerm(mode: orderingMode, expression: monsters.monsterNoJp));

    query.orderBy(orderingTerms);

    if (args.sort.sortType == MonsterSortType.skillTurn) {
      // Special handling; we don't want to sort by monsters with no skill
      query.where(monsters.activeSkillId.isBiggerThanValue(0));
    }

    var filter = args.filter;
    if (filter.mainAttr.isNotEmpty) {
      query.where(monsters.attribute1Id.isIn(filter.mainAttr));
    }
    if (filter.subAttr.isNotEmpty) {
      query.where(monsters.attribute2Id.isIn(filter.subAttr));
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
          monsters.type1Id.isIn(filter.types),
          monsters.type2Id.isIn(filter.types),
          monsters.type3Id.isIn(filter.types),
        ],
      ));
    }

    if (args.text.isNotEmpty) {
      var intValue = int.tryParse(args.text);
      if (intValue != null) {
        query.where(monsters.monsterNoJp.equals(intValue) | monsters.monsterNoNa.equals(intValue));
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
        var searchText = '%($curTag)%';
        var curExpr = leaderSkillsForSearch.tags.like(searchText);
        if (expr == null) {
          expr = curExpr;
        } else {
          expr = expr | curExpr;
        }
      }
      query.where(expr);
    }

    if (args.filter.activeTags.isNotEmpty) {
      var expr;
      for (var curTag in args.filter.activeTags) {
        var searchText = '%($curTag)%';
        var curExpr = activeSkillsForSearch.tags.like(searchText);
        if (expr == null) {
          expr = curExpr;
        } else {
          expr = expr | curExpr;
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
      var as = row.readTable(activeSkillsForSearch);

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
}
