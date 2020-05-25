import 'dart:convert';

import 'package:dadguide2/components/models/data_objects.dart';
import 'package:dadguide2/components/models/enums.dart';
import 'package:flutter_fimber/flutter_fimber.dart';
import 'package:json_annotation/json_annotation.dart' as json_annotation;

part 'team_data.g.dart';

@json_annotation.JsonSerializable()
class Team {
  String name;
  TeamMonster leader;
  TeamMonster sub1;
  TeamMonster sub2;
  TeamMonster sub3;
  TeamMonster sub4;
  TeamMonster friend;

  Team(
      {this.name = '',
      TeamMonster leader,
      TeamMonster sub1,
      TeamMonster sub2,
      TeamMonster sub3,
      TeamMonster sub4,
      TeamMonster friend})
      : this.leader = leader ?? TeamMonster(),
        this.sub1 = sub1 ?? TeamMonster(),
        this.sub2 = sub2 ?? TeamMonster(),
        this.sub3 = sub3 ?? TeamMonster(),
        this.sub4 = sub4 ?? TeamMonster(),
        this.friend = friend ?? TeamMonster();

  bool hasName() {
    return (name ?? '').isNotEmpty;
  }

  factory Team.fromJson(Map<String, dynamic> json) => _$TeamFromJson(json);
  Map<String, dynamic> toJson() => _$TeamToJson(this);

  factory Team.fromJsonString(String jsonStr) {
    try {
      return Team.fromJson(jsonDecode(jsonStr));
    } catch (ex) {
      Fimber.e('failed to decode:', ex: ex);
    }
    return Team();
    // TODO: maybe this should return null so we can detect failures?
  }

  String toJsonString() {
    try {
      return jsonEncode(toJson());
    } catch (ex, st) {
      Fimber.e('failed to encode:', ex: ex, stacktrace: st);
    }
    return "{}";
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
  int monsterId;

  int visibleMonsterId;
  String name;

  int level;
  int maxLevel;
  int limitMult;
  Scale hp;
  Scale atk;
  Scale rcv;

  bool is297;
  int skillLevel;
  int maxSkillLevel;

  TeamAssist(
      {this.monsterId,
      this.visibleMonsterId,
      this.name,
      this.level,
      this.maxLevel,
      this.limitMult,
      this.hp,
      this.atk,
      this.rcv,
      this.is297,
      this.skillLevel,
      this.maxSkillLevel}) {
    monsterId ??= 0;
    visibleMonsterId ??= 0;
    name ??= '';
    level ??= 1;
    maxLevel ??= 1;
    limitMult ??= 0;
    hp ??= Scale();
    atk ??= Scale();
    rcv ??= Scale();
    is297 ??= false;
    skillLevel ??= 1;
    maxSkillLevel ??= 1;
  }
  bool get canLimitBreak => limitMult > 0;

  void clear() {
    monsterId = 0;
    visibleMonsterId = 0;
    name = '';
    level = 1;
    maxLevel = 1;
    limitMult = 0;
    hp = Scale();
    atk = Scale();
    rcv = Scale();
    is297 = false;
    skillLevel = 1;
    maxSkillLevel = 1;
  }

  void loadFrom(FullMonster fm) {
    clear();
    var m = fm.monster;
    monsterId = m.monsterId;
    visibleMonsterId = m.monsterId;
    name = fm.name();
    level = m.level;
    maxLevel = m.level;
    limitMult = m.limitMult ?? 0;
    hp = Scale(min: m.hpMin, max: m.hpMax, scale: m.hpScale);
    atk = Scale(min: m.atkMin, max: m.atkMax, scale: m.atkScale);
    rcv = Scale(min: m.rcvMin, max: m.rcvMax, scale: m.rcvScale);
    is297 = true;
    maxSkillLevel = fm.activeSkill != null ? fm.activeSkill.turnMax : 1;
    skillLevel = 1;
  }

  factory TeamAssist.fromJson(Map<String, dynamic> json) => _$TeamAssistFromJson(json);
  Map<String, dynamic> toJson() => _$TeamAssistToJson(this);
}

@json_annotation.JsonSerializable()
class TeamBase {
  int monsterId;

  int visibleMonsterId;
  String name;

  int level;
  int maxLevel;
  int limitMult;
  Scale hp;
  Scale atk;
  Scale rcv;

  int hpPlus;
  int atkPlus;
  int rcvPlus;

  int skillLevel;
  int maxSkillLevel;

  int awakenings;
  @AwakeningEConverter()
  List<AwakeningE> awakeningOptions;

  @AwakeningEConverter()
  AwakeningE superAwakening;
  @AwakeningEConverter()
  List<AwakeningE> superAwakeningOptions;

  @KillerLatentConverter()
  List<Latent> latents;
  int maxLatents;

  TeamBase(
      {this.monsterId,
      this.visibleMonsterId,
      this.name,
      this.level,
      this.maxLevel,
      this.limitMult,
      this.hp,
      this.atk,
      this.rcv,
      this.hpPlus,
      this.atkPlus,
      this.rcvPlus,
      this.skillLevel,
      this.maxSkillLevel,
      this.awakenings,
      this.awakeningOptions,
      this.superAwakening,
      this.superAwakeningOptions,
      this.latents,
      this.maxLatents}) {
    monsterId ??= 0;
    visibleMonsterId ??= 0;
    name ??= '';
    level ??= 1;
    maxLevel ??= 1;
    limitMult ??= 0;
    hp ??= Scale();
    atk ??= Scale();
    rcv ??= Scale();
    hpPlus ??= 0;
    atkPlus ??= 0;
    rcvPlus ??= 0;
    skillLevel ??= 1;
    maxSkillLevel ??= 1;
    awakenings ??= 0;
    awakeningOptions ??= [];
    superAwakeningOptions ??= [];
    latents ??= [];
    maxLatents ??= 8;
  }

  bool get is297 => hpPlus == 99 && atkPlus == 99 && rcvPlus == 99;
  bool get hasPluses => hpPlus > 0 || atkPlus > 0 && rcvPlus > 0;
  bool get canLimitBreak => limitMult > 0;

  void clear() {
    monsterId = 0;
    visibleMonsterId = 0;
    name = '';
    level = 1;
    maxLevel = 1;
    limitMult = 0;
    hp = Scale();
    atk = Scale();
    rcv = Scale();
    hpPlus = 0;
    atkPlus = 0;
    rcvPlus = 0;
    skillLevel = 1;
    maxSkillLevel = 1;
    awakenings = 0;
    awakeningOptions.clear();
    superAwakening = null;
    superAwakeningOptions.clear();
    latents.clear();
    maxLatents = 8;
  }

  void loadFrom(FullMonster fm) {
    clear();
    var m = fm.monster;
    monsterId = m.monsterId;
    name = fm.name();
    level = m.level;
    maxLevel = m.level;
    limitMult = m.limitMult ?? 0;
    hp = Scale(min: m.hpMin, max: m.hpMax, scale: m.hpScale);
    atk = Scale(min: m.atkMin, max: m.atkMax, scale: m.atkScale);
    rcv = Scale(min: m.rcvMin, max: m.rcvMax, scale: m.rcvScale);
    hpPlus = 99;
    atkPlus = 99;
    rcvPlus = 99;
    maxSkillLevel = fm.activeSkill != null ? fm.activeSkill.turnMax : 1;
    skillLevel = maxSkillLevel;
    awakeningOptions.addAll(
        fm.awakenings.map((a) => AwakeningE.byId(a.awokenSkillId)).where((ae) => ae != null));
    awakenings = awakeningOptions.length;
    superAwakeningOptions.addAll(
        fm.superAwakenings.map((a) => AwakeningE.byId(a.awokenSkillId)).where((ae) => ae != null));
    superAwakening = null;
    latents.clear();
    maxLatents = 8;
  }

  factory TeamBase.fromJson(Map<String, dynamic> json) => _$TeamBaseFromJson(json);
  Map<String, dynamic> toJson() => _$TeamBaseToJson(this);
}

@json_annotation.JsonSerializable()
class Scale {
  int min;
  int max;
  double scale;

  Scale({this.min, this.max, this.scale}) {
    min ??= 1;
    max ??= 1;
    scale ??= 1.0;
  }

  factory Scale.fromJson(Map<String, dynamic> json) => _$ScaleFromJson(json);
  Map<String, dynamic> toJson() => _$ScaleToJson(this);
}
