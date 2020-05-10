import 'package:dadguide2/components/images/images.dart';
import 'package:dadguide2/components/models/data_objects.dart';
import 'package:dadguide2/components/ui/navigation.dart';
import 'package:dadguide2/data/tables.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fimber/flutter_fimber.dart';

/// Displays a row for every available SubDungeon.
class SubDungeonList extends StatelessWidget {
  final FullDungeon data;

  SubDungeonList(this.data);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var sd in data.subDungeons)
          SubDungeonRow(sd, sd.subDungeonId == data.selectedSubDungeon.subDungeon.subDungeonId),
      ],
    );
  }
}

/// A row containing the boss icon, floor name, xp/stam coin/stam, and (optional) reward.
class SubDungeonRow extends StatelessWidget {
  final SubDungeon data;
  final bool selected;
  final LanguageSelector name;

  SubDungeonRow(this.data, this.selected) : name = LanguageSelector.name(data);

  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);

    var rewards = [];
    try {
      if (data.rewardIconIds != null) {
        rewards = data.rewardIconIds.split(',').map(int.parse).toList();
      }
    } catch (ex) {
      Fimber.w('Failed to parse rewards', ex: ex);
    }

    var expStam = data.stamina == 0 ? 0 : (data.expAvg ?? 0) ~/ data.stamina;
    var coinStam = data.stamina == 0 ? 0 : (data.coinAvg ?? 0) ~/ data.stamina;

    var themeData = Theme.of(context);
    var titleStyle = themeData.textTheme.bodyText2;
    if (selected) {
      titleStyle = titleStyle.copyWith(color: themeData.primaryColor);
    }

    return InkWell(
      onTap: () {
        Navigator.of(context).pushReplacementNamed(
          DungeonDetailArgs.routeName,
          result: data,
          arguments: DungeonDetailArgs(data.dungeonId, data.subDungeonId),
        );
      },
      child: Container(
        decoration: BoxDecoration(border: Border(bottom: BorderSide(width: .1))),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            children: [
              PadIcon(data.iconId),
              SizedBox(width: 8),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(name(), style: titleStyle)),
                  SizedBox(height: 2),
                  DefaultTextStyle(
                    style: themeData.textTheme.caption,
                    child: Row(
                      children: [
                        Text(loc.dungeonListExpPerStam(expStam)),
                        SizedBox(width: 8),
                        Text(loc.dungeonListCoinPerStam(coinStam)),
                      ],
                    ),
                  ),
                ],
              )),
              SizedBox(width: 6),
              for (var rewardId in rewards)
                Padding(padding: EdgeInsets.only(left: 2), child: PadIcon(rewardId, size: 36)),
            ],
          ),
        ),
      ),
    );
  }
}
