import 'package:dadguide2/data/tables.dart';
import 'package:dadguide2/l10n/localizations.dart';

String skillLevelText(DadGuideLocalizations loc, ActiveSkill skill) {
  var skillLevels = skill.turnMax - skill.turnMin + 1;
  return skillLevels == 1
      ? loc.monsterInfoSkillMaxed(skill.turnMax)
      : loc.monsterInfoSkillTurns(skill.turnMax, skill.turnMin, skillLevels);
}
