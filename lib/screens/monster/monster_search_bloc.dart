import 'dart:async';

import 'package:dadguide2/components/enums.dart';
import 'package:dadguide2/components/service_locator.dart';
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
    _counterController.onListen = () => search(MonsterSearchArgs());
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

/// Placeholder for monster sort order.
class MonsterSort {
  bool sortAsc = false;
  bool sortNew = false;
}

/// Intermediary between monster list model and the UI.
class MonsterDisplayState with ChangeNotifier {
  final searchBloc = MonsterSearchBloc();
  final searchArgs = MonsterSearchArgs();

  bool _favoritesOnly = false;
  bool _pictureMode = false;
  bool _showAwakenings = false;

  bool _sortAsc = false;
  MonsterSortType _sortType = MonsterSortType.no;

  set searchText(String text) {
    searchArgs.text = text?.trim();
    searchBloc.search(searchArgs);
    notifyListeners();
  }

  void clearSearch() {
    searchText = '';
  }

  bool get favoritesOnly => _favoritesOnly;
  bool get pictureMode => _pictureMode;
  bool get showAwakenings => _showAwakenings;

  set showAwakenings(bool value) {
    _showAwakenings = value;
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

  bool get sortNew => _sortType == MonsterSortType.released;
  bool get customSort => _sortAsc || _sortType != MonsterSortType.no;

  set sortNew(bool value) {
    _sortType = MonsterSortType.released;
    notifyListeners();
  }

  set sortType(MonsterSortType value) {
    _sortType = value;
    notifyListeners();
  }
}
