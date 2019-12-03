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
