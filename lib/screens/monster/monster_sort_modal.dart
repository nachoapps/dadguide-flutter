import 'package:dadguide2/components/enums.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:dadguide2/theme/style.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'monster_search_bloc.dart';

/// Displays a dialog that lets the user sort the monsters in the list view.
Future<void> showMonsterSortDialog(BuildContext context) async {
  var loc = DadGuideLocalizations.of(context);

  var displayState = Provider.of<MonsterDisplayState>(context);
  var dialogResults = await showDialog(
      context: context,
      builder: (innerContext) {
        return ChangeNotifierProvider.value(
          value: displayState,
          child: SimpleDialog(
            title: Text(loc.monsterSortModalTitle),
            contentPadding: EdgeInsets.all(4),
            children: [
              SortOrderRow(),
              Divider(),
              SortOptionsGrid(),
              Divider(),
              FilterActionBar(),
            ],
          ),
        );
      });
  displayState.doSearch();
  return dialogResults;
}

class SortOrderRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);
    var displayState = Provider.of<MonsterDisplayState>(context);

    return Row(
      children: [
        Expanded(
          child: ToggleSortButton(
              !displayState.sortAsc, loc.monsterSortDesc, () => displayState.sortAsc = false),
        ),
        SizedBox(width: 8),
        Expanded(
          child: ToggleSortButton(
              displayState.sortAsc, loc.monsterSortAsc, () => displayState.sortAsc = true),
        ),
      ],
    );
  }
}

class ToggleSortButton extends FlatButton {
  final bool _selected;
  final String _text;
  final VoidCallback _selectedOnPressed;

  ToggleSortButton(this._selected, this._text, this._selectedOnPressed);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      color: grey(context, 200),
      disabledColor: Colors.lightBlueAccent,
      textColor: grey(context, 1000),
      disabledTextColor: grey(context, 0),
      child: Text(_text),
      onPressed: _selected ? null : _selectedOnPressed,
    );
  }
}

class SortOptionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var displayState = Provider.of<MonsterDisplayState>(context);

    return Container(
      width: MediaQuery.of(context).size.width * .8,
      height: MediaQuery.of(context).size.height * .5,
      child: GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 8 / 3,
        shrinkWrap: true,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: [
          for (var sortItem in MonsterSortType.allValues)
            ToggleSortButton(
              displayState.sortType == sortItem,
              sortItem.label,
              () => displayState.sortType = sortItem,
            ),
        ],
      ),
    );
  }
}

class FilterActionBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);
    var displayState = Provider.of<MonsterDisplayState>(context);

    return Row(
      children: [
        FlatButton(
          child: Text(loc.monsterFilterModalClose),
          onPressed: () => Navigator.pop(context),
        ),
        Spacer(),
        FlatButton(
          child: Text(loc.monsterFilterModalReset),
          onPressed: () {
            displayState.sortType = MonsterSortType.released;
            displayState.sortAsc = false;
            displayState.notify();
          },
        ),
      ],
    );
  }
}
