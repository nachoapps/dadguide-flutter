import 'dart:io';

import 'package:dadguide2/components/config/service_locator.dart';
import 'package:dadguide2/components/data_update.dart';
import 'package:dadguide2/components/firebase/ads.dart';
import 'package:dadguide2/components/firebase/analytics.dart';
import 'package:dadguide2/components/navigation.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:dadguide2/screens/dungeon/dungeon_list_tab.dart';
import 'package:dadguide2/screens/dungeon_info/dungeon_info_subtab.dart';
import 'package:dadguide2/screens/dungeon_info/sub_dungeon_sheet.dart';
import 'package:dadguide2/screens/event/event_tab.dart';
import 'package:dadguide2/screens/monster/monster_list_tab.dart';
import 'package:dadguide2/screens/monster/monster_search_modal.dart';
import 'package:dadguide2/screens/monster_info/monster_info_subtab.dart';
import 'package:dadguide2/screens/settings/settings_tab.dart';
import 'package:dadguide2/services/device_utils.dart';
import 'package:dadguide2/theme/style.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fimber/flutter_fimber.dart';

/// Paths to the various screens that the user can navigate to.
///
/// The root screen is actually a single route; hitting the back button does not move the user
/// between views.
///
/// All other screens are nested under the root, and respect the back button all the way up to the
/// root screen.
class TabNavigatorRoutes {
  static const String root = '/';
  static const String monsterDetail = MonsterDetailArgs.routeName;
  static const String dungeonDetail = DungeonDetailArgs.routeName;
  static const String subDungeonSelection = SubDungeonSelectionArgs.routeName;
  static const String filterMonsters = FilterMonstersArgs.routeName;
}

/// Each tab is represented by a TabNavigator with a different rootItem. The tabs all have the
/// ability to go to the various sub screens, although some will never use it (e.g. settings).
///
/// Each TabNavigator wraps its own Navigator, allowing for independent back-stacks. Clicking
/// between tabs will wipe out the back-stack.
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
              // The root tab is wrapped by a DataUpdaterWidget which will force a refresh if an
              // update ever occurs while the tab is loaded.
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
            case TabNavigatorRoutes.filterMonsters:
              var args = routeSettings.arguments as FilterMonstersArgs;
              return MaterialPageRoute(builder: (context) => FilterMonstersScreen(args));
            default:
              throw 'Unexpected route';
          }
        });
  }
}

/// Controls the display of the tabs, including tracking which tab is currently visible.
class StatefulHomeScreen extends StatefulWidget {
  StatefulHomeScreen({Key key}) : super(key: key);

  @override
  _StatefulHomeScreenState createState() => _StatefulHomeScreenState();
}

class _StatefulHomeScreenState extends State<StatefulHomeScreen> {
  static final eventNavKey = GlobalKey<NavigatorState>();
  static final monsterNavKey = GlobalKey<NavigatorState>();
  static final dungeonNavKey = GlobalKey<NavigatorState>();
  // The utils tab is currently disabled due to lack of content.
  // static final utilsNavKey = GlobalKey<NavigatorState>();
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

  /// The currently selected tab.
  int _selectedIndex = 0;

  /// Bottom ad to display.
  BannerAd bannerAd;

  @override
  void initState() {
    super.initState();
    _recordCurrentScreenEvent();
    var deviceInfo = getIt<DeviceInfo>();
    if (deviceInfo.platform == DevicePlatform.IOS && deviceInfo.osVersion.major < 11) {
      Fimber.w('Skipping ad load due to IOS bug');
      return;
    }

    RemoteConfig.instance.then((rc) {
      var bannerId = Platform.isIOS ? rc.getString('ios_banner') : rc.getString('android_banner');
      if (bannerId == null || bannerId.isEmpty) {
        Fimber.e('Remote config: could not find banner id');
        return;
      } else {
        Fimber.i('Remote config: banner id loaded');
      }
      bannerAd = createBannerAd(bannerId);
      bannerAd.load().then((v) {
        Fimber.i('Ad loaded: $v');
        bannerAd.show().then((v) {
          Fimber.i('Ad shown: $v');
        });
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

  /// Triggered whenever a user clicks on a new tab. Swaps the currently displayed tab UI.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _recordCurrentScreenEvent();
    });
  }

  /// Records a screen view of the currently visible widget.
  void _recordCurrentScreenEvent() =>
      screenChangeEvent(_widgetOptions[_selectedIndex].rootItem.runtimeType.toString());

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Only respect the back button if the currently visible tab's navigator says its ok.
      onWillPop: () async =>
          !await _widgetOptions[_selectedIndex].navigatorKey.currentState.maybePop(),
      child: Column(
        children: [
          Expanded(
            child: Scaffold(
              body: SafeArea(child: _widgetOptions[_selectedIndex]),
              // Prevent the tabs at the bottom from floating above the keyboard.
              resizeToAvoidBottomInset: false,
              bottomNavigationBar: BottomNavOptions(_selectedIndex, _onItemTapped),
            ),
          ),
          // Reserve room for the banner ad.
          SizedBox(
              height: getBannerHeight(context) + 8,
              child: Center(
                child: Text("Failed to load ad",
                    style: Theme.of(context).textTheme.body1.copyWith(color: grey(context, 1000))),
              )),
        ],
      ),
    );
  }
}

/// Tabs at the bottom that switch views.
class BottomNavOptions extends StatelessWidget {
  final int selectedIdx;
  final void Function(int) onTap;

  BottomNavOptions(this.selectedIdx, this.onTap);

  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);

    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          title: Text(loc.tabEvent),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.format_line_spacing),
          title: Text(loc.tabMonster),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          title: Text(loc.tabDungeon),
        ),
//        BottomNavigationBarItem(
//          icon: Icon(Icons.move_to_inbox),
//          title: Text('Util'),
//        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          title: Text(loc.tabSetting),
        ),
      ],
      currentIndex: selectedIdx,
      selectedItemColor: Colors.blue,
      unselectedItemColor: grey(context, 1000),
      showUnselectedLabels: true,
      onTap: onTap,
    );
  }
}
