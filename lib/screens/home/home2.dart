import 'package:dadguide2/screens/event/event.dart';
import 'package:flutter/material.dart';

class StatefulHomeScreen extends StatefulWidget {
  StatefulHomeScreen({Key key}) : super(key: key);

  @override
  _StatefulHomeScreenState createState() => _StatefulHomeScreenState();
}

class _StatefulHomeScreenState extends State<StatefulHomeScreen> {
  int _selectedIndex = 0;
  static List<Widget> _widgetOptions = <Widget>[
    EventTab(),
    Container(color: Colors.red, child: Text('Monster')),
    Text('Dungeon'),
    Text('Util'),
    Text('Setting'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            title: Text('Event'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.format_line_spacing),
            title: Text('Monster'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Dungeon'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.move_to_inbox),
            title: Text('Util'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            title: Text('Setting'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }
}
