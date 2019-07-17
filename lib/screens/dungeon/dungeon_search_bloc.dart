import 'dart:async';

import 'package:dadguide2/components/service_locator.dart';
import 'package:dadguide2/data/data_objects.dart';
import 'package:dadguide2/data/tables.dart';

class DungeonSearchBloc {
  final DungeonsDao _dao;

  final _counterController = StreamController<List<ListDungeon>>();

  DungeonSearchBloc() : _dao = getIt<DungeonsDao>() {
    _counterController.onListen = () => search(DungeonSearchArgs());
  }

  StreamSink<List<ListDungeon>> get _resultSink => _counterController.sink;
  Stream<List<ListDungeon>> get searchResults => _counterController.stream;

  void search(DungeonSearchArgs args) {
    _resultSink.add(null);
    _dao.findListDungeons(args).then((r) => _resultSink.add(r));
  }

  void dispose() {
    _counterController.close();
  }
}
