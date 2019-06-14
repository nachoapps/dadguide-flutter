import 'package:dadguide2/screens/event/event.dart';
import 'package:dadguide2/screens/monster/monster_info.dart';
import 'package:dadguide2/screens/monster/monster_screen.dart';
import 'package:dadguide2/screens/settings/settings_screen.dart';
import 'package:dadguide2/screens/utils/utils_screen.dart';
import 'package:flutter/material.dart';

class TabNavigatorRoutes {
  static const String root = '/';
  static const String monsterDetail = '/monsterDetail';
}

class TabNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget rootItem;

  TabNavigator({this.navigatorKey, this.rootItem});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      initialRoute: TabNavigatorRoutes.root,
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(builder: (context) {
          if (routeSettings.name == TabNavigatorRoutes.root) {
            return rootItem;
          } else if (routeSettings.name == TabNavigatorRoutes.monsterDetail) {
            return MonsterDetailScreen(1);
          } else {
            throw 'Unexpected route';
          }
        });
      },
    );
  }
}

class StatefulHomeScreen extends StatefulWidget {
  StatefulHomeScreen({Key key}) : super(key: key);

  @override
  _StatefulHomeScreenState createState() => _StatefulHomeScreenState();
}

class _StatefulHomeScreenState extends State<StatefulHomeScreen> {
  int _selectedIndex = 0;

  static final monsterNavKey = GlobalKey<NavigatorState>();

  static List<Widget> _widgetOptions = <Widget>[
    EventTab(key: PageStorageKey('EventTab')),
    TabNavigator(
      navigatorKey: monsterNavKey,
      rootItem: MonsterTab(key: PageStorageKey('MonsterTab')),
    ),
    Text('Dungeon', key: PageStorageKey('DungeonTab')),
    UtilsScreen(key: PageStorageKey('UtilTab')),
    SettingsScreen(key: PageStorageKey('SettingTab')),
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
        child: _widgetOptions.elementAt(_selectedIndex),
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
