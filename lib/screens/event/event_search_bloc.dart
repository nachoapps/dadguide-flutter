import 'dart:async';

import 'package:dadguide2/components/enums.dart';
import 'package:dadguide2/components/service_locator.dart';
import 'package:dadguide2/data/data_objects.dart';
import 'package:dadguide2/data/tables.dart';

class EventSearchBloc {
  final ScheduleDao _dao;

  final _counterController = StreamController<List<ListEvent>>();

  EventSearchBloc() : _dao = getIt<ScheduleDao>();

  StreamSink<List<ListEvent>> get _resultSink => _counterController.sink;
  Stream<List<ListEvent>> get searchResults => _counterController.stream;

  void search(EventSearchArgs args) async {
    _resultSink.add(null);
    var events = await _dao.findListEvents(args);

    events = events.where((e) => args.serverIds.contains(e.event.serverId)).toList();
    events = events.where((e) {
      if (args.tab == ScheduleTabKey.all) {
        return true;
      } else if (args.tab == ScheduleTabKey.guerrilla) {
        return args.starterNames.contains(e.event.groupName);
      } else if (args.tab == ScheduleTabKey.special) {
        return e.event.groupName == null;
      } else {
        return false;
      }
    }).toList();

    _resultSink.add(events);
  }

  void dispose() {
    _counterController.close();
  }
}
