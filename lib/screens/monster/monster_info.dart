import 'package:async/async.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dadguide2/data/database.dart';
import 'package:dadguide2/data/tables.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MonsterDetailScreen extends StatefulWidget {
  final int monsterId;

  MonsterDetailScreen(this.monsterId);

  @override
  _MonsterDetailScreenState createState() => _MonsterDetailScreenState(monsterId);
}

class _MonsterDetailScreenState extends State<MonsterDetailScreen> {
  final int monsterId;
  final _memoizer = AsyncMemoizer<FullMonster>();

  _MonsterDetailScreenState(this.monsterId);

  @override
  Widget build(BuildContext context) {
    print('adding a monsterdetail');
    return ChangeNotifierProvider(
      builder: (context) => MonsterDetailSearchState(),
      child: Column(children: <Widget>[
        MonsterDetailBar(),
        Expanded(child: _retrieveMonster()),
        MonsterDetailOptionsBar(),
      ]),
    );
  }

  FutureBuilder<FullMonster> _retrieveMonster() {
    var dataFuture = _memoizer.runOnce(() async {
      var database = await DatabaseHelper.instance.database;
      return database.fullMonster(monsterId);
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

String imageUrl(MonsterData model) {
  var paddedNo = model.monsterId.toString().padLeft(4, '0');
  return 'http://miru.info/padguide/images/icons/portrait_$paddedNo.png';
}

String imageUrl2(MonsterData model) {
  var paddedNo = model.monsterId.toString().padLeft(4, '0');
  return 'http://miru.info/padguide/images/icons/icon_$paddedNo.png';
}

class MonsterDetailContents extends StatelessWidget {
  final FullMonster _data;

  const MonsterDetailContents(this._data, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(imageUrl(_data.monster));
    return Column(children: [
      MonsterDetailPortrait(_data),
      Divider(),
      MonsterDetailHeader(_data),
      MonsterStatTable(_data),
    ]);
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
        CachedNetworkImage(
          placeholder: (context, url) => CircularProgressIndicator(),
          imageUrl: imageUrl(_data.monster),
        ),
        Positioned(
          left: 10,
          top: 10,
          child: new Icon(Icons.autorenew),
        ),
        Positioned(
          right: 10,
          top: 10,
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
    return Icon(Icons.compare);
  }
}

Widget sizedContainer(Widget child) {
  return new SizedBox(
    width: 48.0,
    height: 48.0,
    child: new Center(child: child),
  );
}

class MonsterDetailHeader extends StatelessWidget {
  final FullMonster _data;

  const MonsterDetailHeader(this._data, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var rarity = _data.monster.rarity;
    var topRightText = '★' * rarity + '($rarity) / Cost ${_data.monster.cost}';

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sizedContainer(
            CachedNetworkImage(
              placeholder: (context, url) => CircularProgressIndicator(),
              imageUrl: imageUrl2(_data.monster),
            ),
          ),
          SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextStyle(
                  style: Theme.of(context).textTheme.overline,
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
                  Text(_data.monster.type1.toString()),
                  SizedBox(width: 4),
                  Text(_data.monster.type2.toString()),
                  SizedBox(width: 4),
                  Text(_data.monster.type3.toString()),
                ])
              ],
            ),
          )
        ],
      ),
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
      color: Colors.grey[100],
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

class MonsterStatTable extends StatelessWidget {
  final FullMonster _data;

  const MonsterStatTable(this._data, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.overline,
      child: Table(
//        defaultColumnWidth: FractionColumnWidth(1.0),
//        defaultColumnWidth: FlexColumnWidth(),
        // This sucks, bug.
        defaultColumnWidth: FixedColumnWidth(50),
        border: TableBorder.all(width: 1.0, color: Colors.black26),

        children: [
          TableRow(children: [
            TableCell(child: Text('Lv.')),
            TableCell(child: Text('HP')),
            TableCell(child: Text('ATK')),
            TableCell(child: Text('RCV')),
            TableCell(child: Text('Weighted')),
            TableCell(child: Text('EXP')),
          ]),
          TableRow(children: [
            TableCell(child: Text('1')),
            TableCell(child: Text(_data.monster.hpMin.toString())),
            TableCell(child: Text(_data.monster.atkMin.toString())),
            TableCell(child: Text(_data.monster.rcvMin.toString())),
            TableCell(child: Text('0?')),
            TableCell(child: Text('0')),
          ])
        ],
      ),
    );
  }
}
