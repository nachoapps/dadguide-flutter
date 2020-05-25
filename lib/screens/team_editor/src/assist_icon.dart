import 'package:dadguide2/components/config/service_locator.dart';
import 'package:dadguide2/components/images/images.dart';
import 'package:dadguide2/components/ui/navigation.dart';
import 'package:dadguide2/data/tables.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../team_data.dart';
import 'common.dart';

class AssistImage extends StatelessWidget {
  final TeamAssist monster;

  const AssistImage(this.monster, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var controller = Provider.of<TeamController>(context);

    if (!controller.editable && monster.monsterId == 0) {
      return Container();
    }

    var widget = Stack(
      children: <Widget>[
        SizedBox(width: 64, child: iconImage(monster.monsterId)),
        if (monster.monsterId != 0) ...[
          if (monster.is297)
            Positioned(
              top: 2,
              left: 4,
              child: OutlineText('+297', color: Colors.yellow, size: 14, outlineWidth: 4),
            ),
          Positioned(
            bottom: 1,
            left: 1,
            right: 1,
            child: Container(
              color: Colors.black54,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  if (monster.level != 0) OutlineText('LV ${monster.level}', size: 11),
                  Spacer(),
                  OutlineText('${monster.monsterId}', size: 9),
                ],
              ),
            ),
          ),
        ],
      ],
    );

    return ClickDialogIfEditable(
        widget: widget,
        dialogBuilder: (_) => ChangeNotifierProvider.value(
              value: controller,
              child: EditAssistDialog(context, monster),
            ));
  }
}

class EditAssistDialog extends StatelessWidget {
  final BuildContext outer;
  final TeamAssist monster;

  const EditAssistDialog(this.outer, this.monster, {Key key}) : super(key: key);

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
                      monster.level = monster.maxLevel;
                      monster.is297 = true;
                      controller.notify();
                    },
                  ),
                  SizedBox(width: 32),
                  RaisedButton(
                    child: Text('Min'),
                    onPressed: () {
                      monster.level = 1;
                      monster.is297 = false;
                      controller.notify();
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),
              StatRow(
                title: 'Lv    ',
                getValue: () => monster.level,
                setValue: (v) => monster.level = v,
                minValue: 1,
                altValue: monster.canLimitBreak ? monster.maxLevel : null,
                maxValue: monster.canLimitBreak ? 110 : monster.maxLevel,
              ),
              Row(
                children: <Widget>[
                  Text('+297'),
                  Checkbox(
                    activeColor: Colors.blue,
                    value: monster.is297,
                    onChanged: (v) {
                      monster.is297 = v;
                      controller.notify();
                    },
                  ),
                ],
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
