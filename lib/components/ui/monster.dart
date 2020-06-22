import 'dart:math';

import 'package:dadguide2/components/images/images.dart';
import 'package:dadguide2/components/models/data_objects.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:dadguide2/theme/style.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Leader skill multiplier table.
class MonsterLeaderInfoTable extends StatelessWidget {
  final FullMonster data;

  const MonsterLeaderInfoTable(this.data, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);

    var m = data.monster;
    var ls = data.leaderSkill;
    // truncates to 1 or 2 decimal places depending on significant decimals
    var _truncateNumber =
        (double n) => n.toStringAsFixed((n * 10).truncateToDouble() == n * 10 ? 1 : 2);

    return DefaultTextStyle(
      style: Theme.of(context).textTheme.caption,
      child: Table(
        border: TableBorder.all(width: 1.0, color: grey(context, 800)),
        children: [
          TableRow(children: [
            Container(),
            widgetCell(PadIcon(
              m.monsterId,
              size: 24,
            )),
            widgetCell(Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PadIcon(m.monsterId, size: 24),
                SizedBox(width: 4),
                PadIcon(m.monsterId, size: 24),
              ],
            )),
          ]),
          TableRow(children: [
            cell(loc.monsterInfoHp),
            cell(ls.maxHp == 1 ? '-' : 'x ${ls.maxHp}'),
            cell(ls.maxHp == 1 ? '-' : 'x ${_truncateNumber(ls.maxHp * ls.maxHp)}'),
          ]),
          TableRow(children: [
            cell(loc.monsterInfoAtk),
            cell(ls.maxAtk == 1 ? '-' : 'x ${ls.maxAtk}'),
            cell(ls.maxAtk == 1 ? '-' : 'x ${_truncateNumber(ls.maxAtk * ls.maxAtk)}'),
          ]),
          TableRow(children: [
            cell(loc.monsterInfoRcv),
            cell(ls.maxRcv == 1 ? '-' : 'x ${ls.maxRcv}'),
            cell(ls.maxRcv == 1 ? '-' : 'x ${_truncateNumber(ls.maxRcv * ls.maxRcv)}'),
          ]),
          TableRow(children: [
            cell(loc.monsterInfoShield),
            cell(ls.maxShield == 0 ? '-' : '${ls.maxShield * 100} %'),
            cell(ls.maxShield == 0
                ? '-'
                : '${_truncateNumber(100.0 * (1 - pow(1 - ls.maxShield, 2)))} %'),
          ]),
        ],
      ),
    );
  }
}

TableCell cell(String text) {
  return widgetCell(Text(text, textAlign: TextAlign.center));
}

TableCell emptyCell() {
  return TableCell(child: Container());
}

TableCell numCell(num value) {
  return cell(NumberFormat.decimalPattern().format(value.toInt()));
}

TableCell widgetCell(Widget widget) {
  return TableCell(
    child: Padding(
      padding: EdgeInsets.all(4),
      child: widget,
    ),
    verticalAlignment: TableCellVerticalAlignment.middle,
  );
}
