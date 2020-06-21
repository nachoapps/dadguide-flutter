import 'dart:math';

import 'package:dadguide2/components/config/service_locator.dart';
import 'package:dadguide2/components/images/images.dart';
import 'package:dadguide2/components/models/data_objects.dart';
import 'package:dadguide2/components/models/enums.dart';
import 'package:dadguide2/components/ui/containers.dart';
import 'package:dadguide2/components/ui/monster.dart';
import 'package:dadguide2/components/ui/navigation.dart';
import 'package:dadguide2/data/tables.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:dadguide2/screens/monster_compare/src/state.dart';
import 'package:dadguide2/screens/monster_info/utils.dart';
import 'package:dadguide2/theme/style.dart';
import 'package:fimber_io/fimber_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:tuple/tuple.dart';

class CompareFrame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var state = Provider.of<CompareState>(context);
    var controller = Provider.of<ScreenshotController>(context);
    return SingleChildScrollView(
      child: ScreenshotContainer(
        controller: controller,
        child: CompareContents(state.left, state.right),
      ),
    );
  }
}

class BottomBar extends StatelessWidget {
  static Future<Tuple2<FullMonster, FullMonster>> reload(Monster m, FullMonster fm) async {
    final newRarity = min(m.rarity, fm.monster.rarity);
    var dao = getIt<MonstersDao>();
    var newFm = await dao.fullMonster(m.monsterId, rarityForStats: newRarity);

    // We might have to reload the other if the rarity changed.
    final actualNewRarity = newFm.statComparison.rarity;
    if (fm.statComparison.rarity != actualNewRarity) {
      Fimber.i('Reloading alt comparison monster for rarity $actualNewRarity');
      fm = await dao.fullMonster(fm.monster.monsterId, rarityForStats: actualNewRarity);
    }

    return Tuple2(newFm, fm);
  }

  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);
    var state = Provider.of<CompareState>(context);

    return TabOptionsBar([
      RaisedButton(
        child: Text(loc.monsterCompareSelectLeft),
        onPressed: () async {
          final m = await goToMonsterList(context);
          if (m == null) return;

          var reloaded = await reload(m, state.right);
          state.update(reloaded.item1, reloaded.item2);
        },
      ),
      RaisedButton(
        child: Text(loc.monsterCompareSelectRight),
        onPressed: () async {
          final m = await goToMonsterList(context);
          if (m == null) return;

          var reloaded = await reload(m, state.left);
          state.update(reloaded.item2, reloaded.item1);
        },
      ),
    ]);
  }
}

class CompareContents extends StatelessWidget {
  final FullMonster left;
  final FullMonster right;

  const CompareContents(this.left, this.right);

  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);
    final compareRarity = left.statComparison.rarity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Overview(left),
            VerticalDivider(color: grey(context, 1000), thickness: 1),
            Overview(right),
          ],
        ),
        GreyBar(loc.monsterCompareStatsSectionTitle(compareRarity)),
        Stats(left, right),
        GreyBar(loc.monsterCompareAwokenSectionTitle),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AwakeningSection(left),
            VerticalDivider(),
            AwakeningSection(right),
          ],
        ),
        GreyBar(loc.monsterCompareActiveSectionTitle),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ActiveSkillSection(left.activeSkill),
            VerticalDivider(),
            ActiveSkillSection(right.activeSkill),
          ],
        ),
        GreyBar(loc.monsterCompareLeaderSectionTitle),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LeaderSkillSection(left),
            VerticalDivider(),
            LeaderSkillSection(right),
          ],
        ),
      ],
    );
  }
}

class Overview extends StatelessWidget {
  final FullMonster fullMonster;
  Overview(this.fullMonster);

  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);

    var monster = fullMonster.monster;

    return Expanded(
      child: Column(
        children: [
          FittedBox(child: Text(fullMonster.name())),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PadIcon(monster.monsterId),
              Column(
                children: [
                  Text('⭐${monster.rarity} / ${loc.monsterInfoCost(monster.cost)}'),
                  Row(
                    children: [
                      OptAttr(fullMonster.attr1),
                      OptAttr(fullMonster.attr2),
                      OptType(fullMonster.type1),
                      OptType(fullMonster.type2),
                      OptType(fullMonster.type3),
                    ],
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}

class OptAttr extends StatelessWidget {
  final OrbType orbType;

  OptAttr(this.orbType);

  @override
  Widget build(BuildContext context) {
    if (orbType == null) return Container();
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: SizedBox(width: 16, height: 16, child: orbType.icon),
    );
  }
}

class OptType extends StatelessWidget {
  final MonsterType monsterType;

  OptType(this.monsterType);

  @override
  Widget build(BuildContext context) {
    if (monsterType == null) return Container();
    return typeContainer(monsterType.id, leftPadding: 4);
  }
}

class GreyBar extends StatelessWidget {
  final String text;

  const GreyBar(this.text);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: grey(context, 400),
      padding: const EdgeInsets.all(4.0),
      child: Center(child: Text(text)),
    );
  }
}

class Stats extends StatelessWidget {
  final FullMonster left;
  final FullMonster right;

  Stats(this.left, this.right);

  @override
  Widget build(BuildContext context) {
    final leftM = left.monster;
    final rightM = right.monster;
    final leftStat = left.statComparison;
    final rightStat = right.statComparison;

    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: {
        0: IntrinsicColumnWidth(),
        2: IntrinsicColumnWidth(),
        4: IntrinsicColumnWidth(),
      },
      children: [
        createStatRow(context, 'HP', leftM.hpMax, rightM.hpMax, leftStat.hpPct, rightStat.hpPct,
            Colors.green),
        createStatRow(context, 'ATK', leftM.atkMax, rightM.atkMax, leftStat.atkPct, rightStat.hpPct,
            Colors.redAccent),
        createStatRow(context, 'RCV', leftM.rcvMax, rightM.rcvMax, leftStat.rcvPct,
            rightStat.rcvPct, Colors.blueAccent),
        createStatRow(
            context,
            'Total',
            left.stats.weighted,
            right.stats.weighted,
            left.statComparison.weightedPct,
            right.statComparison.weightedPct,
            Colors.deepPurpleAccent),
      ],
    );
  }
}

TableRow createStatRow(BuildContext context, String title, int left, int right, double leftPct,
    double rightPct, Color color) {
  return TableRow(
    decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(color: grey(context, 400), style: BorderStyle.solid, width: 1.0))),
    children: [
      TableNum(left - right, TextAlign.left),
      ColorBoxNum(left, leftPct, TextAlign.right, color),
      TableCell(
          child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                  border: Border(
                left: BorderSide(color: grey(context, 400), style: BorderStyle.solid, width: 1.0),
                right: BorderSide(color: grey(context, 400), style: BorderStyle.solid, width: 1.0),
              )),
              child: Text(title, textAlign: TextAlign.center))),
      ColorBoxNum(right, rightPct, TextAlign.left, color),
      TableNum(right - left, TextAlign.right),
    ],
  );
}

class TableNum extends StatelessWidget {
  final int num;
  final TextAlign align;
  const TableNum(this.num, this.align);

  @override
  Widget build(BuildContext context) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Text(
          '$num',
          style: TextStyle(color: color),
          textAlign: align,
        ),
      ),
    );
  }

  Color get color {
    if (num > 0) return Colors.green;
    if (num < 0) return Colors.red;
    return null;
  }
}

class ColorBoxNum extends StatelessWidget {
  final int num;
  final double numPct;
  final TextAlign align;
  final Color color;
  ColorBoxNum(this.num, this.numPct, this.align, this.color);

  @override
  Widget build(BuildContext context) {
    return TableCell(child: LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth * numPct;
      final left = align == TextAlign.left ? 0.0 : null;
      final leftPadding = align == TextAlign.left ? 4.0 : 0.0;
      final right = align == TextAlign.right ? 0.0 : null;
      final rightPadding = align == TextAlign.right ? 4.0 : 0.0;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Stack(
          children: <Widget>[
            Text(''), // This fake text is necessary for computing the height
            Positioned(
                left: left,
                right: right,
                child: Container(
                  width: width,
                  color: color,
                  child: Text(''), // This fake text expands the box
                )),
            Positioned(
                left: left,
                right: right,
                child: Padding(
                  padding: EdgeInsets.only(left: leftPadding, right: rightPadding),
                  child: Text('$num'),
                )),
          ],
        ),
      );
    }));
  }
}

class AwakeningSection extends StatelessWidget {
  final FullMonster fullMonster;
  AwakeningSection(this.fullMonster);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          children: <Widget>[
            AwakeningWrap(fullMonster.awakenings),
            if (fullMonster.superAwakenings.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(children: <Widget>[
                  Text('SA'),
                  VerticalDivider(),
                  AwakeningWrap(fullMonster.superAwakenings),
                ]),
              )
          ],
        ),
      ),
    );
  }
}

class AwakeningWrap extends StatelessWidget {
  final List<FullAwakening> awakenings;
  const AwakeningWrap(this.awakenings);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: <Widget>[
        for (var fa in awakenings) awakeningContainer(fa.awokenSkillId, size: 20),
      ],
    );
  }
}

class ActiveSkillSection extends StatelessWidget {
  final FullActiveSkill activeSkill;
  ActiveSkillSection(ActiveSkill active) : activeSkill = FullActiveSkill(active);

  @override
  Widget build(BuildContext context) {
    if (activeSkill == null) return Expanded(child: Container());

    var loc = DadGuideLocalizations.of(context);
    var lvlText = skillLevelText(loc, activeSkill.skill);

    return Expanded(
      child: Column(
        children: [
          Center(child: FittedBox(child: Text(activeSkill.name()))),
          Center(
            child: FittedBox(
              child: Text(
                lvlText,
                style: Theme.of(context).textTheme.caption.copyWith(fontSize: 12),
              ),
            ),
          ),
          SizedBox(height: 2),
          Text(activeSkill.desc(), style: secondary(context)),
        ],
      ),
    );
  }
}

class LeaderSkillSection extends StatelessWidget {
  final FullMonster fullMonster;
  LeaderSkillSection(this.fullMonster);

  @override
  Widget build(BuildContext context) {
    if (fullMonster.leaderSkill == null) return Expanded(child: Container());

    var leaderSkill = FullLeaderSkill(fullMonster.leaderSkill);
    return Expanded(
      child: Column(
        children: [
          Center(child: FittedBox(child: Text(leaderSkill.name()))),
          SizedBox(height: 2),
          Text(leaderSkill.desc(), style: secondary(context)),
          SizedBox(height: 4),
          MonsterLeaderInfoTable(fullMonster),
        ],
      ),
    );
  }
}
