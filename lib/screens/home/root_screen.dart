import 'package:dadguide2/components/ads.dart';
import 'package:dadguide2/components/data_update.dart';
import 'package:dadguide2/components/navigation.dart';
import 'package:dadguide2/screens/dungeon/dungeon_info_subtab.dart';
import 'package:dadguide2/screens/dungeon/dungeon_list_tab.dart';
import 'package:dadguide2/screens/dungeon/sub_dungeon_sheet.dart';
import 'package:dadguide2/screens/event/event_tab.dart';
import 'package:dadguide2/screens/monster/monster_info_subtab.dart';
import 'package:dadguide2/screens/monster/monster_list_tab.dart';
import 'package:dadguide2/screens/settings/settings_tab.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fimber/flutter_fimber.dart';

class TabNavigatorRoutes {
  static const String root = '/';
  static const String monsterDetail = MonsterDetailArgs.routeName;
  static const String dungeonDetail = DungeonDetailArgs.routeName;
  static const String subDungeonSelection = SubDungeonSelectionArgs.routeName;
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
          switch (routeSettings.name) {
            case TabNavigatorRoutes.root:
              return MaterialPageRoute(builder: (context) => DataUpdaterWidget(rootItem));
            case TabNavigatorRoutes.monsterDetail:
              MonsterDetailArgs args = routeSettings.arguments;
              return MaterialPageRoute(builder: (context) => MonsterDetailScreen(args));
            case TabNavigatorRoutes.dungeonDetail:
              var args = routeSettings.arguments as DungeonDetailArgs;
              return MaterialPageRoute(builder: (context) => DungeonDetailScreen(args));
            case TabNavigatorRoutes.subDungeonSelection:
              var args = routeSettings.arguments as SubDungeonSelectionArgs;
              return MaterialPageRoute(builder: (context) => SelectSubDungeonScreen(args));
            default:
              throw 'Unexpected route';
          }
        });
  }
}

class StatefulHomeScreen extends StatefulWidget {
  StatefulHomeScreen({Key key}) : super(key: key);

  @override
  _StatefulHomeScreenState createState() => _StatefulHomeScreenState();
}

class _StatefulHomeScreenState extends State<StatefulHomeScreen> {
  static final eventNavKey = GlobalKey<NavigatorState>();
  static final monsterNavKey = GlobalKey<NavigatorState>();
  static final dungeonNavKey = GlobalKey<NavigatorState>();
//  static final utilsNavKey = GlobalKey<NavigatorState>();
  static final settingsNavKey = GlobalKey<NavigatorState>();

  static List<TabNavigator> _widgetOptions = [
    TabNavigator(
      navigatorKey: eventNavKey,
      rootItem: EventTab(key: PageStorageKey('EventTab')),
    ),
    TabNavigator(
      navigatorKey: monsterNavKey,
      rootItem: MonsterTab(key: PageStorageKey('MonsterTab')),
    ),
    TabNavigator(
      navigatorKey: dungeonNavKey,
      rootItem: DungeonTab(key: PageStorageKey('DungeonTab')),
    ),
//    TabNavigator(
//      navigatorKey: utilsNavKey,
//      rootItem: UtilsScreen(key: PageStorageKey('UtilsTab')),
//    ),
    TabNavigator(
      navigatorKey: settingsNavKey,
      rootItem: SettingsScreen(key: PageStorageKey('SettingsTab')),
    ),
  ];

  int _selectedIndex = 0;
  BannerAd bannerAd;

  @override
  void initState() {
    super.initState();
    bannerAd = createBannerAd();
    bannerAd.load().then((v) {
      Fimber.i('Ad loaded: $v');
      bannerAd.show().then((v) {
        Fimber.i('Ad shown: $v');
      });
    });
  }

  @override
  void dispose() {
    if (bannerAd != null) {
      bannerAd.dispose();
      bannerAd = null;
    }
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async =>
          !await _widgetOptions[_selectedIndex].navigatorKey.currentState.maybePop(),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Scaffold(
              body: SafeArea(child: _widgetOptions.elementAt(_selectedIndex)),
              resizeToAvoidBottomInset: false,
              bottomNavigationBar: BottomNavOptions(_selectedIndex, _onItemTapped),
            ),
          ),
          SizedBox(height: getBannerHeight(context)),
//          SizedBox(height: getSmartBannerHeight(context)),
        ],
      ),
    );
  }
}

class BottomNavOptions extends StatelessWidget {
  final int selectedIdx;
  final void Function(int) onTap;

  BottomNavOptions(this.selectedIdx, this.onTap);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
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
//        BottomNavigationBarItem(
//          icon: Icon(Icons.move_to_inbox),
//          title: Text('Util'),
//        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          title: Text('Setting'),
        ),
      ],
      currentIndex: selectedIdx,
      selectedItemColor: Colors.amber[800],
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      onTap: onTap,
    );
  }
}
