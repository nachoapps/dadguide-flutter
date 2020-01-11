import 'package:dadguide2/components/models/enums.dart';
import 'package:dadguide2/components/ui/text_input.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:dadguide2/theme/style.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dungeon_list.dart';
import 'dungeon_search_bloc.dart';

/// Displays the search bar, dungeon list, and dungeon type selector bar.
class DungeonTab extends StatelessWidget {
  DungeonTab({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      key: UniqueKey(),
      create: (context) => DungeonDisplayState(DungeonTabKey.special),
      child: Column(children: [
        DungeonSearchBar(),
        Expanded(child: DungeonList(key: UniqueKey())),
        DungeonDisplayOptionsBar(),
      ]),
    );
  }
}

/// Top bar in the dungeon tab, contains the search bar and 'clear' widget. Eventually will contain
/// the dungeon series filter.
class DungeonSearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);

    final controller = Provider.of<DungeonDisplayState>(context);
    var searchText = controller.searchText;
    return TopTextInputBar(
      searchText,
      loc.dungeonSearchHint,
//    Not supporting filter yet yet
//      InkWell(
//        child: Icon(Icons.clear_all),
//        onTap: () => Navigator.of(context).maybePop(),
//      ),
      Container(),
      InkWell(
        child: Icon(Icons.cancel),
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
          controller.clearSearch();
        },
      ),
      (t) => controller.searchText = t,
      key: UniqueKey(),
    );
  }
}

/// Bottom bar that allows the user to tab between different dungeon types.
class DungeonDisplayOptionsBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);

    final controller = Provider.of<DungeonDisplayState>(context);
    return Material(
      color: grey(context, 100),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _createBottomButton(controller, DungeonTabKey.special, loc.dungeonTabSpecial, context),
          _createBottomButton(controller, DungeonTabKey.normal, loc.dungeonTabNormal, context),
          _createBottomButton(
              controller, DungeonTabKey.technical, loc.dungeonTabTechnical, context),
          _createBottomButton(
              controller, DungeonTabKey.multiranking, loc.dungeonTabMultiRank, context),
        ],
      ),
    );
  }

  Widget _createBottomButton(
      DungeonDisplayState controller, DungeonTabKey tab, String name, BuildContext context) {
    return FlatButton(
      onPressed: () => controller.tab = tab,
      child: Text(name),
      textColor: controller.tab == tab ? Colors.blue : grey(context, 1000),
    );
  }
}
