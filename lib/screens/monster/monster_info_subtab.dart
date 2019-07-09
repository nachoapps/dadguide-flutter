import 'package:async/async.dart';
import 'package:dadguide2/components/images.dart';
import 'package:dadguide2/data/database.dart';
import 'package:dadguide2/data/tables.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MonsterDetailArgs {
  static const routeName = '/monsterDetail';
  final int monsterId;

  MonsterDetailArgs(this.monsterId);
}

class MonsterDetailScreen extends StatefulWidget {
  final MonsterDetailArgs _args;

  MonsterDetailScreen(this._args);

  @override
  _MonsterDetailScreenState createState() => _MonsterDetailScreenState(_args);
}

class _MonsterDetailScreenState extends State<MonsterDetailScreen> {
  final MonsterDetailArgs _args;
  final _memoizer = AsyncMemoizer<FullMonster>();

  _MonsterDetailScreenState(this._args);

  @override
  Widget build(BuildContext context) {
    print('adding a monsterdetail');
    return ChangeNotifierProvider(
      builder: (context) => MonsterDetailSearchState(),
      child: Column(
        children: <Widget>[
          MonsterDetailBar(),
          Expanded(child: SingleChildScrollView(child: _retrieveMonster())),
          MonsterDetailOptionsBar(),
        ],
      ),
    );
  }

  FutureBuilder<FullMonster> _retrieveMonster() {
    var dataFuture = _memoizer.runOnce(() async {
      var database = await DatabaseHelper.instance.database;
      return database.fullMonster(_args.monsterId);
    }).catchError((ex) {
      print(ex);
    });

    return FutureBuilder<FullMonster>(
        future: dataFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            print('no data!');
            return Center(child: CircularProgressIndicator());
          }
          print('got monster data!');

          return MonsterDetailContents(snapshot.data);
        });
  }
}

class MonsterDetailContents extends StatelessWidget {
  final FullMonster _data;

  const MonsterDetailContents(this._data, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MonsterDetailPortrait(_data),
        Divider(),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MonsterDetailHeader(_data),
              MonsterStatTable(_data),
              Text('+297 & fully awoken'),
              MonsterStatTable(_data),
              Text('Stat Bonus when assisting'),
              MonsterStatTable(_data),
              Text('Available Killer Awoken'),
            ],
          ),
        ),
      ],
    );
  }
}

class MonsterDetailPortrait extends StatelessWidget {
  final FullMonster _data;

  const MonsterDetailPortrait(this._data, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 5 / 3,
      child: Stack(children: [
        portraitImage(_data.monster.monsterId),
        Positioned(
          left: 10,
          top: 10,
          child: new Icon(Icons.autorenew),
        ),
        Positioned.fill(
          child: MonsterDetailPortraitAwakenings(_data),
        ),
        Positioned(
          left: 10,
          bottom: 4,
          child: Icon(Icons.chevron_left),
        ),
        Positioned(
          right: 10,
          bottom: 4,
          child: Icon(Icons.chevron_right),
        ),
      ]),
    );
  }
}

class MonsterDetailPortraitAwakenings extends StatelessWidget {
  final FullMonster _data;

  const MonsterDetailPortraitAwakenings(this._data, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, right: 10, bottom: 30),
      child: Align(
        alignment: Alignment.topRight,
        child: LayoutBuilder(
          builder: (context, constraints) {
            var maxHeight = constraints.biggest.height / 9;
            return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                if (_data.superAwakenings.isNotEmpty)
                  Column(
                    children: [
                      for (var a in _data.superAwakenings)
                        awakeningContainer(a.awakeningId, size: maxHeight),
                    ],
                  ),
                if (_data.awakenings.isNotEmpty)
                  Column(
                    children: [
                      for (var a in _data.awakenings)
                        awakeningContainer(a.awokenSkillId, size: maxHeight),
                    ],
                  )
              ],
            );
          },
        ),
      ),
    );
  }
}

class MonsterDetailHeader extends StatelessWidget {
  final FullMonster _data;

  const MonsterDetailHeader(this._data, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var rarity = _data.monster.rarity;
    var topRightText = '★' * rarity + '($rarity) / Cost ${_data.monster.cost}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        iconContainer(_data.monster.monsterId),
        SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DefaultTextStyle(
                style: Theme.of(context).textTheme.caption,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('No. ${_data.monster.monsterNoNa}'),
                    Text(topRightText),
                  ],
                ),
              ),
              Text(_data.monster.nameNa, style: Theme.of(context).textTheme.title),
              Text(_data.monster.nameJp, style: Theme.of(context).textTheme.body1),
              Row(children: [
                Text(_data.monster.type1Id.toString()),
                SizedBox(width: 4),
                Text(_data.monster.type2Id.toString()),
                SizedBox(width: 4),
                Text(_data.monster.type3Id.toString()),
              ])
            ],
          ),
        )
      ],
    );
  }
}

class MonsterDetailBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      child: Row(
        children: <Widget>[
          Icon(Icons.chevron_left),
          Expanded(
            child: TextField(
              decoration: InputDecoration(prefixIcon: Icon(Icons.search)),
            ),
          ),
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

class MonsterDetailOptionsBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          dummyIconButton(context, Icons.compare_arrows, 'Compare Monster'),
          dummyIconButton(context, Icons.live_tv, 'YT Link'),
          dummyIconButton(context, Icons.save_alt, 'Save view'),
        ],
      ),
    );
  }
}

class MonsterDetailSearchState with ChangeNotifier {}

TableCell cell(String text) {
  return TableCell(child: Padding(padding: EdgeInsets.all(4), child: Center(child: Text(text))));
}

TableCell numCell(num value) {
  return cell(value.toString());
}

class MonsterStatTable extends StatelessWidget {
  final FullMonster _data;

  const MonsterStatTable(this._data, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.caption,
      child: Table(
//        defaultColumnWidth: FractionColumnWidth(1.0),
//        defaultColumnWidth: FlexColumnWidth(),
        // This sucks, bug.
        defaultColumnWidth: FixedColumnWidth(60),
        border: TableBorder.all(width: 1.0, color: Colors.black26),
        children: [
          TableRow(children: [
            cell('Lv.'),
            cell('HP'),
            cell('ATK'),
            cell('RCV'),
            cell('WAVG'),
            cell('EXP'),
          ]),
          TableRow(children: [
            numCell(1),
            numCell(_data.monster.hpMin),
            numCell(_data.monster.atkMin),
            numCell(_data.monster.rcvMin),
            numCell(0),
            numCell(0),
          ]),
          TableRow(children: [
            numCell(_data.monster.level),
            numCell(_data.monster.hpMax),
            numCell(_data.monster.atkMax),
            numCell(_data.monster.rcvMax),
            numCell(0),
            numCell(_data.monster.exp),
          ]),
        ],
      ),
    );
  }
}
