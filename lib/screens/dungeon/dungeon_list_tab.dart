import 'package:async/async.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dadguide2/data/database.dart';
import 'package:dadguide2/data/tables.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DungeonTab extends StatefulWidget {
  DungeonTab({Key key}) : super(key: key);

  @override
  _DungeonTabState createState() => _DungeonTabState();
}

class _DungeonTabState extends State<DungeonTab> {
  final _memoizer = AsyncMemoizer<List<Dungeon>>();

  @override
  Widget build(BuildContext context) {
    print('adding a DungeonTab');
    return ChangeNotifierProvider(
      builder: (context) => DungeonDisplayState(),
      child: Column(children: <Widget>[
        DungeonSearchBar(),
        Expanded(child: _searchResults()),
        DungeonDisplayOptionsBar(),
      ]),
    );
  }

  FutureBuilder<List<Dungeon>> _searchResults() {
    var dataFuture = _memoizer.runOnce(() async {
      var database = await DatabaseHelper.instance.database;
      return database.allDungeons;
    });

    return FutureBuilder<List<Dungeon>>(
        future: dataFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            print('no data!');
            return Center(child: CircularProgressIndicator());
          }

          print('got data! ${snapshot.data.length}');

          return ListView(
              children: snapshot.data.map((dungeon) {
            return DungeonListRow(dungeon);
          }).toList());
        });
  }
}

class DungeonSearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<DungeonDisplayState>(context);
    return Container(
      color: Colors.blue,
      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      child: Row(
        children: <Widget>[
          Icon(Icons.clear_all),
          Expanded(child: TextField()),
          Icon(Icons.cancel),
        ],
      ),
    );
  }
}

class DungeonDisplayOptionsBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<DungeonDisplayState>(context);
    return Material(
      color: Colors.grey[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          FlatButton(
            onPressed: () => controller.selectedType = DungeonType.special,
            child: Text('Special'),
            textColor: controller.selectedType == DungeonType.special ? Colors.amber : Colors.black,
          ),
          FlatButton(
            onPressed: () => controller.selectedType = DungeonType.normal,
            child: Text('Normal'),
            textColor: controller.selectedType == DungeonType.normal ? Colors.amber : Colors.black,
          ),
          FlatButton(
            onPressed: () => controller.selectedType = DungeonType.technical,
            child: Text('Technical'),
            textColor:
                controller.selectedType == DungeonType.technical ? Colors.amber : Colors.black,
          ),
          FlatButton(
            onPressed: () => controller.selectedType = DungeonType.multiplayer,
            child: Text('Multi'),
            textColor:
                controller.selectedType == DungeonType.multiplayer ? Colors.amber : Colors.black,
          ),
        ],
      ),
    );
  }
}

class DungeonSort {}

enum DungeonType { special, normal, technical, multiplayer }

class DungeonDisplayState with ChangeNotifier {
  DungeonType _selectedType = DungeonType.special;
  DungeonSort _customSort = DungeonSort();

  DungeonType get selectedType => _selectedType;
  DungeonSort get customSort => _customSort;

  set selectedType(DungeonType value) {
    _selectedType = value;
    notifyListeners();
  }
}

class DungeonListRow extends StatelessWidget {
  final Dungeon _model;
  const DungeonListRow(this._model, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var m = _model;
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed('/dungeonDetail');
      },
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          child: Row(
            children: <Widget>[
              sizedContainer(CachedNetworkImage(
                placeholder: (context, url) => CircularProgressIndicator(),
                imageUrl: imageUrl(_model),
              )),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DefaultTextStyle(
                        style: Theme.of(context).textTheme.caption,
                        child: Row(children: [
                          Text(m.nameJp),
                          Spacer(),
                          Text('Awakenings here'),
                        ])),
                    Text(m.nameNa),
                    DefaultTextStyle(
                      style: Theme.of(context).textTheme.caption,
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
          )),
    );
  }
}

String imageUrl(Dungeon model) {
  var paddedNo = (model.iconId ?? 0).toString().padLeft(4, '0');
  return 'http://miru.info/padguide/images/icons/icon_$paddedNo.png';
}

Widget sizedContainer(Widget child) {
  return new SizedBox(
    width: 48.0,
    height: 48.0,
    child: new Center(child: child),
  );
}
