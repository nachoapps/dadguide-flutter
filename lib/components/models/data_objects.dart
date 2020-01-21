import 'package:collection/collection.dart';
import 'package:dadguide2/components/config/settings_manager.dart';
import 'package:dadguide2/components/models/enums.dart';
import 'package:dadguide2/data/database.dart';
import 'package:dadguide2/data/tables.dart';
import 'package:dadguide2/proto/enemy_skills/enemy_skills.pb.dart';
import 'package:dadguide2/proto/utils/enemy_skills_utils.dart';
import 'package:flutter_fimber/flutter_fimber.dart';

class LanguageSelector {
  static LanguageSelector empty() {
    return LanguageSelector(null, null, null);
  }

  static LanguageSelector name(dynamic v) {
    return LanguageSelector(v.nameJp, v.nameNa, v.nameKr);
  }

  static LanguageSelector nameWithNaOverride(dynamic v) {
    return LanguageSelector(v.nameJp, v.nameNaOverride ?? v.nameNa, v.nameKr);
  }

  static LanguageSelector desc(dynamic v) {
    return LanguageSelector(v.descJp, v.descNa, v.descKr);
  }

  final String _jp;
  final String _na;
  final String _kr;

  LanguageSelector(this._jp, this._na, this._kr);

  String call() {
    var infoLanguage = Prefs.infoLanguage;
    if (infoLanguage == Language.ja) {
      return _jp;
    } else if (infoLanguage == Language.en) {
      return _na;
    } else if (infoLanguage == Language.ko) {
      return _kr;
    } else {
      Fimber.e('Unexpected language: $infoLanguage');
      return _na;
    }
  }
}

/// Partial data displayed in the dungeon list view.
class ListDungeon {
  final Dungeon dungeon;
  final Monster iconMonster;
  final int maxScore;
  final int maxAvgMp;

  final LanguageSelector name;

  ListDungeon(this.dungeon, this.iconMonster, this.maxScore, this.maxAvgMp)
      : name = LanguageSelector.name(dungeon);
}

/// Data displayed in the monster view that links to a dungeon.
class BasicDungeon {
  final int dungeonId;
  final String nameJp;
  final String nameNa;
  final String nameKr;

  LanguageSelector name;

  BasicDungeon(this.dungeonId, this.nameJp, this.nameNa, this.nameKr) {
    name = LanguageSelector.name(this);
  }
}

/// Data displayed in the dungeon view.
class FullDungeon {
  final Dungeon dungeon;
  final List<SubDungeon> subDungeons;
  final FullSubDungeon selectedSubDungeon;

  final LanguageSelector name;

  FullDungeon(this.dungeon, this.subDungeons, this.selectedSubDungeon)
      : name = LanguageSelector.name(dungeon);
}

/// Data displayed in the dungeon view for the selected subdungeon.
class FullSubDungeon {
  final SubDungeon subDungeon;
  final List<FullEncounter> encounters;
  final List<Battle> battles;
  final Map<int, EnemySkill> esLibrary;

  final LanguageSelector name;

  FullSubDungeon(this.subDungeon, this.encounters, this.esLibrary)
      : battles = _computeBattles(encounters),
        name = LanguageSelector.name(subDungeon);

  FullEncounter get bossEncounter => battles.isEmpty ? null : battles.last.encounters.last;

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

  final LanguageSelector name;

  FullSeries(this.series, this.members) : name = LanguageSelector.name(series);
}

MonsterBehavior parseBehavior(EnemyDataItem item) {
  var behavior = MonsterBehavior();
  if (item != null) {
    behavior.mergeFromBuffer(item.behavior);
  }
  return behavior;
}

/// An encounter row for a battle in a subdungeon stage.
class FullEncounter {
  final Encounter encounter;
  final Monster monster;
  final List<Drop> drops;

  final MonsterBehavior behavior;
  final LanguageSelector name;

  FullEncounter(this.encounter, this.monster, EnemyDataItem enemyDataItem, this.drops)
      : behavior = parseBehavior(enemyDataItem),
        name = LanguageSelector.nameWithNaOverride(monster);

  bool get approved => behavior.approved;

  List<BehaviorGroup> get levelBehaviors => pickLevelBehaviors(behavior, encounter.level);
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
  final Map<int, List<BasicDungeon>> skillUpDungeons;
  final List<FullEvolution> evolutions;
  final Map<int, List<BasicDungeon>> dropLocations;
  final List<int> materialForMonsters;

  final LanguageSelector name;

  FullMonster(
      this.monster,
      this.activeSkill,
      this.leaderSkill,
      this.fullSeries,
      this._awakenings,
      this.prevMonsterId,
      this.nextMonsterId,
      this.skillUpMonsters,
      this.skillUpDungeons,
      this.evolutions,
      this.dropLocations,
      this.materialForMonsters)
      : name = LanguageSelector.nameWithNaOverride(monster);

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

  FullAwakening get equipSkill =>
      _awakenings.firstWhere((a) => a.awokenSkillId == 49, orElse: () => null);
}

/// Partial monster info displayed in monster list view.
class ListMonster {
  final Monster monster;
  final List<Awakening> _awakenings;
  final ActiveSkill activeSkill;

  final LanguageSelector name;

  ListMonster(this.monster, this._awakenings, this.activeSkill)
      : name = LanguageSelector.nameWithNaOverride(monster);

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

  final LanguageSelector name;
  final LanguageSelector desc;

  FullAwakening(this.awakening, this.awokenSkill)
      : name = LanguageSelector.name(awokenSkill),
        desc = LanguageSelector.desc(awokenSkill);

  int get awokenSkillId => awakening.awokenSkillId;
}

/// Event details, for the event list view.
class ListEvent {
  final ScheduleEvent event;
  final Dungeon dungeon;

  final LanguageSelector dungeonName;
  final LanguageSelector eventInfo;

  final TimedEvent timedEvent;

  ListEvent(this.event, this.dungeon)
      : dungeonName = dungeon == null ? LanguageSelector.empty() : LanguageSelector.name(dungeon),
        eventInfo = LanguageSelector(event.infoJp, event.infoNa, event.infoKr),
        timedEvent = TimedEvent(event.startTimestamp, event.endTimestamp);

  int get iconId => dungeon?.iconId ?? event.iconId ?? 0;
}

class FullActiveSkill {
  final ActiveSkill skill;
  final LanguageSelector name;
  final LanguageSelector desc;

  FullActiveSkill(this.skill)
      : name = LanguageSelector.name(skill),
        desc = LanguageSelector.desc(skill);

  List<ActiveSkillTag> get tags {
    var tagItems = skill.tags.split(',').map((v) => v.replaceAll(RegExp('[()]'), ''));
    var asMap = Map.fromIterable(DatabaseHelper.allActiveSkillTags, key: (i) => i.activeSkillTagId);
    return [
      for (var tag in tagItems) asMap[int.tryParse(tag)],
    ]..removeWhere((v) => v == null);
  }
}

class FullLeaderSkill {
  final LeaderSkill skill;
  final LanguageSelector name;
  final LanguageSelector desc;

  FullLeaderSkill(this.skill)
      : name = LanguageSelector.name(skill),
        desc = LanguageSelector.desc(skill);

  List<LeaderSkillTag> get tags {
    var tagItems = skill.tags.split(',').map((v) => v.replaceAll(RegExp('[()]'), ''));
    var lsMap = Map.fromIterable(DatabaseHelper.allLeaderSkillTags, key: (i) => i.leaderSkillTagId);
    return [
      for (var tag in tagItems) lsMap[int.tryParse(tag)],
    ]..removeWhere((v) => v == null);
  }
}
