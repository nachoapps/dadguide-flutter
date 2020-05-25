import 'dart:convert';

import 'package:dadguide2/components/models/data_objects.dart';
import 'package:dadguide2/components/models/enums.dart';
import 'package:dadguide2/data/tables.dart';
import 'package:json_annotation/json_annotation.dart' as json_annotation;
import 'package:json_annotation/json_annotation.dart';

part 'team_data.g.dart';

@json_annotation.JsonSerializable()
class Team {
  TeamMonster leader;
  TeamMonster sub1;
  TeamMonster sub2;
  TeamMonster sub3;
  TeamMonster sub4;
  TeamMonster friend;

  Team({
    TeamMonster leader,
    TeamMonster sub1,
    TeamMonster sub2,
    TeamMonster sub3,
    TeamMonster sub4,
    TeamMonster friend,
  })  : this.leader = leader ?? TeamMonster(),
        this.sub1 = sub1 ?? TeamMonster(),
        this.sub2 = sub2 ?? TeamMonster(),
        this.sub3 = sub3 ?? TeamMonster(),
        this.sub4 = sub4 ?? TeamMonster(),
        this.friend = friend ?? TeamMonster();

  factory Team.fromJson(Map<String, dynamic> json) => _$TeamFromJson(json);
  Map<String, dynamic> toJson() => _$TeamToJson(this);

  factory Team.fromJsonString(String jsonStr) {
    return Team.fromJson(jsonDecode(jsonStr));
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}

@json_annotation.JsonSerializable()
class TeamMonster {
  TeamAssist assist;
  TeamBase base;

  TeamMonster({this.assist, this.base}) {
    assist ??= TeamAssist();
    base ??= TeamBase();
  }

  factory TeamMonster.fromJson(Map<String, dynamic> json) => _$TeamMonsterFromJson(json);
  Map<String, dynamic> toJson() => _$TeamMonsterToJson(this);
}

@json_annotation.JsonSerializable()
class TeamAssist {
  // Database-set.

  @MonsterConverter()
  Monster monster;
  @ActiveSkillConverter()
  ActiveSkill active;

  // User-set.
  int level;
  bool is297;
  int skillLevel;

  // Database-set dependencies.
  @JsonKey(ignore: true)
  LanguageSelector name;

  @JsonKey(ignore: true)
  IdSelector id;

  TeamAssist({
    // Database-set.
    this.monster,
    this.active,

    // User-set.
    this.level = 1,
    this.is297 = false,
    this.skillLevel = 0,
  }) {
    if (monster != null) {
      // Database-set dependencies
      name = LanguageSelector.nameWithNaOverride(monster);
      id = IdSelector.visibleId(monster);
    }
  }

  bool get hasMonster => monster != null;
  int get monsterId => monster?.monsterId ?? 0;
  bool get canLimitBreak => monster?.limitMult != null;

  void clear() {
    // Monster-dependent items.
    name = null;
    id = null;

    // Database items.
    monster = null;
    active = null;

    // User-set items.
    level = 1;
    is297 = false;
    skillLevel = 0;
  }

  void loadFrom(FullMonster fm) {
    // Just to be safe clear data.
    clear();

    // Set fields from the database.
    monster = fm.monster;
    active = fm.activeSkill;

    // Set dependent fields.
    name = LanguageSelector.nameWithNaOverride(monster);
    id = IdSelector.visibleId(monster);

    // Leave the monster values as the zero'd out defaults, they rarely matter.
  }

  factory TeamAssist.fromJson(Map<String, dynamic> json) => _$TeamAssistFromJson(json);
  Map<String, dynamic> toJson() => _$TeamAssistToJson(this);
}

@json_annotation.JsonSerializable()
class TeamBase {
  // Database-set.
  @MonsterConverter()
  Monster monster;
  @ActiveSkillConverter()
  ActiveSkill active;
  @LeaderSkillConverter()
  LeaderSkill leader;
  @AwokenSkillConverter()
  List<AwokenSkill> awakeningOptions;
  @AwokenSkillConverter()
  List<AwokenSkill> superAwakeningOptions;

  // User-set.
  int level;
  int hpPlus;
  int atkPlus;
  int rcvPlus;
  int skillLevel;
  int awakenings;
  @AwokenSkillConverter()
  AwokenSkill superAwakening;

//  @KillerLatentConverter()
  @JsonKey(ignore: true)
  List<Latent> latents;

  // Database-set dependencies.
  @JsonKey(ignore: true)
  LanguageSelector name;

  @JsonKey(ignore: true)
  IdSelector id;

  TeamBase({
    // Database-set.
    this.monster,
    this.active,
    this.leader,
    this.awakeningOptions,
    this.superAwakeningOptions,
    // User-set.
    this.level = 1,
    this.hpPlus = 0,
    this.atkPlus = 0,
    this.rcvPlus = 0,
    this.skillLevel = 0,
    this.awakenings = 0,
    this.superAwakening,
    this.latents = const [],
  }) {
    if (monster != null) {
      // Database-set dependencies
      name = LanguageSelector.nameWithNaOverride(monster);
      id = IdSelector.visibleId(monster);
    }
  }

  bool get hasMonster => monster != null;
  bool get hasSuperAwakening => superAwakening != null;
  int get monsterId => monster?.monsterId ?? 0;
  bool get is297 => hpPlus == 99 && atkPlus == 99 && rcvPlus == 99;
  bool get hasPluses => hpPlus > 0 || atkPlus > 0 && rcvPlus > 0;
  bool get canLimitBreak => monster?.limitMult != null;
  int get maxLatents => 6; // TODO: need to populate this with 8 if SR

  void clear() {
    // Monster-dependent items.
    name = null;
    id = null;

    // Database items.
    monster = null;
    active = null;
    leader = null;
    awakeningOptions = null;
    superAwakeningOptions = null;

    // User-set items.
    level = 1;
    hpPlus = 0;
    atkPlus = 0;
    rcvPlus = 0;
    skillLevel = 0;
    awakenings = 0;
    superAwakening = null;
    latents = [];
  }

  void loadFrom(FullMonster fm) {
    // Just to be safe clear data.
    clear();

    // Set fields from the database.
    monster = fm.monster;
    leader = fm.leaderSkill;
    active = fm.activeSkill;
    awakeningOptions = fm.awakenings.map((fa) => fa.awokenSkill).toList();
    superAwakeningOptions = fm.superAwakenings.map((fa) => fa.awokenSkill).toList();

    // Set dependent fields.
    name = LanguageSelector.nameWithNaOverride(monster);
    id = IdSelector.visibleId(monster);

    // Default the monster values to hypermax.
    level = monster.level;
    hpPlus = 99;
    atkPlus = 99;
    rcvPlus = 99;
    skillLevel = active != null ? active.turnMax - active.turnMin + 1 : 0;
    awakenings = awakeningOptions.length;
  }

  factory TeamBase.fromJson(Map<String, dynamic> json) => _$TeamBaseFromJson(json);
  Map<String, dynamic> toJson() => _$TeamBaseToJson(this);
}
