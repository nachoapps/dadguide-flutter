import 'package:dadguide2/components/config/settings_manager.dart';
import 'package:dadguide2/components/models/enums.dart';
import 'package:dadguide2/data/tables.dart';
import 'package:dadguide2/screens/monster/src/state.dart';
import 'package:flutter/widgets.dart';

/// Intermediary between monster list model and the UI.
class MonsterDisplayState with ChangeNotifier {
  final MonsterSearchBloc searchBloc;
  String _searchText;
  MonsterFilterArgs filterArgs;
  MonsterSortArgs sortArgs;

  bool _pictureMode = false;
  bool _showAwakenings = false;

  /// Create a display state and immediately request search results.
  MonsterDisplayState(MonsterSearchArgs searchArgs)
      : _searchText = searchArgs.text ?? '',
        filterArgs = searchArgs.filter ?? MonsterFilterArgs(),
        sortArgs = searchArgs.sort ?? MonsterSortArgs(),
        searchBloc = MonsterSearchBloc() {
    searchBloc.search(toSearchArgs());
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
      awakeningsRequired: _showAwakenings,
    );
  }

  get searchText => _searchText;

  set searchText(String text) {
    _searchText = text?.trim();
    searchBloc.doTextUpdateSearch(_searchText);
    notifyListeners();
  }

  void clearSearchText() {
    filterArgs = MonsterFilterArgs();
    searchText = '';
  }

  bool get favoritesOnly => filterArgs.favoritesOnly;
  bool get pictureMode => _pictureMode;
  bool get showAwakenings => _showAwakenings;

  void clearSelectedAwakenings() {
    filterArgs.awokenSkills.clear();
    showAwakenings = false;
  }

  set showAwakenings(bool value) {
    _showAwakenings = value;
    doSearch();
    notifyListeners();
  }

  set pictureMode(bool value) {
    _pictureMode = value;
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
