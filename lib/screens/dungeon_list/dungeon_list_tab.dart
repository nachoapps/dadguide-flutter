import 'package:dadguide2/components/models/enums.dart';
import 'package:dadguide2/components/notifications/tracking.dart';
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
    return MultiProvider(
      key: UniqueKey(),
      providers: [
        ChangeNotifierProvider(create: (_) => DungeonDisplayState(DungeonTabKey.special)),
        ChangeNotifierProvider(create: (_) => TrackingNotifier()),
      ],
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: AppBar(flexibleSpace: DungeonSearchBar()),
        ),
        body: DungeonList(key: UniqueKey()),
        bottomNavigationBar: DungeonDisplayOptionsBar(),
        resizeToAvoidBottomInset: false, // prevents buttons from moving when keyboard is open
      ),
    );
  }
}

/// Top bar in the dungeon tab, contains the search bar and 'clear' widget. Eventually will contain
/// the dungeon series filter.
class DungeonSearchBar extends StatelessWidget {
  final textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final loc = DadGuideLocalizations.of(context);
    final controller = Provider.of<DungeonDisplayState>(context, listen: false);
    textController.text = controller.searchText;

    return TopTextInputBar(
      loc.dungeonSearchHint,
      Container(),
      InkWell(
        child: Icon(Icons.cancel),
        onTap: () {
          controller.clearSearch();
          textController.text = '';
          FocusScope.of(context).requestFocus(FocusNode());
        },
      ),
      controller: textController,
      onSubmitted: (t) => searchIfDifferent(controller, t as String),
      onChanged: (t) => searchIfDifferent(controller, t as String),
      key: UniqueKey(),
    );
  }

  void searchIfDifferent(DungeonDisplayState controller, String t) {
    if (t != controller.searchText) {
      controller.searchText = t;
    }
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
