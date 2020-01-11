import 'dart:async';

import 'package:dadguide2/components/config/service_locator.dart';
import 'package:dadguide2/components/enums.dart';
import 'package:dadguide2/data/data_objects.dart';
import 'package:dadguide2/data/tables.dart';
import 'package:flutter/widgets.dart';

/// Interface between the monster list data model and the UI.
class MonsterSearchBloc {
  // TODO: This is based on a half-ass understanding of how this is supposed to work, should clean
  //       it up.

  final MonstersDao _dao;
  final _counterController = StreamController<List<ListMonster>>();

  MonsterSearchBloc() : _dao = getIt<MonstersDao>() {
    _counterController.onListen = () => search(MonsterSearchArgs.defaults());
  }

  StreamSink<List<ListMonster>> get _resultSink => _counterController.sink;
  Stream<List<ListMonster>> get searchResults => _counterController.stream;

  void search(MonsterSearchArgs args) {
    _resultSink.add(null);
    _dao.findListMonsters(args).then((r) => _resultSink.add(r));
  }

  void dispose() {
    _counterController.close();
  }
}

/// Intermediary between monster list model and the UI.
class MonsterDisplayState with ChangeNotifier {
  final searchBloc = MonsterSearchBloc();
  String _searchText = '';
  var filterArgs = MonsterFilterArgs();
  var sortArgs = MonsterSortArgs();

  bool _favoritesOnly = false;
  bool _pictureMode = false;
  bool _showAwakenings = false;

  void notify() {
    notifyListeners();
  }

  void doSearch() {
    searchBloc.search(MonsterSearchArgs(
      text: _searchText.trim(),
      sort: sortArgs,
      filter: filterArgs,
      awakeningsRequired: _showAwakenings,
    ));
  }

  get searchText => _searchText;

  set searchText(String text) {
    _searchText = text?.trim();
    doSearch();
    notifyListeners();
  }

  void clearSearchText() {
    filterArgs = MonsterFilterArgs();
    searchText = '';
  }

  bool get favoritesOnly => _favoritesOnly;
  bool get pictureMode => _pictureMode;
  bool get showAwakenings => _showAwakenings;

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
    _favoritesOnly = value;
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
