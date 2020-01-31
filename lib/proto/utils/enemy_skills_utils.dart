import 'package:dadguide2/proto/enemy_skills/enemy_skills.pb.dart';

Set<int> extractSkillIds(List<BehaviorGroup> levelBehavior) {
  var results = <int>{};
  for (var bg in levelBehavior) {
    results.addAll(_extractSkillIdsFromBehaviorGroup(bg));
  }
  return results;
}

Iterable<int> _extractSkillIdsFromBehaviorGroup(BehaviorGroup bg) {
  var results = <int>{};
  for (var bi in bg.children) {
    results.addAll(_extractSkillIdsFromBehaviorItem(bi));
  }
  return results;
}

Iterable<int> _extractSkillIdsFromBehaviorItem(BehaviorItem bi) {
  if (bi.hasGroup()) {
    return _extractSkillIdsFromBehaviorGroup(bi.group);
  } else {
    return {bi.behavior.enemySkillId};
  }
}

List<BehaviorGroup> pickLevelBehaviors(MonsterBehavior behavior, int atLevel) {
  var behaviorGroups = <BehaviorGroup>[];

  // Find all the behavior options where the level is greater or equal then then encounter level.
  var possibleLevels = behavior.levels.where((lb) => lb.level <= atLevel);

  // Assuming we have at least one level...
  if (possibleLevels.isNotEmpty) {
    // We take the behavior at the highest level that qualified.
    var selectedLevel = possibleLevels.reduce((l, r) => l.level > r.level ? l : r);
    behaviorGroups.addAll(selectedLevel.groups);
  }

  return behaviorGroups;
}
