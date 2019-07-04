import 'package:async/async.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dadguide2/data/database.dart';
import 'package:dadguide2/data/tables.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DungeonDetailScreen extends StatefulWidget {
  final int dungeonId;

  DungeonDetailScreen(this.dungeonId);

  @override
  _DungeonDetailScreenState createState() => _DungeonDetailScreenState(dungeonId);
}

class _DungeonDetailScreenState extends State<DungeonDetailScreen> {
  final int dungeonId;
  final _memoizer = AsyncMemoizer<FullDungeon>();

  _DungeonDetailScreenState(this.dungeonId);

  @override
  Widget build(BuildContext context) {
    print('adding a dungeondetail');
    return ChangeNotifierProvider(
      builder: (context) => DungeonDetailSearchState(),
      child: Column(
        children: <Widget>[
          DungeonDetailBar(),
          Expanded(child: SingleChildScrollView(child: _retrieveDungeon())),
          DungeonDetailOptionsBar(),
        ],
      ),
    );
  }

  FutureBuilder<FullDungeon> _retrieveDungeon() {
    var dataFuture = _memoizer.runOnce(() async {
      var database = await DatabaseHelper.instance.database;
      return database.fullDungeon(dungeonId);
    });

    return FutureBuilder<FullDungeon>(
        future: dataFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            print('no data!');
            return Center(child: CircularProgressIndicator());
          }
          print('got dungeon data!');

          return DungeonDetailContents(snapshot.data);
        });
  }
}

String imageUrl(Dungeon model) {
  var paddedNo = model.dungeonId.toString().padLeft(4, '0');
  return 'http://miru.info/padguide/images/icons/portrait_$paddedNo.png';
}

String imageUrl2(Dungeon model) {
  var paddedNo = model.dungeonId.toString().padLeft(4, '0');
  return 'http://miru.info/padguide/images/icons/icon_$paddedNo.png';
}

class DungeonDetailContents extends StatelessWidget {
  final FullDungeon _data;

  const DungeonDetailContents(this._data, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(imageUrl(_data.dungeon));
    return Column(
      children: [
        DungeonHeader(),
        DungeonSubHeader(),
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
            sizedContainer(CachedNetworkImage(
              placeholder: (context, url) => CircularProgressIndicator(),
              imageUrl: imageUrl(_model.dungeon),
            )),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultTextStyle(
                      style: Theme.of(context).textTheme.overline,
                      child: Row(children: [
                        Text(m.nameJp),
                        Spacer(),
                        Text('Awakenings here'),
                      ])),
                  Text(m.nameNa),
                  DefaultTextStyle(
                    style: Theme.of(context).textTheme.overline,
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('srank'),
                      SizedBox(width: 8),
                      Text('mp'),
                      Spacer(),
                    ]),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}

class DungeonDetailPortrait extends StatelessWidget {
  final FullDungeon _data;

  const DungeonDetailPortrait(this._data, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 5 / 3,
      child: Stack(children: [
        CachedNetworkImage(
          placeholder: (context, url) => CircularProgressIndicator(),
          imageUrl: imageUrl(_data.dungeon),
        ),
        Positioned(
          left: 10,
          top: 10,
          child: new Icon(Icons.autorenew),
        ),
        Positioned(
          right: 10,
          top: 10,
          child: DungeonDetailPortraitAwakenings(_data),
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

class DungeonDetailPortraitAwakenings extends StatelessWidget {
  final FullDungeon _data;

  const DungeonDetailPortraitAwakenings(this._data, {Key key}) : super(key: key);

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

class DungeonDetailHeader extends StatelessWidget {
  final FullDungeon _data;

  const DungeonDetailHeader(this._data, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var rarity = _data.dungeon.rarity;
    var topRightText = '★' * rarity + '($rarity) / Cost ${_data.dungeon.cost}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sizedContainer(
          CachedNetworkImage(
            placeholder: (context, url) => CircularProgressIndicator(),
            imageUrl: imageUrl2(_data.dungeon),
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
                    Text('No. ${_data.dungeon.dungeonNoNa}'),
                    Text(topRightText),
                  ],
                ),
              ),
              Text(_data.dungeon.nameNa, style: Theme.of(context).textTheme.title),
              Text(_data.dungeon.nameJp, style: Theme.of(context).textTheme.body1),
              Row(children: [
                Text(_data.dungeon.type1Id.toString()),
                SizedBox(width: 4),
                Text(_data.dungeon.type2Id.toString()),
                SizedBox(width: 4),
                Text(_data.dungeon.type3Id.toString()),
              ])
            ],
          ),
        )
      ],
    );
  }
}

class DungeonDetailBar extends StatelessWidget {
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

class DungeonDetailOptionsBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          dummyIconButton(context, Icons.compare_arrows, 'Compare Dungeon'),
          dummyIconButton(context, Icons.live_tv, 'YT Link'),
          dummyIconButton(context, Icons.save_alt, 'Save view'),
        ],
      ),
    );
  }
}

class DungeonDetailSearchState with ChangeNotifier {}

TableCell cell(String text) {
  return TableCell(child: Padding(padding: EdgeInsets.all(4), child: Center(child: Text(text))));
}

TableCell numCell(num value) {
  return cell(value.toString());
}

class DungeonStatTable extends StatelessWidget {
  final FullDungeon _data;

  const DungeonStatTable(this._data, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.overline,
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
            cell('Weighted'),
            cell('EXP'),
          ]),
          TableRow(children: [
            numCell(1),
            numCell(_data.dungeon.hpMin),
            numCell(_data.dungeon.atkMin),
            numCell(_data.dungeon.rcvMin),
            numCell(0),
            numCell(0),
          ]),
          TableRow(children: [
            numCell(_data.dungeon.level),
            numCell(_data.dungeon.hpMax),
            numCell(_data.dungeon.atkMax),
            numCell(_data.dungeon.rcvMax),
            numCell(0),
            numCell(_data.dungeon.exp),
          ]),
        ],
      ),
    );
  }
}
