import 'package:async/async.dart';
import 'package:dadguide2/components/icons.dart';
import 'package:dadguide2/components/images.dart';
import 'package:dadguide2/data/database.dart';
import 'package:dadguide2/data/tables.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DungeonDetailArgs {
  static const routeName = '/dungeonDetail';
  final int dungeonId;
  final int subDungeonId;

  DungeonDetailArgs(this.dungeonId, this.subDungeonId);
}

class DungeonDetailScreen extends StatefulWidget {
  final DungeonDetailArgs args;

  DungeonDetailScreen(this.args);

  @override
  _DungeonDetailScreenState createState() => _DungeonDetailScreenState(args);
}

class _DungeonDetailScreenState extends State<DungeonDetailScreen> {
  final DungeonDetailArgs _args;
  final _memoizer = AsyncMemoizer<FullDungeon>();

  _DungeonDetailScreenState(this._args);

  @override
  Widget build(BuildContext context) {
    print('adding a dungeondetail for ${_args.dungeonId}');
    return ChangeNotifierProvider(
      builder: (context) => DungeonDetailSearchState(),
      child: Column(
        children: <Widget>[
          DungeonDetailActionsBar(),
          Expanded(child: SingleChildScrollView(child: _retrieveDungeon())),
          DungeonDetailOptionsBar(),
        ],
      ),
    );
  }

  FutureBuilder<FullDungeon> _retrieveDungeon() {
    var dataFuture = _memoizer.runOnce(() async {
      var database = await DatabaseHelper.instance.database;
      return database.lookupFullDungeon(_args.dungeonId);
    }).catchError((ex) {
      print(ex);
    });

    return FutureBuilder<FullDungeon>(
        future: dataFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            print('no dungeon data!');
            return Center(child: CircularProgressIndicator());
          }
          print('got dungeon data!');

          return DungeonDetailContents(snapshot.data);
        });
  }
}

class DungeonDetailContents extends StatelessWidget {
  final FullDungeon _data;

  const DungeonDetailContents(this._data, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DungeonHeader(_data),
        DungeonSubHeader(_data.selectedSubDungeon),
      ],
    );
  }
}

class DungeonHeader extends StatelessWidget {
  final FullDungeon _model;

  const DungeonHeader(this._model, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var m = _model;
    var bossMonster = m.selectedSubDungeon.bossEncounter?.monster;
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Row(
          children: <Widget>[
            iconContainer(_model.dungeon.iconId),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      SizedBox(height: 18),
                      if (bossMonster != null)
                        Row(children: <Widget>[
                          typeContainer(bossMonster.type1Id, leftPadding: 2, size: 18),
                          typeContainer(bossMonster.type2Id, leftPadding: 2, size: 18),
                          typeContainer(bossMonster.type3Id, leftPadding: 2, size: 18),
                        ])
                    ],
                  ),
                  Text(m.dungeon.nameNa),
                  DefaultTextStyle(
                      style: Theme.of(context).textTheme.caption,
                      child: Row(children: [
                        DadGuideIcons.mp,
                        Text(m.selectedSubDungeon.mpText()),
                      ])),
                ],
              ),
            ),
          ],
        ));
  }
}

class DungeonSubHeader extends StatelessWidget {
  final FullSubDungeon _model;

  const DungeonSubHeader(this._model, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var m = _model;
    return Container(
      color: Colors.grey[300],
      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FittedBox(
                    alignment: Alignment.centerLeft,
                    child: Text(m.subDungeon.nameNa),
                  ),
                  FittedBox(
                    alignment: Alignment.centerLeft,
                    child: Text(m.subDungeon.nameJp),
                  ),
                ],
              ),
              Spacer(),
              for (var rewardIconId in m.rewardIconIds) iconContainer(rewardIconId, size: 32)
            ],
          ),
          // Probably should be a row with col, sizedbox, col
          DefaultTextStyle(
            style: Theme.of(context).textTheme.caption,
            child: Row(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Stamina: ${m.subDungeon.stamina}'),
                    Text('Battles: ${m.subDungeon.floors}'),
                  ],
                ),
                SizedBox(width: 20),
                Expanded(child: ExpCoinTable(m.subDungeon)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ExpCoinTable extends StatelessWidget {
  final SubDungeon sd;
  const ExpCoinTable(this.sd, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Table(
      children: [
        TableRow(children: [
          cell(''),
          cell('Min'),
          cell('Max'),
          cell('Avg'),
          cell('Avg/Stam'),
        ]),
        TableRow(children: [
          cell('EXP'),
          cell(sd.expMin.toString()),
          cell(sd.expMax.toString()),
          cell(sd.expAvg.toString()),
          cell((sd.expAvg ~/ sd.stamina).toString()),
        ]),
        TableRow(children: [
          cell('Coin'),
          cell(sd.coinMin.toString()),
          cell(sd.coinMax.toString()),
          cell(sd.coinAvg.toString()),
          cell((sd.coinAvg ~/ sd.stamina).toString()),
        ]),
      ],
    );
  }

  Widget cell(String text) => TableCell(child: Text(text, textAlign: TextAlign.end));
}

class DungeonDetailActionsBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      child: Row(
        children: <Widget>[
          Icon(Icons.chevron_left),
          Spacer(),
          Icon(Icons.star_border),
        ],
      ),
    );
  }
}

IconButton dummyIconButton(BuildContext context, IconData icon, String title) {
  return IconButton(
      icon: Icon(icon),
      onPressed: () {
        Scaffold.of(context).removeCurrentSnackBar();
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('$title not implemented yet'),
        ));
      });
}

class DungeonDetailOptionsBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          dummyIconButton(context, Icons.format_list_bulleted, 'Difficulty'),
          dummyIconButton(context, Icons.live_tv, 'YT Link'),
        ],
      ),
    );
  }
}

class DungeonDetailSearchState with ChangeNotifier {}
