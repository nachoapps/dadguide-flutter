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
  final TeamBase item;

  const BaseImage(this.item, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var controller = Provider.of<TeamController>(context);
    var widget = Stack(
      children: <Widget>[
        SizedBox(width: 64, child: iconImage(item.monsterId)),
        if (item.displayBadge)
          Positioned(
            top: 1,
            right: 1,
            child: SizedBox(width: 18, child: DadGuideIcons.inheritableBadgeImage),
          ),
        if (item.hasSuperAwakening)
          Positioned(
            top: 24,
            right: 1,
            child: awakeningContainer(item.superAwakening.awokenSkillId, size: 24),
          ),
        if (item.hasMonster)
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
                  OutlineText('Lv ${item.level}', size: 11, outlineWidth: 2),
                  Spacer(),
                  OutlineText('${item.id()}',
                      size: 10, color: Colors.lightBlueAccent, outlineWidth: 3),
                ],
              ),
            ),
          ),
        if (item.is297)
          Positioned(
            top: 2,
            left: 4,
            child: OutlineText('+297', color: Colors.yellow, size: 14, outlineWidth: 4),
          ),
        if (!item.is297 && item.hasPluses)
          Positioned(
            top: 4,
            left: 4,
            child: Column(
              children: <Widget>[
                OutlineText('+${item.hpPlus}', color: Colors.yellow, size: 13, outlineWidth: 4),
                OutlineText('+${item.atkPlus}', color: Colors.yellow, size: 13, outlineWidth: 4),
                OutlineText('+${item.rcvPlus}', color: Colors.yellow, size: 13, outlineWidth: 4),
              ],
            ),
          ),
      ],
    );

    return ClickDialogIfEditable(
        widget: widget,
        dialogBuilder: (_) => ChangeNotifierProvider.value(
              value: controller,
              child: EditBaseDialog(context, item),
            ));
  }
}

class EditBaseDialog extends StatelessWidget {
  final BuildContext outer;
  final TeamBase item;

  const EditBaseDialog(this.outer, this.item, {Key key}) : super(key: key);

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
                PadIcon(item.monsterId),
                SizedBox(width: 8),
                if (item.hasMonster)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(item.name()),
                        Text('# ${item.id()}'),
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
                    item.loadFrom(fm);
                    controller.notify();
                  },
                ),
                SizedBox(width: 8),
                RaisedButton(
                  child: Text('Remove'),
                  onPressed: item.monsterId == 0
                      ? null
                      : () {
                          item.clear();
                          controller.notify();
                        },
                ),
              ],
            ),
            if (item.monsterId > 0) ...[
              Divider(),
              FittedBox(
                child: Row(
                  children: <Widget>[
                    if (item.canLimitBreak) ...[
                      RaisedButton(
                        child: Text('110'),
                        onPressed: () {
                          item.level = 110;
                          item.awakenings = item.awakeningOptions.length;
                          item.hpPlus = 99;
                          item.atkPlus = 99;
                          item.rcvPlus = 99;
                          controller.notify();
                        },
                      ),
                      SizedBox(width: 8),
                    ],
                    RaisedButton(
                      child: Text('Max (${item.monster.level})'),
                      onPressed: () {
                        item.level = item.monster.level;
                        item.awakenings = item.awakeningOptions.length;
                        item.hpPlus = 99;
                        item.atkPlus = 99;
                        item.rcvPlus = 99;
                        controller.notify();
                      },
                    ),
                    SizedBox(width: 8),
                    RaisedButton(
                      child: Text('Min'),
                      onPressed: () {
                        item.level = 1;
                        item.awakenings = 0;
                        item.hpPlus = 0;
                        item.atkPlus = 0;
                        item.rcvPlus = 0;
                        controller.notify();
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      item.awakenings = 0;
                      controller.notify();
                    },
                    child: Icon(Icons.clear),
                  ),
                  for (int i = 0; i < item.awakeningOptions.length; i++)
                    GestureDetector(
                      onTap: () {
                        item.awakenings = i + 1;
                        controller.notify();
                      },
                      child: item.awakenings < i + 1
                          ? Greyscale(awakeningContainer(item.awakeningOptions[i].awokenSkillId))
                          : awakeningContainer(item.awakeningOptions[i].awokenSkillId),
                    ),
                ],
              ),
              SizedBox(height: 16),
              if (item.superAwakeningOptions.isNotEmpty) ...[
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        item.superAwakening = null;
                        controller.notify();
                      },
                      child: Icon(Icons.clear),
                    ),
                    for (var sa in item.superAwakeningOptions)
                      GestureDetector(
                        onTap: () {
                          if (item.superAwakening == sa) {
                            item.superAwakening = null;
                          } else {
                            item.superAwakening = sa;
                            controller.notify();
                          }
                        },
                        child: item.superAwakening != sa
                            ? Greyscale(awakeningContainer(sa.awokenSkillId))
                            : awakeningContainer(sa.awokenSkillId),
                      ),
                  ],
                ),
                SizedBox(height: 16),
              ],
              Row(
                children: <Widget>[
                  StatRow(
                    title: 'Lv    ',
                    getValue: () => item.level,
                    setValue: (v) => item.level = v,
                    minValue: 1,
                    altValue: item.canLimitBreak ? item.monster.level : null,
                    maxValue: item.canLimitBreak ? 110 : item.monster.level,
                  ),
                  SizedBox(width: 16),
                  StatRow(
                    title: 'HP+ ',
                    getValue: () => item.hpPlus,
                    setValue: (v) => item.hpPlus = v,
                    minValue: 0,
                    altValue: 0,
                    maxValue: 99,
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: <Widget>[
                  StatRow(
                    title: 'ATK+',
                    getValue: () => item.atkPlus,
                    setValue: (v) => item.atkPlus = v,
                    minValue: 0,
                    altValue: 0,
                    maxValue: 99,
                  ),
                  SizedBox(width: 16),
                  StatRow(
                    title: 'RCV+',
                    getValue: () => item.rcvPlus,
                    setValue: (v) => item.rcvPlus = v,
                    minValue: 0,
                    altValue: 0,
                    maxValue: 99,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: <Widget>[
        OutlineButton(child: Text('Done'), onPressed: () => Navigator.of(context).pop()),
      ],
    );
  }
}
