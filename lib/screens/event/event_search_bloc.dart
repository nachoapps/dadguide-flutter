import 'dart:async';

import 'package:dadguide2/components/enums.dart';
import 'package:dadguide2/components/service_locator.dart';
import 'package:dadguide2/components/settings_manager.dart';
import 'package:dadguide2/data/data_objects.dart';
import 'package:dadguide2/data/tables.dart';
import 'package:dadguide2/services/update_service.dart';
import 'package:flutter/material.dart';

/// Top level state for the event tab; contains the selected date and server.
class ScheduleDisplayState with ChangeNotifier {
  List<Country> servers = [Prefs.eventCountry];
  List<StarterDragon> starters = Prefs.eventStarters;
  bool hideClosed = Prefs.eventHideClosed;
  DateTime _currentEventDate = _toStartOfDay(DateTime.now());

  set currentEventDate(DateTime date) {
    _currentEventDate = _toStartOfDay(date);
    notifyListeners();
  }

  DateTime get currentEventDate => _currentEventDate;

  set server(Country country) {
    Prefs.eventCountry = country;
    servers = [Prefs.eventCountry];
    notifyListeners();
  }
}

/// State for an individual sub tab.
class ScheduleTabState with ChangeNotifier {
  final searchBloc = EventSearchBloc();

  final List<Country> servers;
  final List<StarterDragon> starters;
  final ScheduleTabKey tab;
  final DateTime dateStart;
  final bool hideClosed;

  StreamSubscription<void> _updateSubscription;

  ScheduleTabState(this.servers, this.starters, this.tab, this.dateStart, this.hideClosed) {
    _updateSubscription = updateManager.updateStream.listen((_) {
      search();
    });
    search();
  }

  void search() {
    searchBloc.search(EventSearchArgs.from(
        servers, starters, tab, dateStart, dateStart.add(Duration(days: 1)), hideClosed));
  }

  @override
  void dispose() {
    super.dispose();
    _updateSubscription.cancel();
  }
}

class EventSearchBloc {
  final ScheduleDao _dao;

  final _counterController = StreamController<List<ListEvent>>();

  EventSearchBloc() : _dao = getIt<ScheduleDao>();

  StreamSink<List<ListEvent>> get _resultSink => _counterController.sink;
  Stream<List<ListEvent>> get searchResults => _counterController.stream;

  void search(EventSearchArgs args) async {
    _resultSink.add(null);
    var events = await _dao.findListEvents(args);

    // This probably needs to move into the DAO.
    events = events.where((e) => args.serverIds.contains(e.event.serverId)).toList();
    events = events.where((e) {
      var groupName = e.event.groupName;
      var isSpecial = groupName == null;
      var passesGroupFilter = isSpecial || args.starterNames.contains(groupName);
      if (args.tab == ScheduleTabKey.all) {
        return passesGroupFilter;
      } else if (args.tab == ScheduleTabKey.special) {
        return isSpecial;
      } else if (args.tab == ScheduleTabKey.guerrilla) {
        return !isSpecial && passesGroupFilter;
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

DateTime _toStartOfDay(DateTime time) {
  return DateTime(time.year, time.month, time.day);
}
