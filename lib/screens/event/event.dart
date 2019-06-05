import 'package:flutter/material.dart';

class EventTab extends StatefulWidget {
  EventTab({Key key}) : super(key: key);

  @override
  EventTabState createState() => EventTabState();
}

class EventTabState extends State<EventTab> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Container(
        color: Colors.blue,
        padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Row(
          children: <Widget>[
            Expanded(child: Center(child: Text('Guerrilla'))),
            Expanded(child: Center(child: Text('Special'))),
            Expanded(child: Center(child: Text('News'))),
          ],
        ),
      ),
      Expanded(
        child: Center(
          child: Text('wooo'),
        ),
      ),
      Container(
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
      ),
    ]);
  }
}
