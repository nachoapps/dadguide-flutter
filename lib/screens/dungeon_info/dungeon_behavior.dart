import 'package:dadguide2/components/formatting.dart';
import 'package:dadguide2/data/data_objects.dart';
import 'package:dadguide2/data/tables.dart';
import 'package:dadguide2/proto/enemy_skills/enemy_skills.pb.dart';
import 'package:dadguide2/theme/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:strings/strings.dart';
import 'package:url_launcher/url_launcher.dart';

class BehaviorWidgetInputs {
  final int atk;
  final Map<int, EnemySkill> esLibrary;

  BehaviorWidgetInputs(this.atk, this.esLibrary);
}

/// Top-level container for monster behavior. Displays a red warning sign if monster data has not
/// been reviewed yet, then a list of BehaviorGroups.
///
/// TODO: Top level groups should probably be encased in an outline with the group type called out.
/// TODO: Make the warning link to an explanation.
class EncounterBehavior extends StatelessWidget {
  static const warningText =
      'This monster\'s behavior not yet reviewed. Rely on it at your own risk.';
  static const textLink =
      'https://docs.google.com/document/d/10L1HSYg5ZNZocvTFUarg20rGyTEylJze5GHOEK3YLUA/edit#heading=h.s5qhmnr5fy53';

  final bool approved;
  final List<BehaviorGroup> groups;

  EncounterBehavior(this.approved, this.groups);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!approved)
            Container(
              padding: EdgeInsets.all(4),
              decoration: ShapeDecoration(
                color: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: InkWell(
                onTap: () => launch(textLink, forceWebView: true),
                child: Row(
                  children: [
                    Icon(Icons.open_in_new),
                    SizedBox(width: 8),
                    Flexible(child: Center(child: Text(warningText))),
                  ],
                ),
              ),
            ),
          for (var group in groups) BehaviorGroupWidget(true, group),
        ],
      ),
    );
  }
}

/// A group of behavior, containing a list of child groups or individual behaviors.
class BehaviorGroupWidget extends StatelessWidget {
  final bool forceType;
  final BehaviorGroup group;

  BehaviorGroupWidget(this.forceType, this.group);

  @override
  Widget build(BuildContext context) {
    var inputs = Provider.of<BehaviorWidgetInputs>(context);

    var contents = ListView.builder(
      shrinkWrap: true,
      itemCount: group.children.length,
      itemBuilder: (ctx, idx) => Padding(
          padding: EdgeInsets.only(left: 4, right: 4),
          child: BehaviorItemWidget(group.children[idx])),
    );

    var showType = forceType ||
        [BehaviorGroup_GroupType.MONSTER_STATUS, BehaviorGroup_GroupType.DISPEL_PLAYER]
            .contains(group.groupType);
    var conditionText = formatCondition(group.condition, inputs.esLibrary);

    if (showType) {
      return TextBorder(text: convertGroup(group.groupType, group.condition), child: contents);
    } else if (conditionText.isNotEmpty) {
      return TextBorder(text: conditionText, child: contents);
    } else {
      return contents;
    }
  }
}

/// An individual child, containing either a nested group or a single behavior.
class BehaviorItemWidget extends StatelessWidget {
  final BehaviorItem child;

  BehaviorItemWidget(this.child);

  @override
  Widget build(BuildContext context) {
    if (child.hasGroup()) {
      return BehaviorGroupWidget(false, child.group);
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
    var inputs = Provider.of<BehaviorWidgetInputs>(context);
    var skill = inputs.esLibrary[behavior.enemySkillId];

    var nameText = LanguageSelector.name(skill).call();
    var descText = LanguageSelector.desc(skill).call();
    var conditionText = formatCondition(behavior.condition, inputs.esLibrary);
    if (conditionText.isNotEmpty) {
      descText = '$descText ($conditionText)';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(nameText, style: caption(context)),
        if (descText.isNotEmpty) Text(descText),
        if (skill.minHits > 0) Text(formatAttack(skill, inputs.atk), style: secondary(context)),
      ],
    );
  }
}

class TextBorder extends StatelessWidget {
  final String text;
  final Widget child;

  const TextBorder({@required this.text, @required this.child, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          child: child,
          // This margin forces the border down so the text can overlay it.
          margin: EdgeInsets.only(top: 10),
          // Force the contents down so the title doesn't overlap it. Pad the bottom by the same
          // amount to make it symmetric.
          padding: EdgeInsets.only(top: 10, bottom: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).primaryColor.withOpacity(.4), width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Positioned(
            left: 20,
            top: 0,
            child: Container(
              // This padding enforces a slight gap left and right of the text
              padding: EdgeInsets.only(left: 10, right: 10),
              // Make the text container hide the border.
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Text(text),
            )),
      ],
    );
  }
}

String convertGroup(BehaviorGroup_GroupType groupType, Condition cond) {
  switch (groupType) {
    case BehaviorGroup_GroupType.DEATH:
      return 'On Death';
    case BehaviorGroup_GroupType.DISPEL_PLAYER:
      return 'When player has buff';
    case BehaviorGroup_GroupType.MONSTER_STATUS:
      return 'When monster delayed/poisoned';
    case BehaviorGroup_GroupType.PASSIVE:
      return 'Base abilities';
    case BehaviorGroup_GroupType.PREEMPT:
      return 'Preemptive';
    case BehaviorGroup_GroupType.REMAINING:
      var condStr = formatCondition(cond, {});
      return condStr.isEmpty ? 'Error' : condStr;
    case BehaviorGroup_GroupType.STANDARD:
      var condStr = formatCondition(cond, {});
      return condStr.isEmpty ? 'Standard' : condStr;
    case BehaviorGroup_GroupType.UNKNOWN_USE:
      return 'Unknown usage';
  }
  return 'Unknown';
}

String formatCondition(Condition cond, Map<int, EnemySkill> esLibrary) {
  var parts = <String>[];

  if (![0, 100].contains(cond.useChance)) {
    parts.add('${cond.useChance}% chance');
  }

  if (cond.hasLimitedExecution()) {
    parts.add('At most ${cond.limitedExecution} times');
  } else if (cond.globalOneTime) {
    parts.add('One time only');
  }

  if (cond.triggerEnemiesRemaining == 1) {
    parts.add('When alone');
  } else if (cond.triggerEnemiesRemaining > 1) {
    parts.add('When <=${cond.triggerEnemiesRemaining} enemies');
  }

  if (cond.ifDefeated) {
    parts.add('When defeated');
  }

  if (cond.ifAttributesAvailable) {
    parts.add('Requires specific attributes');
  }

  if (cond.triggerMonsters.isNotEmpty) {
    var monsterStr = cond.triggerMonsters.map((m) => m.toString()).join(', ');
    parts.add('When [$monsterStr] on team');
  }

  if (cond.hasTriggerCombos()) {
    parts.add('When ${cond.triggerCombos} combos last turn');
  }

  if (cond.ifNothingMatched) {
    parts.add('If no other skills matched');
  }

  if (cond.alwaysAfter > 0) {
    var skill = esLibrary[cond.alwaysAfter];
    var nameText = LanguageSelector.name(skill).call();
    parts.add('Always use after $nameText');
  }

  if (cond.hasRepeatsEvery()) {
    if (cond.hasTriggerTurn()) {
      if (cond.hasTriggerTurnEnd()) {
        parts.add(
            'Repeating, turns ${cond.triggerTurn}-${cond.triggerTurnEnd} of ${cond.repeatsEvery}');
      } else {
        parts.add('Repeating, turn ${cond.triggerTurn} of ${cond.repeatsEvery}');
      }
    } else {
      parts.add('Repeats every ${cond.repeatsEvery} turns');
    }
  } else if (cond.hasTriggerTurnEnd()) {
    parts.add(formatTurnInfo(
        cond.alwaysTriggerAbove, 'turns ${cond.triggerTurn}-${cond.triggerTurnEnd}'));
  } else if (cond.hasTriggerTurn()) {
    parts.add(formatTurnInfo(cond.alwaysTriggerAbove, 'turn ${cond.triggerTurn}'));
  }

  if (cond.hpThreshold == 101) {
    parts.insert(0, 'When HP is full');
  } else if (cond.hpThreshold > 0) {
    if ((cond.hpThreshold + 1) % 5 == 0) {
      parts.insert(0, 'HP < ${cond.hpThreshold + 1}');
    } else {
      parts.insert(0, 'HP <= ${cond.hpThreshold}');
    }
  }

  return parts.join(', ');
}

String formatTurnInfo(int alwaysTriggerAbove, String turnText) {
  var text = turnText;
  if (alwaysTriggerAbove == 1) {
    text = 'always on $turnText';
  } else if (alwaysTriggerAbove > 1) {
    text = '$turnText while above $alwaysTriggerAbove HP';
  }
  return capitalize(text);
}

String formatAttack(EnemySkill skill, int atk) {
  var damage = skill.atkMult * atk / 100;
  var minDamage = (damage * skill.minHits).round();
  var maxDamage = (damage * skill.maxHits).round();

  var hitsStr =
      skill.minHits == skill.maxHits ? '${skill.minHits}' : '${skill.minHits}-${skill.maxHits}';
  var damageStr = skill.minHits == skill.maxHits
      ? commaFormat(minDamage)
      : commaFormat(minDamage) + '-' + commaFormat(maxDamage);

  return 'Attack $hitsStr times for $damageStr damage';
}
