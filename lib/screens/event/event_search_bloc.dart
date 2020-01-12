import 'dart:async';

import 'package:dadguide2/components/config/service_locator.dart';
import 'package:dadguide2/components/config/settings_manager.dart';
import 'package:dadguide2/components/models/data_objects.dart';
import 'package:dadguide2/components/models/enums.dart';
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
    _resultSink.add(events);
  }

  void dispose() {
    _counterController.close();
  }
}

DateTime _toStartOfDay(DateTime time) {
  return DateTime(time.year, time.month, time.day);
}
