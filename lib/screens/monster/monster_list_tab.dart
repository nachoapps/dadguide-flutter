import 'package:dadguide2/components/config/settings_manager.dart';
import 'package:dadguide2/components/images/images.dart';
import 'package:dadguide2/components/models/data_objects.dart';
import 'package:dadguide2/components/ui/navigation.dart';
import 'package:dadguide2/components/ui/text_input.dart';
import 'package:dadguide2/data/tables.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:dadguide2/screens/monster/monster_sort_modal.dart';
import 'package:dadguide2/theme/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fimber/flutter_fimber.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';

import 'monster_search_bloc.dart';

/// Displays the search bar, list of monsters, and display options toggles.
class MonsterTab extends StatelessWidget {
  final MonsterListArgs args;

  MonsterTab({this.args, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MonsterSearchArgs defaultState =
        args.useArgsFromPrefs ? Prefs.monsterSearchArgs : MonsterSearchArgs.defaults();
    return ChangeNotifierProvider<MonsterDisplayState>(
      create: (_) => MonsterDisplayState(defaultState),
      child: Column(children: [
        MonsterSearchBar(),
        Expanded(child: MonsterList(args.action)),
        MonsterDisplayOptionsBar(),
      ]),
    );
  }
}

/// Displays the list of monsters retrieved from the database based on the search/sort options.
class MonsterList extends StatelessWidget {
  final MonsterListAction action;
  MonsterList(this.action);

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
              itemBuilder: (context, index) => MonsterListRow(data[index], action),
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
    var searchText = controller.searchText;
    return TopTextInputBar(
      searchText,
      'Search: Monster Name/No.',
      InkWell(
        child: Icon(controller.filterSet ? FontAwesome.filter : Feather.filter,
            color: controller.filterSet ? Colors.black : Colors.white),
        onTap: () async {
          await goToFilterMonstersFn(context, controller)();
          controller.doSearch();
        },
      ),
      InkWell(
        child: Icon(Icons.cancel),
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
          controller.clearSearchText();
        },
      ),
      (t) => controller.searchText = t,
      key: UniqueKey(),
    );
  }
}

/// Bottom bar in the monster list view; allows the user to select display options.
class MonsterDisplayOptionsBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<MonsterDisplayState>(context);
    return Material(
      color: grey(context, 100),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: controller.favoritesOnly ? Icon(Icons.star) : Icon(Icons.star_border),
            color: controller.favoritesOnly ? Colors.blue : grey(context, 1000),
            onPressed: () => controller.favoritesOnly = !controller.favoritesOnly,
          ),
          IconButton(
            icon: Icon(Foundation.burst_new),
            color: controller.sortNew ? Colors.blue : grey(context, 1000),
            onPressed: () => controller.sortNew = !controller.sortNew,
          ),
          IconButton(
            icon: Icon(SimpleLineIcons.picture),
            color: controller.pictureMode ? Colors.blue : grey(context, 1000),
            onPressed: () => controller.pictureMode = !controller.pictureMode,
          ),
          IconButton(
            icon: Icon(Icons.sort),
            color: controller.customSort ? Colors.blue : grey(context, 1000),
            onPressed: () => showMonsterSortDialog(context),
          ),
          IconButton(
            icon: Icon(MaterialCommunityIcons.star_box_outline),
            color: controller.showAwakenings ? Colors.blue : grey(context, 1000),
            onPressed: () => controller.showAwakenings = !controller.showAwakenings,
          ),
        ],
      ),
    );
  }
}

/// Item representing a monster in the monster list.
class MonsterListRow extends StatelessWidget {
  final ListMonster _model;
  final MonsterListAction action;
  const MonsterListRow(this._model, this.action, {Key key}) : super(key: key);

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
      onTap: () => _onClickAction(context),
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
                          TypeIcon(m.type1Id),
                          TypeIcon(m.type2Id),
                          TypeIcon(m.type3Id),
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

  void _onClickAction(BuildContext context) {
    switch (action) {
      case MonsterListAction.showDetails:
        goToMonsterFn(context, _model.monster.monsterId)();
        break;
      case MonsterListAction.returnResult:
        Navigator.of(context).pop(_model.monster);
        break;
      default:
        Fimber.e('Unexpected action type: $action');
    }
  }
}

/// Combination of the type icon and type name with padding (null safe for type).
class TypeIcon extends StatelessWidget {
  final int typeId;

  TypeIcon(this.typeId);

  @override
  Widget build(BuildContext context) {
    if (typeId == null) return Container();
    return typeContainer(typeId, leftPadding: 2);
  }
}

int _weighted(num hp, num atk, num rcv, {limitMult: 100}) =>
    (hp / 10 + atk / 5 + rcv / 3) * limitMult ~/ 100;
