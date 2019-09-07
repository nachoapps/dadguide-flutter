import 'package:dadguide2/components/images.dart';
import 'package:dadguide2/components/navigation.dart';
import 'package:dadguide2/components/text_input.dart';
import 'package:dadguide2/data/data_objects.dart';
import 'package:dadguide2/data/tables.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fimber/flutter_fimber.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';

import 'monster_search_bloc.dart';

/// Displays the search bar, list of monsters, and display options toggles.
class MonsterTab extends StatelessWidget {
  MonsterTab({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MonsterDisplayState>(
      builder: (_) => MonsterDisplayState(),
      child: Column(children: [
        MonsterSearchBar(),
        Expanded(child: MonsterList()),
        MonsterDisplayOptionsBar(),
      ]),
    );
  }
}

/// Displays the list of monsters retrieved from the database based on the search/sort options.
class MonsterList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var displayState = Provider.of<MonsterDisplayState>(context);
    return StreamBuilder<List<ListMonster>>(
        stream: displayState.searchBloc.searchResults,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            Fimber.e('Failed to display monster list', ex: snapshot.error);
            return Center(child: Icon(Icons.error));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: CircularProgressIndicator());
          }

          var data = snapshot.data;
          if (displayState.pictureMode) {
            return GridView.builder(
              itemCount: data.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.all(2.0),
                child: PadIcon(
                  data[index].monster.monsterId,
                  monsterLink: true,
                ),
              ),
            );
          } else {
            return ListView.separated(
              itemCount: data.length,
              separatorBuilder: (context, index) => Divider(height: 0),
              itemBuilder: (context, index) => MonsterListRow(data[index]),
            );
          }
        });
  }
}

/// Top bar in the monster list view; allows the user to search by name/id.
class MonsterSearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<MonsterDisplayState>(context);
    var searchText = controller.searchArgs.text;
    return TopTextInputBar(
      searchText,
      'Search: Monster Name/No.',
//      Not supporting filter yet
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

/// Bottom bar in the monster list view; allows the user to select display options.
class MonsterDisplayOptionsBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<MonsterDisplayState>(context);
    return Material(
      color: Colors.grey[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
//          Not supporting favorites yet
//          IconButton(
//            icon: Icon(Icons.star_border),
//            color: controller.favoritesOnly ? Colors.amber : Colors.black,
//            onPressed: () => controller.favoritesOnly = !controller.favoritesOnly,
//          ),
          IconButton(
            icon: Icon(Foundation.getIconData('burst-new')),
            color: controller.sortNew ? Colors.amber : Colors.black,
            onPressed: () => controller.sortNew = !controller.sortNew,
          ),
          IconButton(
            icon: Icon(SimpleLineIcons.getIconData('picture')),
            color: controller.pictureMode ? Colors.amber : Colors.black,
            onPressed: () => controller.pictureMode = !controller.pictureMode,
          ),
//          Not supporting sort yet
//          IconButton(
//            icon: Icon(Icons.sort),
//            color: controller.useCustomSort ? Colors.amber : Colors.black,
//            onPressed: () => controller.useCustomSort = !controller.useCustomSort,
//          ),
          IconButton(
            icon: Icon(MaterialCommunityIcons.getIconData('star-box-outline')),
            color: controller.showAwakenings ? Colors.amber : Colors.black,
            onPressed: () => controller.showAwakenings = !controller.showAwakenings,
          ),
        ],
      ),
    );
  }
}

/// Placeholder for monster sort order.
class MonsterSort {}

/// Intermediary between monster list model and the UI.
class MonsterDisplayState with ChangeNotifier {
  final searchBloc = MonsterSearchBloc();
  final searchArgs = MonsterSearchArgs();

  bool _favoritesOnly = false;
  bool _sortNew = false;
  bool _pictureMode = false;
  bool _useCustomSort = false;
  MonsterSort _customSort = MonsterSort();
  bool _showAwakenings = false;

  set searchText(String text) {
    searchArgs.text = text?.trim();
    searchBloc.search(searchArgs);
    notifyListeners();
  }

  void clearSearch() {
    searchText = '';
  }

  bool get favoritesOnly => _favoritesOnly;
  bool get sortNew => _sortNew;
  bool get pictureMode => _pictureMode;
  bool get useCustomSort => _useCustomSort;
  MonsterSort get customSort => _customSort;
  bool get showAwakenings => _showAwakenings;

  set showAwakenings(bool value) {
    _showAwakenings = value;
    notifyListeners();
  }

  set customSort(MonsterSort value) {
    _customSort = value;
    notifyListeners();
  }

  set useCustomSort(bool value) {
    _useCustomSort = value;
    notifyListeners();
  }

  set pictureMode(bool value) {
    _pictureMode = value;
    notifyListeners();
  }

  set sortNew(bool value) {
    _sortNew = value;
    notifyListeners();
  }

  set favoritesOnly(bool value) {
    _favoritesOnly = value;
    notifyListeners();
  }
}

/// Item representing a monster in the monster list.
class MonsterListRow extends StatelessWidget {
  final ListMonster _model;
  const MonsterListRow(this._model, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);
    var displayState = Provider.of<MonsterDisplayState>(context);
    var textTheme = Theme.of(context).textTheme;
    var m = _model.monster;
    var as = _model.activeSkill;

    var upperRightText = '${loc.monsterListMp(m.sellMp)} / ⭐${m.rarity}';
    if (as != null) {
      upperRightText += ' / S${as.turnMax}→${as.turnMin}';
    }

    return InkWell(
      onTap: goToMonsterFn(context, m.monsterId),
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PadIcon(m.monsterId, inheritable: m.inheritable),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DefaultTextStyle(
                        style: textTheme.caption,
                        child: Row(children: [
                          Text(loc.monsterListNo(m.monsterNoJp)),
                          Spacer(),
                          Text(upperRightText),
                        ])),
                    FittedBox(alignment: Alignment.centerLeft, child: Text(_model.name())),
                    DefaultTextStyle(
                      style: textTheme.caption,
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(loc.monsterListLevel(m.level)),
                        Text(loc.monsterListHp(m.hpMax)),
                        Text(loc.monsterListAtk(m.atkMax)),
                        Text(loc.monsterListRcv(m.rcvMax)),
                        Text(loc.monsterListWeighted(_weighted(m.hpMax, m.atkMax, m.rcvMax))),
                      ]),
                    ),
                    if (m.limitMult != null && m.limitMult > 0)
                      DefaultTextStyle(
                        style: textTheme.caption,
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text(loc.monsterListLimitBreak(100 + m.limitMult)),
                          Text(loc.monsterListWeighted(_weighted(m.hpMax, m.atkMax, m.rcvMax,
                              limitMult: 100 + m.limitMult))),
                        ]),
                      ),
                    if (displayState.showAwakenings && _model.awakenings.isNotEmpty)
                      Row(children: [
                        for (var awakening in _model.awakenings)
                          Padding(
                              padding: EdgeInsets.only(right: 2),
                              child: awakeningContainer(awakening.awokenSkillId, size: 16))
                      ]),
                    if (displayState.showAwakenings && _model.superAwakenings.isNotEmpty)
                      Row(children: [
                        for (var awakening in _model.superAwakenings)
                          Padding(
                              padding: EdgeInsets.only(right: 2),
                              child: awakeningContainer(awakening.awokenSkillId, size: 16)),
                      ]),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}

int _weighted(num hp, num atk, num rcv, {limitMult: 100}) =>
    (hp / 10 + atk / 5 + rcv / 3) * limitMult ~/ 100;
