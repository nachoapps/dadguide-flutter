import 'package:async/async.dart';
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
                      SizedBox(height: 12),
                      if (m.selectedSubDungeon.bossEncounter != null)
                        for (var a in m.selectedSubDungeon.bossEncounter.awakenings)
                          awakeningContainer(a.awakeningId)
                    ],
                  ),
                  Text(m.dungeon.nameNa),
                  DefaultTextStyle(
                      style: Theme.of(context).textTheme.caption,
                      child: Row(children: [
                        Icon(Icons.add),
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
      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(m.subDungeon.nameNa),
          Text(m.subDungeon.nameJp),
          // Probably should be a row with col, sizedbox, col
          Text('Stamina: ${m.subDungeon.stamina}'),
          Text('Battles: ${m.subDungeon.floors}'),
        ],
      ),
    );
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
