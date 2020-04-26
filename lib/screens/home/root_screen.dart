import 'package:dadguide2/components/firebase/ads.dart';
import 'package:dadguide2/components/firebase/analytics.dart';
import 'package:dadguide2/components/ui/navigation.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:dadguide2/screens/dungeon/dungeon_list_tab.dart';
import 'package:dadguide2/screens/event/event_tab.dart';
import 'package:dadguide2/screens/home/tab_navigator.dart';
import 'package:dadguide2/screens/monster/monster_list_tab.dart';
import 'package:dadguide2/screens/settings/settings_tab.dart';
import 'package:dadguide2/theme/style.dart';
import 'package:flutter/material.dart';

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
  static final settingsNavKey = GlobalKey<NavigatorState>();

  static List<TabNavigator> _widgetOptions = [
    TabNavigator(
      navigatorKey: eventNavKey,
      rootItem: EventTab(key: PageStorageKey('EventTab')),
    ),
    TabNavigator(
      navigatorKey: monsterNavKey,
      rootItem: MonsterTab(
        args: MonsterListArgs(MonsterListAction.showDetails),
        key: PageStorageKey('MonsterTab'),
      ),
    ),
    TabNavigator(
      navigatorKey: dungeonNavKey,
      rootItem: DungeonTab(key: PageStorageKey('DungeonTab')),
    ),
    TabNavigator(
      navigatorKey: settingsNavKey,
      rootItem: SettingsScreen(key: PageStorageKey('SettingsTab')),
    ),
  ];

  /// The currently selected tab.
  int _selectedIndex = 0;

  /// Bottom ad to display.
  BannerAdManager adManager = new BannerAdManager();

  @override
  void initState() {
    super.initState();
    _recordCurrentScreenEvent();
    adManager.init();
  }

  @override
  void dispose() {
    if (adManager != null) {
      adManager.dispose();
      adManager = null;
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
          AdAvailabilitySpacerWidget(),
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
