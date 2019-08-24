import 'package:dadguide2/components/images.dart';
import 'package:dadguide2/components/navigation.dart';
import 'package:dadguide2/data/data_objects.dart';
import 'package:dadguide2/data/tables.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fimber/flutter_fimber.dart';

/// Displays a list of the SubDungeons in the Dungeon, which the user can pick from.
class SelectSubDungeonScreen extends StatelessWidget {
  final SubDungeonSelectionArgs args;

  SelectSubDungeonScreen(this.args);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SelectSubDungeonTopBar(),
        Expanded(child: SubDungeonList(args.fullDungeon)),
        SelectSubDungeonBottomBar(),
      ],
    );
  }
}

/// Contains a back button and instructional text.
class SelectSubDungeonTopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.blue,
        padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Row(
          children: [
            SizedBox(
                width: 32,
                height: 32,
                child: InkWell(
                  child: Icon(Icons.chevron_left),
                  onTap: () => Navigator.of(context).pop(),
                )),
            Expanded(child: Center(child: Text('Select Difficulty'))),
            SizedBox(width: 32, height: 32),
          ],
        ));
  }
}

/// Contains a close button; just an alias for the back button.
class SelectSubDungeonBottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.grey,
        padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Row(
          children: [
            SizedBox(
              height: 24,
              child: FlatButton(
                child: Text('Close'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ));
  }
}

/// Displays a row for every available SubDungeon.
class SubDungeonList extends StatelessWidget {
  final FullDungeon data;

  SubDungeonList(this.data);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        for (var sd in data.subDungeons) SubDungeonRow(sd),
      ],
    );
  }
}

/// A row containing the boss icon, floor name, xp/stam coin/stam, and (optional) reward.
class SubDungeonRow extends StatelessWidget {
  final SubDungeon data;

  SubDungeonRow(this.data);

  @override
  Widget build(BuildContext context) {
    var rewards = [];
    try {
      if (data.rewardIconIds != null) {
        rewards = data.rewardIconIds.split(',').map(int.parse).toList();
      }
    } catch (ex) {
      Fimber.w('Failed to parse rewards', ex: ex);
    }

    var expStam = (data.expAvg ?? 0) ~/ data.stamina;
    var coinStam = (data.coinAvg ?? 0) ~/ data.stamina;

    return InkWell(
      onTap: () {
        Navigator.of(context).pop(data);
        Navigator.of(context).pushReplacementNamed(DungeonDetailArgs.routeName,
            arguments: DungeonDetailArgs(data.dungeonId, data.subDungeonId));
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
                children: <Widget>[
                  FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(data.nameNa)),
                  SizedBox(height: 2),
                  DefaultTextStyle(
                    style: Theme.of(context).textTheme.caption,
                    child: Row(
                      children: [
                        Text('Exp/Stam:$expStam'),
                        SizedBox(width: 8),
                        Text('Coin/Stam:$coinStam'),
                      ],
                    ),
                  ),
                ],
              )),
              SizedBox(width: 6),
              for (var rewardId in rewards)
                Padding(padding: EdgeInsets.only(left: 2), child: PadIcon(rewardId)),
            ],
          ),
        ),
      ),
    );
  }
}
