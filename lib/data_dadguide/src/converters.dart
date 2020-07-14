part of '../tables.dart';

// These converters convert to/from json but only store the ID.
// It's up to the loading code to replace them as appropriate with the inflated values.

Map<String, dynamic> _keyOnlyMap(String key, Map<String, dynamic> map) => {key: map[key]};
Map<String, dynamic> _keysOnlyMap(List<String> keys, Map<String, dynamic> map) =>
    Map.of(map)..removeWhere((key, value) => !keys.contains(key));

class AwokenSkillConverter
    implements json_annotation.JsonConverter<AwokenSkill, Map<String, dynamic>> {
  const AwokenSkillConverter();
  static const key = 'awokenSkillId';

  @override
  AwokenSkill fromJson(Map<String, dynamic> json) =>
      json == null ? null : AwokenSkill.fromJson(_keyOnlyMap(key, json));

  @override
  Map<String, dynamic> toJson(AwokenSkill o) => o == null ? null : _keyOnlyMap(key, o.toJson());
}

class ActiveSkillConverter
    implements json_annotation.JsonConverter<ActiveSkill, Map<String, dynamic>> {
  const ActiveSkillConverter();
  static const key = 'activeSkillId';

  @override
  ActiveSkill fromJson(Map<String, dynamic> json) =>
      json == null ? null : ActiveSkill.fromJson(_keyOnlyMap(key, json));

  @override
  Map<String, dynamic> toJson(ActiveSkill o) => o == null ? null : _keyOnlyMap(key, o.toJson());
}

class LeaderSkillConverter
    implements json_annotation.JsonConverter<LeaderSkill, Map<String, dynamic>> {
  const LeaderSkillConverter();
  static const key = 'leaderSkillId';

  @override
  LeaderSkill fromJson(Map<String, dynamic> json) =>
      json == null ? null : LeaderSkill.fromJson(_keyOnlyMap(key, json));

  @override
  Map<String, dynamic> toJson(LeaderSkill o) => o == null ? null : _keyOnlyMap(key, o.toJson());
}

class MonsterConverter implements json_annotation.JsonConverter<Monster, Map<String, dynamic>> {
  const MonsterConverter();
  // The 'noXX' are used by the ID selector.
  static const keys = ['monsterId', 'monsterNoJp', 'monsterNoNa', 'monsterNoKr'];

  @override
  Monster fromJson(Map<String, dynamic> json) =>
      json == null ? null : Monster.fromJson(_keysOnlyMap(keys, json));

  @override
  Map<String, dynamic> toJson(Monster o) => o == null ? null : _keysOnlyMap(keys, o.toJson());
}
