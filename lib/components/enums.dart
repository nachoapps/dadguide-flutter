// TODO: needs localization

import 'package:dadguide2/l10n/localizations.dart';

/// Enum class for monster typing.
class MonsterType {
  const MonsterType._(this.id, this.name, this.killers);

  final int id;
  final String name;
  final List<KillerLatent> killers;

  static const MonsterType evoMat = MonsterType._(0, 'Evo Material', []);
  static const MonsterType balanced = MonsterType._(1, 'Balanced', [
    KillerLatent.god,
    KillerLatent.dragon,
    KillerLatent.devil,
    KillerLatent.machine,
    KillerLatent.balanced,
    KillerLatent.attacker,
    KillerLatent.physical,
    KillerLatent.healer,
  ]);
  static const MonsterType physical = MonsterType._(2, 'Physical', [
    KillerLatent.machine,
    KillerLatent.healer,
  ]);
  static const MonsterType healer = MonsterType._(3, 'Healer', [
    KillerLatent.dragon,
    KillerLatent.attacker,
  ]);
  static const MonsterType dragon = MonsterType._(4, 'Dragon', [
    KillerLatent.machine,
    KillerLatent.healer,
  ]);
  static const MonsterType god = MonsterType._(5, 'God', [KillerLatent.devil]);
  static const MonsterType attacker = MonsterType._(6, 'Attacker', [
    KillerLatent.devil,
    KillerLatent.physical,
  ]);
  static const MonsterType devil = MonsterType._(7, 'Devil', [KillerLatent.god]);
  static const MonsterType machine = MonsterType._(8, 'Machine', [
    KillerLatent.god,
    KillerLatent.balanced,
  ]);
  static const MonsterType enhance = MonsterType._(12, 'Enhance', []);
  static const MonsterType awoken = MonsterType._(14, 'Awoken', []);
  static const MonsterType vendor = MonsterType._(15, 'Vendor', []);

  static const List<MonsterType> all = [
    god,
    devil,
    dragon,
    balanced,
    attacker,
    physical,
    healer,
    machine,
    evoMat,
    enhance,
    awoken,
    vendor
  ];

  static final _lookup = Map.fromIterable(all, key: (mt) => mt.id);

  static MonsterType byId(int id) {
    return _lookup[id];
  }
}

/// Enum class for killer latents.
class KillerLatent {
  final int id;
  final String name;

  const KillerLatent._(this.id, this.name);

  static const KillerLatent god = KillerLatent._(20, 'God');
  static const KillerLatent dragon = KillerLatent._(21, 'Dragon');
  static const KillerLatent devil = KillerLatent._(22, 'Devil');
  static const KillerLatent machine = KillerLatent._(23, 'Machine');
  static const KillerLatent balanced = KillerLatent._(24, 'Balanced');
  static const KillerLatent attacker = KillerLatent._(25, 'Attacker');
  static const KillerLatent physical = KillerLatent._(26, 'Physical');
  static const KillerLatent healer = KillerLatent._(27, 'Healer');

  static const List<KillerLatent> all = [
    god,
    dragon,
    devil,
    machine,
    balanced,
    attacker,
    physical,
    healer,
  ];

  static final _lookup = Map.fromIterable(all, key: (k) => k.id);

  static MonsterType byId(int id) {
    return _lookup[id];
  }
}

/// Enum class for languages. This can be used for monster data (only supports 3 languages) but also
/// for UI data (currently only English, eventually JP/KR/CN.
class Language {
  final int id;
  final String languageName;
  final String languageCode;

  const Language._(this.id, this.languageName, this.languageCode);

  static const Language en = Language._(1, 'English', 'en');
  static const Language ja = Language._(0, 'Japanese', 'ja');
  static const Language ko = Language._(2, 'Korean', 'ko');

  static const List<Language> all = [
    en,
    ja,
    ko,
  ];

  static final _lookup = Map.fromIterable(all, key: (k) => k.id);

  static Language byId(int id) {
    return _lookup[id];
  }
}

/// Enum representing the game country. Used to select which version of names to display, as well
/// as which set of events to show.
class Country {
  final int id;
  final String countryName;
  final String countryCode;
  final String iconOnName;
  final String iconOffName;

  const Country._(this.id, this.countryName, this.countryCode, this.iconOnName, this.iconOffName);

  // TODO: redo id values to start from 1
  static const Country na = Country._(1, 'North America', 'NA', 'na_on.png', 'na_off.png');
  static const Country jp = Country._(0, 'Japan', 'JP', 'jp_on.png', 'jp_off.png');
  static const Country kr = Country._(2, 'Korea', 'KR', 'kr_on.png', 'kr_off.png');

  static const List<Country> all = [
    na,
    jp,
    kr,
  ];

  static final _lookup = Map.fromIterable(all, key: (k) => k.id);

  static Country byId(int id) {
    return _lookup[id];
  }
}

/// The starter dragon used to filter guerrilla events.
class StarterDragon {
  final int id;
  final String nameCode;

  const StarterDragon._(this.id, this.nameCode);

  static const StarterDragon red = StarterDragon._(1, 'red');
  static const StarterDragon blue = StarterDragon._(2, 'blue');
  static const StarterDragon green = StarterDragon._(3, 'green');

  static const List<StarterDragon> all = [
    red,
    blue,
    green,
  ];

  static final _lookup = Map.fromIterable(all, key: (k) => k.id);

  static StarterDragon byId(int id) {
    return _lookup[id];
  }
}

/// The tabs on the schedule page
class ScheduleTabKey {
  // TODO: this probably should move to the events package.
  final int id;
  final String nameCode;

  const ScheduleTabKey._(this.id, this.nameCode);

  static const ScheduleTabKey all = ScheduleTabKey._(1, 'schedule_tab_all');
  static const ScheduleTabKey guerrilla = ScheduleTabKey._(2, 'schedule_tab_guerrilla');
  static const ScheduleTabKey special = ScheduleTabKey._(3, 'schedule_tab_special');
  static const ScheduleTabKey news = ScheduleTabKey._(3, 'schedule_tab_news');

  static const List<ScheduleTabKey> allValues = [
    all,
    guerrilla,
    special,
    news,
  ];

  static final _lookup = Map.fromIterable(allValues, key: (k) => k.id);

  static ScheduleTabKey byId(int id) {
    return _lookup[id];
  }
}

/// Possible sub sections in the event list.
class ScheduleSubSection {
  final int id;
  final String name;

  const ScheduleSubSection._(this.id, this.name);

  static const ScheduleSubSection starter_dragons = ScheduleSubSection._(1, 'Starter Dragon');
  static const ScheduleSubSection special = ScheduleSubSection._(2, 'Special');

  static const List<ScheduleSubSection> allValues = [
    starter_dragons,
    special,
  ];

  static final _lookup = Map.fromIterable(allValues, key: (k) => k.id);

  static ScheduleSubSection byId(int id) {
    return _lookup[id];
  }
}

/// The tabs on the dungeon page.
class DungeonTabKey {
  // TODO: This should move to the dungeon package.
  final int id;
  final String nameCode;

  const DungeonTabKey._(this.id, this.nameCode);

  static const DungeonTabKey special = DungeonTabKey._(1, 'dungeon_tab_special');
  static const DungeonTabKey normal = DungeonTabKey._(2, 'dungeon_tab_normal');
  static const DungeonTabKey technical = DungeonTabKey._(3, 'dungeon_tab_technical');
  static const DungeonTabKey multiranking = DungeonTabKey._(3, 'dungeon_tab_multiranking');

  static const List<DungeonTabKey> allValues = [
    special,
    normal,
    technical,
    multiranking,
  ];

  static final _lookup = Map.fromIterable(allValues, key: (k) => k.id);

  static DungeonTabKey byId(int id) {
    return _lookup[id];
  }
}

/// Possible sub sections in the dungeon list. Currently only 'full list' is supported.
class DungeonSubSection {
  final int id;
  final String name;

  const DungeonSubSection._(this.id, this.name);

  static const DungeonSubSection underway_events = DungeonSubSection._(1, 'Underway Events');
  static const DungeonSubSection upcoming_events = DungeonSubSection._(2, 'Upcoming Events');
  static const DungeonSubSection full_list = DungeonSubSection._(3, 'Full List');
  static const DungeonSubSection series = DungeonSubSection._(4, 'Series');

  static const List<DungeonSubSection> allValues = [
    underway_events,
    upcoming_events,
    full_list,
    series,
  ];

  static final _lookup = Map.fromIterable(allValues, key: (k) => k.id);

  static DungeonSubSection byId(int id) {
    return _lookup[id];
  }
}

class DungeonType {
  final int id;

  const DungeonType._(this.id);

  static const DungeonType unknown_value = DungeonType._(-1);
  static const DungeonType normal = DungeonType._(0);
  static const DungeonType special = DungeonType._(1);
  static const DungeonType technical = DungeonType._(2);
  static const DungeonType gift = DungeonType._(3);
  static const DungeonType ranking = DungeonType._(4);
  static const DungeonType deprecated = DungeonType._(5);
  static const DungeonType unused_6 = DungeonType._(6);
  static const DungeonType multiplayer = DungeonType._(7);

  static const List<DungeonType> allValues = [
    normal,
    technical,
    technical,
    gift,
    ranking,
    deprecated,
    unused_6,
    multiplayer,
  ];

  static final _lookup = Map.fromIterable(allValues, key: (k) => k.id);

  static DungeonType byId(int id) {
    return _lookup[id] ?? DungeonType.unknown_value;
  }
}

/// Possible evolution sections.
class EvolutionType {
  final int id;

  const EvolutionType._(this.id);

  static const EvolutionType unknown_value = EvolutionType._(0);
  static const EvolutionType evo = EvolutionType._(1);
  static const EvolutionType reversible = EvolutionType._(2);
  static const EvolutionType non_reversible = EvolutionType._(3);

  static const List<EvolutionType> allValues = [
    evo,
    reversible,
    non_reversible,
  ];

  static final _lookup = Map.fromIterable(allValues, key: (k) => k.id);

  static EvolutionType byId(int id) {
    return _lookup[id] ?? EvolutionType.unknown_value;
  }
}

class MonsterSortType {
  final int id;
  final String Function() _label;

  MonsterSortType._(this.id, this._label);

  String get label => _label();

  static MonsterSortType released = MonsterSortType._(0, () => 'unused');
  static MonsterSortType no = MonsterSortType._(1, localized.monsterSortTypeNumber);
  static MonsterSortType atk = MonsterSortType._(2, localized.monsterSortTypeAtk);
  static MonsterSortType hp = MonsterSortType._(3, localized.monsterSortTypeHp);
  static MonsterSortType rcv = MonsterSortType._(4, localized.monsterSortTypeRcv);
  static MonsterSortType total = MonsterSortType._(5, localized.monsterSortTypeWeighted);
  static MonsterSortType attribute = MonsterSortType._(6, localized.monsterSortTypeAttr);
  static MonsterSortType subAttribute = MonsterSortType._(7, localized.monsterSortTypeSubAttr);
  static MonsterSortType type = MonsterSortType._(8, localized.monsterSortTypeType);
  static MonsterSortType rarity = MonsterSortType._(9, localized.monsterSortTypeRarity);
  static MonsterSortType cost = MonsterSortType._(10, localized.monsterSortTypeCost);
  static MonsterSortType mp = MonsterSortType._(11, localized.monsterSortTypeMp);
  static MonsterSortType skillTurn = MonsterSortType._(12, localized.monsterSortTypeSkillTurn);

  static List<MonsterSortType> allValues = [
//    released,
    no,
    attribute,
    subAttribute,
    atk,
    hp,
    rcv,
//    total,
    type,
    rarity,
    cost,
    mp,
    skillTurn,
  ];

  static final _lookup = Map.fromIterable(allValues, key: (k) => k.id);

  static MonsterSortType byId(int id) {
    return _lookup[id] ?? MonsterSortType.no;
  }
}
