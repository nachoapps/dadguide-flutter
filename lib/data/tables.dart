import 'package:intl/intl.dart';
import 'package:moor_flutter/moor_flutter.dart';

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

class FullDungeon {
  final Dungeon dungeon;
  final List<SubDungeon> subDungeons;
  final FullSubDungeon selectedSubDungeon;

  FullDungeon(this.dungeon, this.subDungeons, this.selectedSubDungeon);
}

class FullSubDungeon {
  final SubDungeon subDungeon;
  final List<FullEncounter> encounters;

  FullSubDungeon(this.subDungeon, this.encounters);

  FullEncounter get bossEncounter => encounters?.first;

  String mpText() {
    final mp = subDungeon.mpAvg;
    final mpPerStam = mp / subDungeon.stamina;
    return '$mp ($mpPerStam / Stamina';
  }
}

class FullEncounter {
  final Encounter encounter;
  final Monster monster;
  final List<Awakening> awakenings;

  FullEncounter(this.encounter, this.monster, this.awakenings);
}

class _PartialEncounter {
  final Encounter encounter;
  final Monster monster;

  _PartialEncounter(this.encounter, this.monster);
}

class FullMonster {
  final Monster monster;
  final ActiveSkill activeSkill;
  final LeaderSkill leaderSkill;
  final SeriesData series;

  FullMonster(this.monster, this.activeSkill, this.leaderSkill, this.series);
}

class FullEvent {
  static final DateFormat longFormat = DateFormat.MMMd().add_jm();
  static final DateFormat shortFormat = DateFormat.jm();

  final ScheduleEvent _event;
  final Dungeon _dungeon;

  final DateTime _startTime;
  final DateTime _endTime;

  FullEvent(this._event, this._dungeon)
      : _startTime = DateTime.fromMillisecondsSinceEpoch(_event.startTimestamp * 1000, isUtc: true),
        _endTime = DateTime.fromMillisecondsSinceEpoch(_event.endTimestamp * 1000, isUtc: true);

  ScheduleEvent get event => _event;

  Dungeon get dungeon => _dungeon;

  String headerText() {
    String text = _dungeon?.nameNa ?? _event.infoNa;
    if (_event.groupName != null) {
      text = '[${event.groupName}] $text';
    }
    return text ?? 'error';
  }

  String underlineText(DateTime displayedDate) {
    String text = '';
    if (!isOpen()) {
      text = _adjDate(displayedDate, _startTime);
    }
    text += ' ~ ';
    text += _adjDate(displayedDate, _endTime);

    int deltaDays = _daysUntilClose();
    if (deltaDays > 0) {
      text += ' [$deltaDays Days]';
    }
    return text;
  }

  int get iconId => _dungeon?.iconId ?? _event.iconId ?? 0;

  DateTime get startTime => _startTime;

  DateTime get endTime => _endTime;

  bool isOpen() {
    var now = DateTime.now();
    return startTime.isBefore(now) && endTime.isAfter(now);
  }

  String _adjDate(DateTime displayedDate, DateTime timeToDisplay) {
    displayedDate = displayedDate.toLocal();
    timeToDisplay = timeToDisplay.toLocal();
    if (displayedDate.day != timeToDisplay.day) {
      return longFormat.format(timeToDisplay);
    } else {
      return shortFormat.format(timeToDisplay);
    }
  }

  int _daysUntilClose() {
    var now = DateTime.now();
    return now.difference(_endTime).inDays;
  }
}

@UseMoor(tables: [
  ActiveSkills,
  Awakenings,
  AwokenSkills,
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
])
class DadGuideDatabase extends _$DadGuideDatabase {
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

  Future<List<Dungeon>> get allDungeons => select(dungeons).get();

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

  Future<FullDungeon> lookupFullDungeon(int dungeonId, [int subDungeonId]) async {
    final dungeonQuery = select(dungeons)..where((d) => d.dungeonId.equals(dungeonId));
    final dungeonItem = (await dungeonQuery.get()).first;

    final subDungeonsQuery = select(subDungeons)..where((sd) => sd.dungeonId.equals(dungeonId));
    var subDungeonList = await subDungeonsQuery.get();

    subDungeonId == subDungeonId ?? subDungeonList.first.subDungeonId;
    var fullSubDungeon = await lookupFullSubDungeon(subDungeonId);

    return FullDungeon(dungeonItem, subDungeonList, fullSubDungeon);
  }

  Future<FullSubDungeon> lookupFullSubDungeon(int subDungeonId) async {
    final subDungeonQuery = select(subDungeons)
      ..where((sd) => sd.subDungeonId.equals(subDungeonId));
    final subDungeonItem = (await subDungeonQuery.get()).first;
    final fullEncountersList = await lookupFullEncounters(subDungeonId);

    return FullSubDungeon(subDungeonItem, fullEncountersList);
  }

  Future<List<FullEncounter>> lookupFullEncounters(int subDungeonId) async {
    final query = (select(encounters).join([
      leftOuterJoin(monsters, monsters.monsterId.equalsExp(encounters.monsterId)),
    ]));

    var partialEncounters = await query.get().then((rows) {
      return rows.map((row) {
        return _PartialEncounter(row.readTable(encounters), row.readTable(monsters));
      });
    });

    return Future.wait(partialEncounters.map((r) async {
      final awakenings = await findAwakenings(r.encounter.monsterId);
      return FullEncounter(r.encounter, r.monster, awakenings);
    }));
  }

  Future<List<Awakening>> findAwakenings(int monsterId) async {
    final query = select(awakenings)..where((a) => a.monsterId.equals(monsterId));
    return (await query.get()).toList();
  }

  Future<List<FullEvent>> fullEvents() {
    final query = (select(schedule).join([
      leftOuterJoin(dungeons, dungeons.dungeonId.equalsExp(schedule.dungeonId)),
    ]));

    return query.get().then((rows) {
      return rows.map((row) {
        return FullEvent(row.readTable(schedule), row.readTable(dungeons));
      }).toList();
    });
  }

  Future<List<ScheduleEvent>> get currentEvents => select(schedule).get();
}
