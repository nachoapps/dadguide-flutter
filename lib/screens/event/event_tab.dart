import 'package:async/async.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dadguide2/data/database.dart';
import 'package:dadguide2/data/tables.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EventTab extends StatefulWidget {
  EventTab({Key key}) : super(key: key);

  @override
  EventTabState createState() => EventTabState();
}

class EventTabState extends State<EventTab> {
  final _memoizer = AsyncMemoizer<List<FullEvent>>();
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('adding an eventtab');
    return ChangeNotifierProvider(
      builder: (context) => ScheduleEventDisplayState(),
      child: Column(children: <Widget>[
        EventSearchBar(),
        Expanded(child: _searchResults()),
        DateSelectBar(),
      ]),
    );
  }

  FutureBuilder<List<FullEvent>> _searchResults() {
    var dataFuture = _memoizer.runOnce(() async {
      var database = await DatabaseHelper.instance.database;

      var y = await database.currentEvents;
      return database.fullEvents();
    }).catchError((ex) {
      print(ex);
    });

    return FutureBuilder<List<FullEvent>>(
        future: dataFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            print('no data!');
            return Center(child: CircularProgressIndicator());
          }
          print('got data!');

          return ListView(
              children: snapshot.data.map((event) {
            return ScheduleEventRow(event);
          }).toList());
        });
  }
}

class EventSearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      child: Row(
        children: <Widget>[
          Expanded(child: Center(child: Text('Guerrilla'))),
          Expanded(child: Center(child: Text('Special'))),
          Expanded(child: Center(child: Text('News'))),
        ],
      ),
    );
  }
}

class DateSelectBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      child: Row(children: <Widget>[
        Expanded(child: Center(child: Text('Dates'))),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 2),
          child: Center(child: Text('Schedule')),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 2),
          child: Center(child: Text('Eggs')),
        ),
      ]),
    );
  }
}

class ScheduleEventRow extends StatelessWidget {
  final FullEvent _model;
  const ScheduleEventRow(this._model, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var se = _model;
    return InkWell(
      onTap: () {
        print('pushing!');
//        Navigator.of(context).pushNamed('/monsterDetail');
      },
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          child: Row(
            children: <Widget>[
              sizedContainer(CachedNetworkImage(
                placeholder: (context, url) => CircularProgressIndicator(),
                imageUrl: imageUrl(_model),
              )),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(se.headerText()),
                    DefaultTextStyle(
                      style: Theme.of(context).textTheme.overline,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [Text(se.underlineText(DateTime.now()))]),
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}

String imageUrl(FullEvent model) {
  var paddedNo = model.iconId.toString().padLeft(4, '0');
  return 'http://miru.info/padguide/images/icons/icon_$paddedNo.png';
}

Widget sizedContainer(Widget child) {
  return new SizedBox(
    width: 48.0,
    height: 48.0,
    child: new Center(child: child),
  );
}

class ScheduleEventDisplayState with ChangeNotifier {}
