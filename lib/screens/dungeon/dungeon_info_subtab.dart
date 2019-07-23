import 'package:async/async.dart';
import 'package:dadguide2/components/email.dart';
import 'package:dadguide2/components/icons.dart';
import 'package:dadguide2/components/images.dart';
import 'package:dadguide2/components/navigation.dart';
import 'package:dadguide2/data/data_objects.dart';
import 'package:dadguide2/data/database.dart';
import 'package:dadguide2/data/tables.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';

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
      return database.dungeonsDao.lookupFullDungeon(_args.dungeonId);
    }).catchError((ex) {
      print(ex);
    });

    return FutureBuilder<FullDungeon>(
        future: dataFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
            return Center(child: Icon(Icons.error));
          }
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
        for (var battle in _data.selectedSubDungeon.battles) DungeonBattle(battle),
        MailIssues(_data),
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
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          children: <Widget>[
            PadIcon(_model.dungeon.iconId),
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
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
              for (var rewardIconId in m.rewardIconIds)
                PadIcon(rewardIconId, size: 32, monsterLink: true)
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
    if (sd.expMin == null) return Container(width: 0.0, height: 0.0);

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
          intCell(sd.expMin),
          intCell(sd.expMax),
          intCell(sd.expAvg),
          intCell((sd.expAvg ?? 0 ~/ sd.stamina)),
        ]),
        TableRow(children: [
          cell('Coin'),
          intCell(sd.coinMin),
          intCell(sd.coinMax),
          intCell(sd.coinAvg),
          intCell((sd.coinAvg ?? 0 ~/ sd.stamina)),
        ]),
      ],
    );
  }

  Widget cell(String text) => TableCell(child: Text(text, textAlign: TextAlign.end));
  Widget intCell(int value) =>
      TableCell(child: Text(value?.toString() ?? '', textAlign: TextAlign.end));
}

class DungeonBattle extends StatelessWidget {
  final Battle _model;

  const DungeonBattle(this._model, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var text = 'Battle ${_model.stage}';
    if (_model.stage == -1) {
      text = 'Invades';
    } else if (_model.stage == 0) {
      text = 'Common Monsters';
    }
    return Column(children: [
      Container(
        color: Colors.grey[400],
        padding: const EdgeInsets.all(4.0),
        child: Row(children: [
          Text(text),
          Spacer(),
          Text('Drop'),
        ]),
      ),
      for (var encounter in _model.encounters) DungeonEncounter(encounter)
    ]);
  }
}

class DungeonEncounter extends StatelessWidget {
  final FullEncounter _model;

  const DungeonEncounter(this._model, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              PadIcon(_model.monster.monsterId, monsterLink: true),
              SizedBox(height: 2),
              MonsterColorBar(_model.monster),
            ],
          ),
          SizedBox(width: 4),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(children: [
                    typeContainer(_model.monster.type1Id, size: 18, leftPadding: 4),
                    typeContainer(_model.monster.type2Id, size: 18, leftPadding: 4),
                    typeContainer(_model.monster.type3Id, size: 18, leftPadding: 4),
                  ]),
                  Text(_model.monster.nameNa),
                  IconTheme(
                    data: new IconThemeData(size: Theme.of(context).textTheme.caption.fontSize),
                    child: DefaultTextStyle(
                        style: Theme.of(context).textTheme.caption,
                        child: Row(
                          children: [
                            item(1, Icons.refresh, _model.encounter.turns),
                            item(3, Feather.getIconData('heart'), _model.encounter.hp),
                            item(3, MaterialCommunityIcons.getIconData('sword'),
                                _model.encounter.atk),
                            item(3, Feather.getIconData('shield'), _model.encounter.defence),
                          ],
                        )),
                  ),
                ]),
          ),
          Column(children: [
            for (var drop in _model.drops) PadIcon(drop.monsterId, size: 24, monsterLink: true)
          ])
        ],
      ),
    );
  }

  Widget item(int flex, IconData iconData, int value) {
//    return Flexible(flex: flex, child: Row(children: [Icon(iconData), Text(value.toString())]));
    return Expanded(flex: flex, child: Row(children: [Icon(iconData), Text(value.toString())]));
//    return Row(children: [Icon(iconData), Text(value.toString())]);
  }
}

class MonsterColorBar extends StatelessWidget {
  final Monster _model;

  const MonsterColorBar(this._model, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: The SizedBox here is a hack because I can't get it to expand properly =(
    return Container(
      decoration: BoxDecoration(border: Border.all()),
      child: Row(
        children: [
          Container(
            color: _colorFor(_model.attribute1Id),
            child: SizedBox(width: 23, height: 6),
          ),
          Container(
            color: _colorFor(_model.attribute2Id ?? _model.attribute1Id),
            child: SizedBox(width: 23, height: 6),
          ),
        ],
      ),
    );
  }

  Color _colorFor(int attributeId) {
    switch (attributeId) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.yellow;
      case 4:
        return Colors.deepPurple;
      default:
        throw 'Unexpected attribute id: $attributeId';
    }
  }
}

class DungeonDetailActionsBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.blue,
        padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Row(
          children: <Widget>[
            SizedBox(
                width: 32,
                height: 32,
                child: InkWell(
                  child: Icon(Icons.chevron_left),
                  onTap: () => Navigator.of(context).pop(),
                )),
            Spacer(),
          ],
        ));
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

class MailIssues extends StatelessWidget {
  final FullDungeon _data;

  const MailIssues(this._data, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => sendDungeonErrorEmail(_data.dungeon, _data.selectedSubDungeon.subDungeon),
      child: Card(
          color: Colors.grey[300],
          child: Row(
            children: [
              Icon(Icons.mail_outline),
              Text('Report incorrect information',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          )),
    );
  }
}
