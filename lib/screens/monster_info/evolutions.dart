import 'package:dadguide2/components/images/images.dart';
import 'package:dadguide2/components/models/data_objects.dart';
import 'package:dadguide2/components/models/enums.dart';
import 'package:dadguide2/components/utils/formatting.dart';
import 'package:dadguide2/data_dadguide/tables.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:dadguide2/screens/monster_info/utils.dart';
import 'package:dadguide2/theme/style.dart';
import 'package:flutter/material.dart';

/// Wrapper for the multiple possible evolution sections.
class MonsterEvolutions extends StatelessWidget {
  final FullMonster fullMonster;

  const MonsterEvolutions(this.fullMonster, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);

    var evos = fullMonster.evolutions;
    final baseEvos = evos.where((e) => e.type == EvolutionType.evo).toList();
    final reversableEvos = evos.where((e) => e.type == EvolutionType.reversible).toList();
    final nonReversableEvos = evos.where((e) => e.type == EvolutionType.non_reversible).toList();
    final transformations = fullMonster.transformations;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (baseEvos.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: MonsterEvoSection(loc.monsterInfoEvolution, baseEvos),
          ),
        if (reversableEvos.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: MonsterEvoSection(loc.monsterInfoReversableEvolution, reversableEvos),
          ),
        if (nonReversableEvos.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: MonsterEvoSection(loc.monsterInfoNonReversableEvolution, nonReversableEvos),
          ),
        if (transformations.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: MonsterTransformationSection(transformations),
          ),
      ],
    );
  }
}

/// An individual evolution section, with a name and list of evos.
class MonsterEvoSection extends StatelessWidget {
  final String name;
  final List<FullEvolution> evos;

  MonsterEvoSection(this.name, this.evos);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, style: subtitle(context)),
        for (var evo in evos)
          Padding(
            child: MonsterEvoRow(evo),
            padding: EdgeInsets.symmetric(vertical: 4),
          ),
      ],
    );
  }
}

/// An individual evo row, with from/to monster and mats displayed between.
class MonsterEvoRow extends StatelessWidget {
  final FullEvolution data;

  const MonsterEvoRow(this.data, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);
    var statText = _buildStatText(loc, data.fromMonster, data.toMonster);

    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: {
        0: IntrinsicColumnWidth(),
        2: IntrinsicColumnWidth(),
        4: IntrinsicColumnWidth(),
      },
      children: [
        TableRow(
          children: [
            PadIcon(data.fromMonster.monsterId, monsterLink: true),
            Icon(Icons.add),
            Row(children: [
              for (var matId in data.evoMatIds)
                Padding(
                  child: PadIcon(matId, size: 38, monsterLink: true),
                  padding: EdgeInsets.symmetric(horizontal: 2),
                ),
              for (int i = 0; i < 5 - data.evoMatIds.length; i++)
                Padding(
                  child: SizedBox(width: 38),
                  padding: EdgeInsets.symmetric(horizontal: 2),
                ),
            ]),
            Icon(Icons.chevron_right),
            PadIcon(data.toMonster.monsterId, monsterLink: true),
          ],
        ),
        TableRow(
          children: [
            TypesRowChunk(data.fromMonster),
            Container(),
            Center(child: Text(statText, style: Theme.of(context).textTheme.caption)),
            Container(),
            TypesRowChunk(data.toMonster),
          ],
        )
      ],
    );
  }
}

/// An individual evolution section, with a name and list of transformations.
class MonsterTransformationSection extends StatelessWidget {
  final List<Transformation> transformations;

  MonsterTransformationSection(this.transformations);

  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(loc.monsterInfoTransformationEvolution, style: subtitle(context)),
        for (var transformation in transformations)
          Padding(
            child: MonsterTransformationRow(transformation),
            padding: EdgeInsets.symmetric(vertical: 4),
          ),
      ],
    );
  }
}

/// An individual transformation row, with from/to monster and active info displayed between.
class MonsterTransformationRow extends StatelessWidget {
  final Transformation data;

  const MonsterTransformationRow(this.data);

  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);
    var statText = _buildStatText(loc, data.fromMonster, data.toMonster);
    var lvlText = skillLevelText(loc, data.skill);

    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: {
        0: IntrinsicColumnWidth(),
        2: IntrinsicColumnWidth(),
        4: IntrinsicColumnWidth(),
      },
      children: [
        TableRow(
          children: [
            PadIcon(data.fromMonster.monsterId, monsterLink: true),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Icon(Icons.add),
            ),
            FittedBox(
              child: Text(
                'Active skill: $lvlText',
              ),
            ),
            Icon(Icons.chevron_right),
            PadIcon(data.toMonster.monsterId, monsterLink: true),
          ],
        ),
        TableRow(
          children: [
            TypesRowChunk(data.fromMonster),
            Container(),
            Center(child: Text(statText, style: Theme.of(context).textTheme.caption)),
            Container(),
            TypesRowChunk(data.toMonster),
          ],
        )
      ],
    );
  }
}

class TypesRowChunk extends StatelessWidget {
  final Monster monster;

  const TypesRowChunk(this.monster);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        typeContainer(monster.type1Id),
        typeContainer(monster.type2Id),
        typeContainer(monster.type3Id),
      ],
    );
  }
}

String _buildStatText(DadGuideLocalizations loc, Monster fromMonster, Monster toMonster) {
  var hpDiff = toMonster.hpMax - fromMonster.hpMax;
  var atkDiff = toMonster.atkMax - fromMonster.atkMax;
  var rcvDiff = toMonster.rcvMax - fromMonster.rcvMax;
  var deltas = [];

  if (hpDiff != 0) deltas.add(loc.monsterInfoEvoDiffHp(plusMinus(hpDiff)));
  if (atkDiff != 0) deltas.add(loc.monsterInfoEvoDiffAtk(plusMinus(atkDiff)));
  if (rcvDiff != 0) deltas.add(loc.monsterInfoEvoDiffRcv(plusMinus(rcvDiff)));

  return deltas.join(' / ');
}
