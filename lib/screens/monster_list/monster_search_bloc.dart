import 'dart:async';

import 'package:dadguide2/components/config/settings_manager.dart';
import 'package:dadguide2/components/favorites/favorites.dart';
import 'package:dadguide2/components/models/enums.dart';
import 'package:dadguide2/data/tables.dart';
import 'package:dadguide2/screens/monster_list/src/state.dart';
import 'package:flutter/widgets.dart';

/// Intermediary between monster list model and the UI.
class MonsterDisplayState with ChangeNotifier {
  final MonsterSearchBloc searchBloc;
  String _searchText;
  MonsterFilterArgs filterArgs;
  MonsterSortArgs sortArgs;

  bool _pictureMode = false;
  bool _showAwakenings = false;

  StreamSubscription _favoriteSubscription;

  /// Create a display state and immediately request search results.
  MonsterDisplayState(MonsterSearchArgs searchArgs)
      : _searchText = searchArgs.text ?? '',
        filterArgs = searchArgs.filter ?? MonsterFilterArgs(),
        sortArgs = searchArgs.sort ?? MonsterSortArgs(),
        _pictureMode = Prefs.monsterListPictureMode,
        _showAwakenings = Prefs.monsterListAwakeningMode,
        searchBloc = MonsterSearchBloc() {
    searchBloc.search(toSearchArgs());
    _favoriteSubscription = FavoriteManager.instance.updateStream.listen((event) {
      if (filterArgs.favoritesOnly) searchBloc.search(toSearchArgs());
    });
  }

  @override
  void dispose() {
    if (_favoriteSubscription != null) _favoriteSubscription.cancel();
    super.dispose();
  }

  void notify() {
    notifyListeners();
  }

  void doSearch() {
    var searchArgs = toSearchArgs();
    Prefs.monsterSearchArgs = searchArgs;
    searchBloc.search(searchArgs);
  }

  MonsterSearchArgs toSearchArgs() {
    return MonsterSearchArgs(
      text: _searchText.trim(),
      sort: sortArgs,
      filter: filterArgs,
    );
  }

  String get searchText => _searchText;

  set searchText(String text) {
    _searchText = text?.trim();
    searchBloc.doTextUpdateSearch(_searchText);
    notifyListeners();
  }

  set searchTextQuiet(String text) {
    _searchText = text?.trim();
    notifyListeners();
  }

  void clearFilter() {
    filterArgs = MonsterFilterArgs();
    searchTextQuiet = '';
    doSearch();
  }

  bool get favoritesOnly => filterArgs.favoritesOnly;
  bool get pictureMode => _pictureMode;
  bool get showAwakenings => _showAwakenings;

  void clearSelectedAwakenings() {
    filterArgs.awokenSkills.clear();
  }

  void addAwakening(int awakeningId) {
    filterArgs.awokenSkills
      ..add(awakeningId)
      ..sort();
  }

  set showAwakenings(bool value) {
    _showAwakenings = value;
    Prefs.monsterListAwakeningMode = value;
    notifyListeners();
  }

  set pictureMode(bool value) {
    _pictureMode = value;
    Prefs.monsterListPictureMode = value;
    notifyListeners();
  }

  set favoritesOnly(bool value) {
    filterArgs.favoritesOnly = value;
    doSearch();
    notifyListeners();
  }

  bool get filterSet => filterArgs.modified;

  bool get sortNew => sortArgs.sortType == MonsterSortType.released;
  MonsterSortType get sortType => sortArgs.sortType;
  bool get sortAsc => sortArgs.sortAsc;
  bool get customSort => sortArgs.sortAsc || sortArgs.sortType != MonsterSortType.released;

  set sortNew(bool value) {
    sortArgs.sortType = value ? MonsterSortType.released : MonsterSortType.no;
    doSearch();
    notifyListeners();
  }

  set sortType(MonsterSortType value) {
    sortArgs.sortType = value;
    notifyListeners();
  }

  set sortAsc(bool value) {
    sortArgs.sortAsc = value;
    notifyListeners();
  }
}
