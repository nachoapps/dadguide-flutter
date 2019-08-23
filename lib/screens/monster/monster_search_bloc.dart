import 'dart:async';

import 'package:dadguide2/components/service_locator.dart';
import 'package:dadguide2/data/data_objects.dart';
import 'package:dadguide2/data/tables.dart';

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
