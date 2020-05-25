part of '../tables.dart';

class AwokenSkillConverter<T>
    implements json_annotation.JsonConverter<AwokenSkill, Map<String, dynamic>> {
  const AwokenSkillConverter();

  @override
  AwokenSkill fromJson(Map<String, dynamic> json) =>
      json == null ? null : AwokenSkill.fromJson(json);

  @override
  Map<String, dynamic> toJson(AwokenSkill o) => o == null ? null : o.toJson();
}

class ActiveSkillConverter<T>
    implements json_annotation.JsonConverter<ActiveSkill, Map<String, dynamic>> {
  const ActiveSkillConverter();

  @override
  ActiveSkill fromJson(Map<String, dynamic> json) =>
      json == null ? null : ActiveSkill.fromJson(json);

  @override
  Map<String, dynamic> toJson(ActiveSkill o) => o == null ? null : o.toJson();
}

class LeaderSkillConverter<T>
    implements json_annotation.JsonConverter<LeaderSkill, Map<String, dynamic>> {
  const LeaderSkillConverter();

  @override
  LeaderSkill fromJson(Map<String, dynamic> json) =>
      json == null ? null : LeaderSkill.fromJson(json);

  @override
  Map<String, dynamic> toJson(LeaderSkill o) => o == null ? null : o.toJson();
}

class MonsterConverter<T> implements json_annotation.JsonConverter<Monster, Map<String, dynamic>> {
  const MonsterConverter();

  @override
  Monster fromJson(Map<String, dynamic> json) => json == null ? null : Monster.fromJson(json);

  @override
  Map<String, dynamic> toJson(Monster o) => o == null ? null : o.toJson();
}
