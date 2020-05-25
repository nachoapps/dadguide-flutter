import 'package:dadguide2/components/config/service_locator.dart';
import 'package:dadguide2/components/images/icons.dart';
import 'package:dadguide2/components/images/images.dart';
import 'package:dadguide2/components/ui/containers.dart';
import 'package:dadguide2/components/ui/navigation.dart';
import 'package:dadguide2/data/tables.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../team_data.dart';
import 'common.dart';

class BaseImage extends StatelessWidget {
  final TeamBase monster;

  const BaseImage(this.monster, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var controller = Provider.of<TeamController>(context);
    var widget = Stack(
      children: <Widget>[
        SizedBox(width: 64, child: iconImage(monster.monsterId)),
        Positioned(
          top: 1,
          right: 1,
          child: SizedBox(width: 18, child: DadGuideIcons.inheritableBadgeImage),
        ),
        if (monster.superAwakening != null)
          Positioned(
            top: 24,
            right: 1,
            child: awakeningContainer(monster.superAwakening.id, size: 24),
          ),
        if (monster.monsterId != 0)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black54,
              margin: EdgeInsets.all(1),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  if (monster.level != 0)
                    OutlineText('Lv ${monster.level}', size: 11, outlineWidth: 2),
                  Spacer(),
                  OutlineText('${monster.monsterId}',
                      size: 10, color: Colors.lightBlueAccent, outlineWidth: 3),
                ],
              ),
            ),
          ),
        if (monster.is297)
          Positioned(
            top: 2,
            left: 4,
            child: OutlineText('+297', color: Colors.yellow, size: 14, outlineWidth: 4),
          ),
        if (!monster.is297 && monster.hasPluses)
          Positioned(
            top: 4,
            left: 4,
            child: Column(
              children: <Widget>[
                OutlineText('+${monster.hpPlus}', color: Colors.yellow, size: 13, outlineWidth: 4),
                OutlineText('+${monster.atkPlus}', color: Colors.yellow, size: 13, outlineWidth: 4),
                OutlineText('+${monster.rcvPlus}', color: Colors.yellow, size: 13, outlineWidth: 4),
              ],
            ),
          ),
      ],
    );

    return ClickDialogIfEditable(
        widget: widget,
        dialogBuilder: (_) => ChangeNotifierProvider.value(
              value: controller,
              child: EditBaseDialog(context, monster),
            ));
  }
}

class EditBaseDialog extends StatelessWidget {
  final BuildContext outer;
  final TeamBase monster;

  const EditBaseDialog(this.outer, this.monster, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var controller = Provider.of<TeamController>(context);

    return AlertDialog(
      title: Text('Edit Monster'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: <Widget>[
                PadIcon(monster.monsterId),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(monster.name),
                      Text('# ${monster.monsterId}'),
                    ],
                  ),
                )
              ],
            ),
            Row(
              children: <Widget>[
                RaisedButton(
                  child: Text('Select'),
                  onPressed: () async {
                    await Navigator.of(context).pop();
                    final m = await Navigator.of(outer).pushNamed<Monster>(
                        MonsterListArgs.routeName,
                        arguments: MonsterListArgs(MonsterListAction.returnResult));
                    if (m == null) return;
                    final fm = await getIt<MonstersDao>().fullMonster(m.monsterId);
                    monster.loadFrom(fm);
                    controller.notify();
                  },
                ),
                SizedBox(width: 32),
                RaisedButton(
                  child: Text('Remove'),
                  onPressed: monster.monsterId == 0
                      ? null
                      : () {
                          monster.clear();
                          controller.notify();
                        },
                ),
              ],
            ),
            if (monster.monsterId > 0) ...[
              Divider(),
              Row(
                children: <Widget>[
                  RaisedButton(
                    child: Text('Max'),
                    onPressed: () {
                      monster.level = 110;
                      monster.awakenings = monster.awakeningOptions.length;
                      monster.hpPlus = 99;
                      monster.atkPlus = 99;
                      monster.rcvPlus = 99;
                      controller.notify();
                    },
                  ),
                  SizedBox(width: 32),
                  RaisedButton(
                    child: Text('Min'),
                    onPressed: () {
                      monster.level = 1;
                      monster.awakenings = 0;
                      monster.hpPlus = 0;
                      monster.atkPlus = 0;
                      monster.rcvPlus = 0;
                      controller.notify();
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      monster.awakenings = 0;
                      controller.notify();
                    },
                    child: Icon(Icons.clear),
                  ),
                  for (int i = 0; i < monster.awakeningOptions.length; i++)
                    GestureDetector(
                      onTap: () {
                        monster.awakenings = i + 1;
                        controller.notify();
                      },
                      child: monster.awakenings < i + 1
                          ? Greyscale(awakeningContainer(monster.awakeningOptions[i].id))
                          : awakeningContainer(monster.awakeningOptions[i].id),
                    ),
                ],
              ),
              SizedBox(height: 16),
              if (monster.superAwakeningOptions.isNotEmpty)
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        monster.superAwakening = null;
                        controller.notify();
                      },
                      child: Icon(Icons.clear),
                    ),
                    for (var sa in monster.superAwakeningOptions)
                      GestureDetector(
                        onTap: () {
                          if (monster.superAwakening?.id == sa.id) {
                            monster.superAwakening = null;
                          } else {
                            monster.superAwakening = sa;
                            controller.notify();
                          }
                        },
                        child: monster.superAwakening?.id != sa.id
                            ? Greyscale(awakeningContainer(sa.id))
                            : awakeningContainer(sa.id),
                      ),
                  ],
                ),
              StatRow(
                title: 'Lv    ',
                getValue: () => monster.level,
                setValue: (v) => monster.level = v,
                minValue: 1,
                altValue: monster.canLimitBreak ? monster.maxLevel : null,
                maxValue: monster.canLimitBreak ? 110 : monster.maxLevel,
              ),
              StatRow(
                title: 'HP+ ',
                getValue: () => monster.hpPlus,
                setValue: (v) => monster.hpPlus = v,
                minValue: 0,
                altValue: 0,
                maxValue: 99,
              ),
              StatRow(
                title: 'ATK+',
                getValue: () => monster.atkPlus,
                setValue: (v) => monster.atkPlus = v,
                minValue: 0,
                altValue: 0,
                maxValue: 99,
              ),
              StatRow(
                title: 'RCV+',
                getValue: () => monster.rcvPlus,
                setValue: (v) => monster.rcvPlus = v,
                minValue: 0,
                altValue: 0,
                maxValue: 99,
              ),
            ],
          ],
        ),
      ),
      actions: <Widget>[
        FlatButton(child: Text('Done'), onPressed: () => Navigator.of(context).pop()),
      ],
    );
  }
}
