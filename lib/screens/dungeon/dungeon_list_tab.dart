import 'package:dadguide2/components/enums.dart';
import 'package:dadguide2/components/text_input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dungeon_list.dart';
import 'dungeon_search_bloc.dart';

class DungeonTab extends StatelessWidget {
  DungeonTab({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('adding a DungeonTab');
    return ChangeNotifierProvider(
      key: UniqueKey(),
      builder: (context) => DungeonDisplayState(DungeonTabKey.special),
      child: Column(children: <Widget>[
        DungeonSearchBar(),
        Expanded(child: DungeonList(key: UniqueKey())),
        DungeonDisplayOptionsBar(),
      ]),
    );
  }
}

class DungeonSearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<DungeonDisplayState>(context);
    var searchText = controller.searchText;
    return TopTextInputBar(
      searchText,
      'Search: Dungeon name',
//    Not supporting filter yet yet
//      InkWell(
//        child: Icon(Icons.clear_all),
//        onTap: () => Navigator.of(context).maybePop(),
//      ),
      Container(),
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
          _createBottomButton(controller, DungeonTabKey.special, 'Special'),
          _createBottomButton(controller, DungeonTabKey.normal, 'Normal'),
          _createBottomButton(controller, DungeonTabKey.technical, 'Technical'),
          _createBottomButton(controller, DungeonTabKey.multiranking, 'Multi/Rank'),
        ],
      ),
    );
  }

  Widget _createBottomButton(DungeonDisplayState controller, DungeonTabKey tab, String name) {
    return FlatButton(
      onPressed: () => controller.tab = tab,
      child: Text(name),
      textColor: controller.tab == tab ? Colors.amber : Colors.black,
    );
  }
}
