import 'package:dadguide2/data/tables.dart';
import 'package:dadguide2/proto/enemy_skills/enemy_skills.pb.dart';
import 'package:dadguide2/theme/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

/// A collection of the enemy skill data by ID for a dungeon. Needs to be provided above the tree
/// that contains any encounter behavior widgets.
class EnemySkillLibrary {
  final Map<int, EnemySkill> data;

  EnemySkillLibrary(this.data);
}

/// Top-level container for monster behavior. Displays a red warning sign if monster data has not
/// been reviewed yet, then a list of BehaviorGroups.
///
/// TODO: Top level groups should probably be encased in an outline with the group type called out.
/// TODO: Make the warning link to an explanation.
class EncounterBehavior extends StatelessWidget {
  final bool approved;
  final List<BehaviorGroup> groups;

  EncounterBehavior(this.approved, this.groups);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!approved)
          Container(
            padding: EdgeInsets.all(4),
            decoration: ShapeDecoration(
              color: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
                'Monster data has not been reviewed and approved yet. Rely on this at your own risk.'),
          ),
        for (var group in groups) BehaviorGroupWidget(group),
      ],
    );
  }
}

/// A group of behavior, containing a list of child groups or individual behaviors.
class BehaviorGroupWidget extends StatelessWidget {
  final BehaviorGroup group;

  BehaviorGroupWidget(this.group);

  @override
  Widget build(BuildContext context) {
    var groupType = group.groupType;
    var groupName = '';
    if (groupType != BehaviorGroup_GroupType.UNSPECIFIED) {
      groupName = groupType.name.toLowerCase();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (groupName.isNotEmpty) Text('Group Type: $groupName'),
        for (var child in group.children)
          Padding(padding: EdgeInsets.only(left: 4), child: BehaviorItemWidget(child)),
      ],
    );
  }
}

/// An individual child, containing either a nested group or a single behavior.
class BehaviorItemWidget extends StatelessWidget {
  final BehaviorItem child;

  BehaviorItemWidget(this.child);

  @override
  Widget build(BuildContext context) {
    if (child.hasGroup()) {
      return BehaviorGroupWidget(child.group);
    } else {
      return BehaviorWidget(child.behavior);
    }
  }
}

/// An individual behavior.
class BehaviorWidget extends StatelessWidget {
  final Behavior behavior;

  BehaviorWidget(this.behavior);

  @override
  Widget build(BuildContext context) {
    var library = Provider.of<EnemySkillLibrary>(context);
    var skill = library.data[behavior.enemySkillId];

    var condition = behavior.condition;
    var conditionParts = [];
    if (condition.hpThreshold != 100) {
      conditionParts.add('HP <= ${condition.hpThreshold}');
    }
    if (condition.useChance != 100) {
      conditionParts.add('Use chance ${condition.useChance}%');
    }
    var conditionStr = conditionParts.join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (conditionStr.isNotEmpty) Text(conditionStr),
        Text(skill.nameNa, style: subtitle(context)),
        Text(skill.descNa, style: secondary(context)),
      ],
    );
  }
}
