import 'package:dadguide2/components/config/service_locator.dart';
import 'package:dadguide2/components/images/images.dart';
import 'package:dadguide2/components/ui/navigation.dart';
import 'package:dadguide2/data_dadguide/tables.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../team_data.dart';
import 'common.dart';

class AssistImage extends StatelessWidget {
  final TeamAssist item;
  final TeamBase base;

  const AssistImage(this.item, this.base, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var controller = Provider.of<TeamController>(context);

    if (!controller.editable && !item.hasMonster) {
      return SizedBox(width: 100, height: 1);
    }

    var widget = Stack(
      children: <Widget>[
        SizedBox(width: 64, child: iconImage(item.monsterId)),
        if (item.hasMonster) ...[
          if (canContributeStats && item.is297)
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
                  if (canContributeStats) OutlineText('LV ${item.level}', size: 11),
                  Spacer(),
                  OutlineText('${item.id()}', size: 10, color: Colors.lightBlueAccent[100]),
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
              child: EditAssistDialog(context, item),
            ));
  }

  bool get canContributeStats =>
      item.hasMonster && base.hasMonster && item.monster.attr1 == base.monster.attr1;
}

class EditAssistDialog extends StatelessWidget {
  final BuildContext outer;
  final TeamAssist item;

  const EditAssistDialog(this.outer, this.item, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var controller = Provider.of<TeamController>(context);

    return AlertDialog(
      title: Text(context.loc.teamEditAssistDialogTitle),
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
                        Text('# ${item.monsterId}'),
                      ],
                    ),
                  )
              ],
            ),
            Row(
              children: <Widget>[
                RaisedButton(
                  child: Text(context.loc.teamEditDialogSelect),
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
                SizedBox(width: 32),
                RaisedButton(
                  child: Text(context.loc.teamEditDialogRemove),
                  onPressed: !item.hasMonster
                      ? null
                      : () {
                          item.clear();
                          controller.notify();
                        },
                ),
              ],
            ),
            if (item.hasMonster) ...[
              Divider(),
              Row(
                children: <Widget>[
                  RaisedButton(
                    child: Text(context.loc.teamEditDialogMax),
                    onPressed: () {
                      item.level = item.monster.level;
                      item.is297 = true;
                      controller.notify();
                    },
                  ),
                  SizedBox(width: 32),
                  RaisedButton(
                    child: Text(context.loc.teamEditDialogMin),
                    onPressed: () {
                      item.level = 1;
                      item.is297 = false;
                      controller.notify();
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),
              StatRow(
                title: 'Lv    ',
                getValue: () => item.level,
                setValue: (v) => item.level = v,
                minValue: 1,
                altValue: item.canLimitBreak ? item.monster.level : null,
                maxValue: item.canLimitBreak ? 110 : item.monster.level,
              ),
              Row(
                children: <Widget>[
                  Text('+297'),
                  Checkbox(
                    activeColor: Colors.blue,
                    value: item.is297,
                    onChanged: (v) {
                      item.is297 = v;
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
        FlatButton(child: Text(context.loc.close), onPressed: () => Navigator.of(context).pop()),
      ],
    );
  }
}
