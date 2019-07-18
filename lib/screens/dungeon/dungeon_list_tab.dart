import 'package:dadguide2/components/icons.dart';
import 'package:dadguide2/components/images.dart';
import 'package:dadguide2/components/navigation.dart';
import 'package:dadguide2/components/text_input.dart';
import 'package:dadguide2/data/data_objects.dart';
import 'package:dadguide2/data/tables.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dungeon_search_bloc.dart';

class DungeonTab extends StatelessWidget {
  DungeonTab({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('adding a DungeonTab');
    return ChangeNotifierProvider(
      builder: (context) => DungeonDisplayState(),
      child: Column(children: <Widget>[
        DungeonSearchBar(),
        Expanded(child: DungeonList()),
        DungeonDisplayOptionsBar(),
      ]),
    );
  }
}

class DungeonList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var displayState = Provider.of<DungeonDisplayState>(context);
    return StreamBuilder<List<ListDungeon>>(
        stream: displayState.searchBloc.searchResults,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
            return Center(child: Icon(Icons.error));
          }
          if (!snapshot.hasData) {
            print('no data!');
            return Center(child: CircularProgressIndicator());
          }

          var data = snapshot.data;
          if (data == null) {
            print('null data!');
            return Center(child: CircularProgressIndicator());
          }

          print('got data! ${data.length}');

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) => DungeonListRow(data[index]),
          );
        });
  }
}

class DungeonSearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<DungeonDisplayState>(context);
    var searchText = controller.searchArgs.text;
    return TopTextInputBar(
      searchText,
      'Search: Dungeon name',
      InkWell(
        child: Icon(Icons.clear_all),
        onTap: () => Navigator.of(context).maybePop(),
      ),
      InkWell(
        child: Icon(Icons.cancel),
        onTap: () => controller.clearSearch(),
      ),
      (t) => controller.searchText = t,
      key: ValueKey(searchText),
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
  final searchBloc = DungeonSearchBloc();
  final searchArgs = DungeonSearchArgs();

  DungeonType _selectedType = DungeonType.special;
  DungeonSort _customSort = DungeonSort();

  DungeonType get selectedType => _selectedType;
  DungeonSort get customSort => _customSort;

  set searchText(String text) {
    searchArgs.text = text;
    searchBloc.search(searchArgs);
    notifyListeners();
  }

  void clearSearch() {
    searchText = '';
  }

  set selectedType(DungeonType value) {
    _selectedType = value;
    notifyListeners();
  }
}

class DungeonListRow extends StatelessWidget {
  final ListDungeon _model;
  const DungeonListRow(this._model, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var d = _model.dungeon;
    var m = _model.iconMonster;
    return InkWell(
      onTap: goToDungeonFn(context, d.dungeonId, 0),
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          child: Row(
            children: <Widget>[
              PadIcon(d.iconId),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DefaultTextStyle(
                        style: Theme.of(context).textTheme.caption,
                        child: Row(children: [
                          Text(d.nameJp),
                          Spacer(),
                          typeContainer(m?.type1Id, size: 18, leftPadding: 4),
                          typeContainer(m?.type2Id, size: 18, leftPadding: 4),
                          typeContainer(m?.type3Id, size: 18, leftPadding: 4),
                        ])),
                    Text(d.nameNa),
                    DefaultTextStyle(
                      style: Theme.of(context).textTheme.caption,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconAndText(DadGuideIcons.mp, _model.maxAvgMp?.toString()),
                          SizedBox(width: 8),
                          IconAndText(DadGuideIcons.srank, _model.maxScore?.toString()),
                          Spacer(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}

class IconAndText extends StatelessWidget {
  final Widget _icon;
  final String _text;

  IconAndText(this._icon, this._text);

  @override
  Widget build(BuildContext context) {
    if (_text == null) return Container(width: 0.0, height: 0.0);

    return Row(children: [
      _icon,
      Text(_text, style: Theme.of(context).textTheme.caption),
    ]);
  }
}
