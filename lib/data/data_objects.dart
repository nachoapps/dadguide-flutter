import 'package:collection/collection.dart';
import 'package:dadguide2/components/enums.dart';
import 'package:dadguide2/data/tables.dart';

/// Partial data displayed in the dungeon list view.
class ListDungeon {
  final Dungeon dungeon;
  final Monster iconMonster;
  final int maxScore;
  final int maxAvgMp;

  ListDungeon(this.dungeon, this.iconMonster, this.maxScore, this.maxAvgMp);
}

/// Data displayed in the monster view that links to a dungeon.
class BasicDungeon {
  final int dungeonId;
  final String nameJp;
  final String nameNa;
  final String nameKr;

  BasicDungeon(this.dungeonId, this.nameJp, this.nameNa, this.nameKr);
}

/// Data displayed in the dungeon view.
class FullDungeon {
  final Dungeon dungeon;
  final List<SubDungeon> subDungeons;
  final FullSubDungeon selectedSubDungeon;

  FullDungeon(this.dungeon, this.subDungeons, this.selectedSubDungeon);
}

/// Data displayed in the dungeon view for the selected subdungeon.
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

/// Series info displayed in the monster view.
class FullSeries {
  final SeriesData series;
  final List<int> members;

  FullSeries(this.series, this.members);
}

/// An encounter row for a battle in a subdungeon stage.
class FullEncounter {
  final Encounter encounter;
  final Monster monster;
  final List<Drop> drops;

  FullEncounter(this.encounter, this.monster, this.drops);
}

/// A list of encounters for a specific stage in a subdungeon.
class Battle {
  final int stage;
  final List<FullEncounter> encounters;

  Battle(this.stage, this.encounters);
}

/// Full monster info displayed in the monster view
class FullMonster {
  final Monster monster;
  final ActiveSkill activeSkill;
  final LeaderSkill leaderSkill;
  final FullSeries fullSeries;
  final List<FullAwakening> _awakenings;
  final int prevMonsterId;
  final int nextMonsterId;
  final List<int> skillUpMonsters;
  final List<FullEvolution> evolutions;
  final Map<int, List<BasicDungeon>> dropLocations;

  FullMonster(
      this.monster,
      this.activeSkill,
      this.leaderSkill,
      this.fullSeries,
      this._awakenings,
      this.prevMonsterId,
      this.nextMonsterId,
      this.skillUpMonsters,
      this.evolutions,
      this.dropLocations);

  List<FullAwakening> get awakenings => _awakenings.where((a) => !a.awakening.isSuper).toList();
  List<FullAwakening> get superAwakenings => _awakenings.where((a) => a.awakening.isSuper).toList();

  MonsterType get type1 => MonsterType.byId(monster.type1Id);
  MonsterType get type2 => MonsterType.byId(monster.type2Id);
  MonsterType get type3 => MonsterType.byId(monster.type3Id);

  Set<KillerLatent> get killers {
    var killers = Set<KillerLatent>();
    killers.addAll(type1.killers);
    killers.addAll(type2?.killers ?? []);
    killers.addAll(type3?.killers ?? []);
    return killers;
  }
}

/// Partial monster info displayed in monster list view.
class ListMonster {
  final Monster monster;
  final List<Awakening> _awakenings;

  ListMonster(this.monster, this._awakenings);

  List<Awakening> get awakenings => _awakenings.where((a) => !a.isSuper).toList();
  List<Awakening> get superAwakenings => _awakenings.where((a) => a.isSuper).toList();

  MonsterType get type1 => MonsterType.byId(monster.type1Id);
  MonsterType get type2 => MonsterType.byId(monster.type2Id);
  MonsterType get type3 => MonsterType.byId(monster.type3Id);
}

/// Evolution data for the monster detail view.
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

  EvolutionType get type => EvolutionType.byId(evolution.evolutionType);
}

/// Awakening plus skill info, for the monster detail view.
class FullAwakening {
  final Awakening awakening;
  final AwokenSkill awokenSkill;

  FullAwakening(this.awakening, this.awokenSkill);

  int get awokenSkillId => awakening.awokenSkillId;
}

/// Event details, for the event list view.
class ListEvent {
  final ScheduleEvent event;
  final Dungeon dungeon;

  final DateTime startTime;
  final DateTime endTime;

  ListEvent(this.event, this.dungeon)
      : startTime = DateTime.fromMillisecondsSinceEpoch(event.startTimestamp * 1000, isUtc: true),
        endTime = DateTime.fromMillisecondsSinceEpoch(event.endTimestamp * 1000, isUtc: true);

  int get iconId => dungeon?.iconId ?? event.iconId ?? 0;

  bool isOpen() {
    var now = DateTime.now();
    return startTime.isBefore(now) && endTime.isAfter(now);
  }

  bool isClosed() {
    var now = DateTime.now();
    return endTime.isBefore(now);
  }

  bool isPending() {
    return !isOpen() && !isClosed();
  }

  int daysUntilClose() {
    var now = DateTime.now();
    return now.difference(endTime).inDays;
  }
}
