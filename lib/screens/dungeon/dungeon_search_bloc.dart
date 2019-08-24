import 'dart:async';

import 'package:dadguide2/components/enums.dart';
import 'package:dadguide2/components/service_locator.dart';
import 'package:dadguide2/data/data_objects.dart';
import 'package:dadguide2/data/tables.dart';
import 'package:flutter/material.dart';

class DungeonSort {}

/// Interface between the tab and the underlying dungeon list data.
class DungeonDisplayState with ChangeNotifier {
  final searchBloc = DungeonSearchBloc();

  DungeonTabKey _tab;

  String _searchText = '';

  DungeonDisplayState(this._tab) {
    search();
  }

  set searchText(String searchText) {
    this._searchText = searchText.trim();
    search();
    notifyListeners();
  }

  String get searchText => _searchText;

  void search() {
    var dungeonTypes = <DungeonType>[];
    if (_tab == DungeonTabKey.special) {
      dungeonTypes.add(DungeonType.special);
    } else if (_tab == DungeonTabKey.normal) {
      dungeonTypes.add(DungeonType.normal);
    } else if (_tab == DungeonTabKey.technical) {
      dungeonTypes.add(DungeonType.technical);
    } else if (_tab == DungeonTabKey.multiranking) {
      dungeonTypes.add(DungeonType.multiplayer);
      dungeonTypes.add(DungeonType.ranking);
    }
    searchBloc.search(DungeonSearchArgs(text: searchText, dungeonTypes: dungeonTypes));
  }

  void clearSearch() {
    searchText = '';
  }

  DungeonTabKey get tab => _tab;

  set tab(DungeonTabKey value) {
    if (_tab == value) return;

    _tab = value;
    search();
    notifyListeners();
  }
}

/// Interface between the dungeon list data model and the UI.
class DungeonSearchBloc {
  // TODO: This is based on a half-ass understanding of how this is supposed to work, should clean
  //       it up.

  final DungeonsDao _dao;
  final _counterController = StreamController<List<ListDungeon>>();

  DungeonSearchBloc() : _dao = getIt<DungeonsDao>();

  StreamSink<List<ListDungeon>> get _resultSink => _counterController.sink;
  Stream<List<ListDungeon>> get searchResults => _counterController.stream;

  void search(DungeonSearchArgs args) async {
    _resultSink.add(null);
    var dungeons = await _dao.findListDungeons(args);

    // Probably move this into DAO.
    dungeons = dungeons.where((d) => args.dungeonTypeIds.contains(d.dungeon.dungeonType)).toList();
    print(dungeons.length);

    _resultSink.add(dungeons);
  }

  void dispose() {
    _counterController.close();
  }
}
