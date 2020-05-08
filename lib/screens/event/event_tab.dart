import 'package:dadguide2/components/config/settings_manager.dart';
import 'package:dadguide2/components/firebase/remote_config.dart';
import 'package:dadguide2/components/images/icons.dart';
import 'package:dadguide2/components/models/enums.dart';
import 'package:dadguide2/components/ui/navigation.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:dadguide2/screens/event/server_select_modal.dart';
import 'package:dadguide2/theme/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_week/calendar_week.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';

import 'event_list.dart';
import 'event_search_bloc.dart';

/// A header-tabbed screen displaying events.
class EventTab extends StatelessWidget {
  EventTab({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: ChangeNotifierProvider(
        create: (context) => ScheduleDisplayState(),
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(40),
            child: EventListHeader(),
          ),
          body: Column(children: [
            Expanded(child: EventListTabs()),
            DateSelectBar(),
          ]),
        ),
      ),
    );
  }
}

/// The event tab header.
class EventListHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);
    var displayState = Provider.of<ScheduleDisplayState>(context);

    return AppBar(
      flexibleSpace: Row(
        children: [
          InkWell(
              onTap: () => showServerSelectDialog(context, displayState),
              child: SizedBox(width: 60, height: 40, child: DadGuideIcons.currentCountryOn)),
          Flexible(
            child: TabBar(tabs: [
              Tab(text: loc.eventTabAll),
              Tab(text: loc.eventTabGuerrilla),
              Tab(text: loc.eventTabSpecial),
//              News disabled for now
//              Tab(text: 'News'),
            ]),
          ),
        ],
      ),
    );
  }
}

/// The tab contents.
class EventListTabs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TabBarView(children: [
      EventList(ScheduleTabKey.all),
      EventList(ScheduleTabKey.guerrilla),
      EventList(ScheduleTabKey.special),
//              News disabled for now
//      EventList(ScheduleTabKey.news),
    ]);
  }
}

/// Displays a list of Events, chunked into sections by type.
class EventList extends StatelessWidget {
  final ScheduleTabKey _tabKey;

  EventList(this._tabKey);

  @override
  Widget build(BuildContext context) {
    var displayState = Provider.of<ScheduleDisplayState>(context);

    return ChangeNotifierProvider(
        key: UniqueKey(),
        create: (context) => ScheduleTabState(displayState.servers, displayState.starters, _tabKey,
            displayState.currentEventDate, displayState.hideClosed),
        child: EventListContents());
  }
}

/// Bar at the bottom of each tab; allows the user to select the current event date.
class DateSelectBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: grey(context, 200),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 240, child: DateSelectWidget()),
            Spacer(),
            if (!RemoteConfigWrapper.disableExchange)
              SizedBox(
                height: 32,
                width: 64,
                child: FlatButton(
                  onPressed: goToExchangeFn(context, Prefs.eventCountry),
                  child: Icon(FontAwesome.exchange),
                ),
              ),
            if (!RemoteConfigWrapper.disableEggMachine)
              SizedBox(
                height: 32,
                width: 64,
                child: FlatButton(
                  onPressed: goToEggMachineFn(context, Prefs.eventCountry),
                  child: Icon(MaterialCommunityIcons.egg_easter),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class DateSelectWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var displayState = Provider.of<ScheduleDisplayState>(context);
    // TODO: CalendarWeek doesn't take a default start date. It probably doesn't matter since we
    //       use the current date by default but it's still weird.
    //    var currentEventDate = displayState.currentEventDate;

    return CalendarWeek(
      height: 32,
      minDate: DateTime.now().add(Duration(days: -1)),
      maxDate: DateTime.now().add(Duration(days: 14)),
      weekSize: 4,
      onDatePressed: (DateTime datetime) => displayState.currentEventDate = datetime,
      dayOfWeekStyle: TextStyle(color: grey(context, 1000)),
      dateStyle: TextStyle(color: grey(context, 1000)),
      todayDateStyle: TextStyle(color: grey(context, 1000)),
      backgroundColor: Colors.transparent,
    );
  }
}
