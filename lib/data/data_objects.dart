import 'package:collection/collection.dart';
import 'package:dadguide2/components/enums.dart';
import 'package:dadguide2/data/tables.dart';
import 'package:intl/intl.dart';

class ListDungeon {
  final Dungeon dungeon;
  final Monster iconMonster;
  final int maxScore;
  final int maxAvgMp;

  ListDungeon(this.dungeon, this.iconMonster, this.maxScore, this.maxAvgMp);
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
  final List<Battle> battles;

  FullSubDungeon(this.subDungeon, this.encounters) : battles = _computeBattles(encounters);

  FullEncounter get bossEncounter => battles.isEmpty ? null : battles.last.encounters.last;

  String mpText() {
    final mp = subDungeon.mpAvg ?? 0;
    final mpPerStam = (mp / subDungeon.stamina).toStringAsFixed(2);
    return '$mp ($mpPerStam / Stamina';
  }

  List<int> get rewardIconIds => (subDungeon.rewardIconIds ?? '')
      .split(',')
      .where((x) => num.tryParse(x) != null)
      .map((x) => int.parse(x))
      .toList();

  static List<Battle> _computeBattles(List<FullEncounter> encounters) {
    return groupBy(encounters, (x) => x.encounter.stage)
        .entries
        .map((e) => Battle(
            e.key, e.value.toList()..sort((l, r) => l.encounter.orderIdx - r.encounter.orderIdx)))
        .toList()
          ..sort((l, r) => l.stage - r.stage);
  }
}

class FullSeries {
  final SeriesData series;
  final List<int> members;

  FullSeries(this.series, this.members);
}

class FullEncounter {
  final Encounter encounter;
  final Monster monster;
  final List<Drop> drops;

  FullEncounter(this.encounter, this.monster, this.drops);
}

class Battle {
  final int stage;
  final List<FullEncounter> encounters;

  Battle(this.stage, this.encounters);
}

class FullMonster {
  final Monster monster;
  final ActiveSkill activeSkill;
  final LeaderSkill leaderSkill;
  final FullSeries fullSeries;
  final List<Awakening> _awakenings;
  final int prevMonsterId;
  final int nextMonsterId;
  final List<int> skillUpMonsters;
  final List<FullEvolution> evolutions;

  FullMonster(this.monster, this.activeSkill, this.leaderSkill, this.fullSeries, this._awakenings,
      this.prevMonsterId, this.nextMonsterId, this.skillUpMonsters, this.evolutions);

  List<Awakening> get awakenings => _awakenings.where((a) => !a.isSuper).toList();
  List<Awakening> get superAwakenings => _awakenings.where((a) => a.isSuper).toList();

  MonsterType get type1 => monsterTypeFor(monster.type1Id);
  MonsterType get type2 => monsterTypeFor(monster.type2Id);
  MonsterType get type3 => monsterTypeFor(monster.type3Id);

  Set<KillerLatent> get killers {
    var killers = Set<KillerLatent>();
    killers.addAll(type1.killers);
    killers.addAll(type2?.killers ?? []);
    killers.addAll(type3?.killers ?? []);
    return killers;
  }
}

class WithAwakeningsMonster {
  final Monster monster;
  final List<Awakening> _awakenings;

  WithAwakeningsMonster(this.monster, this._awakenings);

  List<Awakening> get awakenings => _awakenings.where((a) => !a.isSuper).toList();
  List<Awakening> get superAwakenings => _awakenings.where((a) => a.isSuper).toList();

  MonsterType get type1 => monsterTypeFor(monster.type1Id);
  MonsterType get type2 => monsterTypeFor(monster.type2Id);
  MonsterType get type3 => monsterTypeFor(monster.type3Id);
}

class FullEvolution {
  final Evolution evolution;
  final Monster fromMonster;
  final Monster toMonster;

  FullEvolution(this.evolution, this.fromMonster, this.toMonster);

  List<int> get evoMatIds {
    List<int> result = [];
    result.add(evolution.mat1Id);
    if (evolution.mat2Id != null) result.add(evolution.mat2Id);
    if (evolution.mat3Id != null) result.add(evolution.mat3Id);
    if (evolution.mat4Id != null) result.add(evolution.mat4Id);
    if (evolution.mat5Id != null) result.add(evolution.mat5Id);
    return result;
  }
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
