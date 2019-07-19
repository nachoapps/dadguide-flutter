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
    evoMat,
    balanced,
    physical,
    healer,
    dragon,
    god,
    attacker,
    devil,
    machine,
    enhance,
    awoken,
    vendor
  ];

  static final _lookup = Map.fromIterable(all, key: (mt) => mt.id);

  static MonsterType byId(int id) {
    return _lookup[id];
  }
}

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

class Language {
  final int id;
  final String languageName;
  final String languageCode;

  const Language._(this.id, this.languageName, this.languageCode);

  static const Language en = Language._(1, 'English', 'EN');
  static const Language ja = Language._(0, 'Japanese', 'JP');
  static const Language ko = Language._(2, 'Korean', 'KR');

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

class Country {
  final int id;
  final String countryName;
  final String countryCode;

  const Country._(this.id, this.countryName, this.countryCode);

  // TODO: redo id values to start from 1
  static const Country na = Country._(1, 'North America', 'NA');
  static const Country jp = Country._(0, 'Japan', 'JP');
  static const Country kr = Country._(2, 'Korea', 'KR');

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

class ScheduleTabKey {
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
