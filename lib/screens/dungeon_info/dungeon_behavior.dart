import 'package:dadguide2/components/models/data_objects.dart';
import 'package:dadguide2/components/utils/formatting.dart';
import 'package:dadguide2/data/tables.dart';
import 'package:dadguide2/l10n/localizations.dart';
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
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: BehaviorWarningWidget(),
          ),
        for (var group in groups) BehaviorGroupWidget(true, group),
      ],
    );
  }
}

class BehaviorWarningWidget extends StatelessWidget {
  static const textLink =
      'https://docs.google.com/document/d/10L1HSYg5ZNZocvTFUarg20rGyTEylJze5GHOEK3YLUA/edit#heading=h.s5qhmnr5fy53';

  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);

    return Container(
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
            Flexible(child: Center(child: Text(loc.esNotReviewedWarning))),
          ],
        ),
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
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: group.children.length,
      itemBuilder: (ctx, idx) => Padding(
          padding: EdgeInsets.only(left: 4, right: 4, top: 2),
          child: BehaviorItemWidget(group.children[idx])),
    );

    var showType = forceType ||
        group.groupType == BehaviorGroup_GroupType.MONSTER_STATUS ||
        group.groupType == BehaviorGroup_GroupType.DISPEL_PLAYER;
    var conditionText = formatCondition(context, group.condition, inputs.esLibrary);

    if (showType) {
      return TextBorder(
          text: convertGroup(context, group.groupType, group.condition), child: contents);
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
    var conditionText = formatCondition(context, behavior.condition, inputs.esLibrary);
    if (conditionText.isNotEmpty) {
      descText = '$descText ($conditionText)';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(nameText, style: caption(context)),
        if (descText.isNotEmpty) Text(descText, style: esDescription(context)),
        if (skill.minHits > 0)
          Text(formatAttack(context, skill, inputs.atk), style: esDescription(context)),
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
          margin: EdgeInsets.only(top: 8),
          // Force the contents down so the title doesn't overlap it. Pad the bottom by the same
          // amount to make it symmetric.
          padding: EdgeInsets.only(top: 8, bottom: 8),
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
              child: Text(text, style: esDescription(context)),
            )),
      ],
    );
  }
}

String convertGroup(BuildContext context, BehaviorGroup_GroupType groupType, Condition cond) {
  var loc = DadGuideLocalizations.of(context);

  switch (groupType) {
    case BehaviorGroup_GroupType.DEATH:
      return loc.esGroupOnDeath;
    case BehaviorGroup_GroupType.DISPEL_PLAYER:
      return loc.esGroupPlayerBuff;
    case BehaviorGroup_GroupType.MONSTER_STATUS:
      return loc.esGroupEnemyDebuff;
    case BehaviorGroup_GroupType.PASSIVE:
      return loc.esGroupAbilities;
    case BehaviorGroup_GroupType.PREEMPT:
      return loc.esGroupPreemptive;
    case BehaviorGroup_GroupType.REMAINING:
      var condStr = formatCondition(context, cond, {});
      return condStr.isEmpty ? loc.esGroupError : condStr;
    case BehaviorGroup_GroupType.STANDARD:
      var condStr = formatCondition(context, cond, {});
      return condStr.isEmpty ? loc.esGroupStandard : condStr;
    case BehaviorGroup_GroupType.UNKNOWN_USE:
      return loc.esGroupUnknownUse;
  }
  return loc.esGroupUnknown;
}

String formatCondition(BuildContext context, Condition cond, Map<int, EnemySkill> esLibrary) {
  var loc = DadGuideLocalizations.of(context);
  var parts = <String>[];

  if (![0, 100].contains(cond.useChance)) {
    parts.add(loc.esCondUseChance(cond.useChance));
  }

  if (cond.hasLimitedExecution()) {
    parts.add(loc.esCondLimitedExecution(cond.limitedExecution));
  } else if (cond.globalOneTime) {
    parts.add(loc.esCondOneTimeOnly);
  }

  if (cond.triggerEnemiesRemaining == 1) {
    parts.add(loc.esCondOneEnemiesRemaining);
  } else if (cond.triggerEnemiesRemaining > 1) {
    parts.add(loc.esCondMultipleEnemiesRemaining(cond.triggerEnemiesRemaining));
  }

  if (cond.ifDefeated) {
    parts.add(loc.esCondDefeated);
  }

  if (cond.ifAttributesAvailable) {
    parts.add(loc.esCondAttributesAvailable);
  }

  if (cond.triggerMonsters.isNotEmpty) {
    var monsterStr = cond.triggerMonsters.map((m) => m.toString()).join(', ');
    parts.add(loc.esCondTriggerMonsters(monsterStr));
  }

  if (cond.hasTriggerCombos()) {
    parts.add(loc.esCondTriggerCombos(cond.triggerCombos));
  }

  if (cond.ifNothingMatched) {
    parts.add(loc.esCondNothingMatched);
  }

  if (cond.alwaysAfter > 0) {
    var skill = esLibrary[cond.alwaysAfter];
    var nameText = LanguageSelector.name(skill).call();
    parts.add(loc.esCondTriggerAfter(nameText));
  }

  if (cond.hasRepeatsEvery()) {
    if (cond.hasTriggerTurn()) {
      if (cond.hasTriggerTurnEnd()) {
        parts.add(loc.esCondRepeating3(cond.triggerTurn, cond.triggerTurnEnd, cond.repeatsEvery));
      } else {
        parts.add(loc.esCondRepeating2(cond.triggerTurn, cond.repeatsEvery));
      }
    } else {
      parts.add(loc.esCondRepeating1(cond.repeatsEvery));
    }
  } else if (cond.hasTriggerTurnEnd()) {
    parts.add(formatTurnInfo(context, cond.alwaysTriggerAbove,
        loc.esCondTurnsRange(cond.triggerTurn, cond.triggerTurnEnd)));
  } else if (cond.hasTriggerTurn()) {
    parts.add(
        formatTurnInfo(context, cond.alwaysTriggerAbove, loc.esCondTurnsExact(cond.triggerTurn)));
  }

  if (cond.hpThreshold == 101) {
    parts.insert(0, loc.esCondHpFull);
  } else if (cond.hpThreshold > 0) {
    if ((cond.hpThreshold + 1) % 5 == 0) {
      parts.insert(0, loc.esCondHpLt(cond.hpThreshold + 1));
    } else {
      parts.insert(0, loc.esCondHpLtEq(cond.hpThreshold));
    }
  }

  return parts.join(loc.esCondPartJoin);
}

String formatTurnInfo(BuildContext context, int alwaysTriggerAbove, String turnText) {
  var loc = DadGuideLocalizations.of(context);

  var text = turnText;
  if (alwaysTriggerAbove == 1) {
    text = loc.esCondAlwaysOnTurn(turnText);
  } else if (alwaysTriggerAbove > 1) {
    text = loc.esCondWhileAboveHp(turnText, alwaysTriggerAbove);
  }
  return capitalize(text);
}

String formatAttack(BuildContext context, EnemySkill skill, int atk) {
  var loc = DadGuideLocalizations.of(context);

  var damage = skill.atkMult * atk / 100;
  var minDamage = (damage * skill.minHits).round();
  var maxDamage = (damage * skill.maxHits).round();

  var hitsStr =
      skill.minHits == skill.maxHits ? '${skill.minHits}' : '${skill.minHits}-${skill.maxHits}';
  var damageStr = skill.minHits == skill.maxHits
      ? commaFormat(minDamage)
      : commaFormat(minDamage) + '-' + commaFormat(maxDamage);

  return loc.esAttackText(hitsStr, damageStr);
}
