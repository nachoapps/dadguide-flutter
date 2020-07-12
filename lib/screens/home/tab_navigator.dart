import 'package:dadguide2/components/ui/navigation.dart';
import 'package:dadguide2/components/updates/data_update.dart';
import 'package:dadguide2/data_dadguide/tables.dart';
import 'package:dadguide2/screens/dungeon_info/dungeon_info_subtab.dart';
import 'package:dadguide2/screens/dungeon_info/src/overview.dart';
import 'package:dadguide2/screens/dungeon_info/sub_dungeon_sheet.dart';
import 'package:dadguide2/screens/egg_machine/egg_machine_subtab.dart';
import 'package:dadguide2/screens/exchange/exchange_subtab.dart';
import 'package:dadguide2/screens/monster_compare/monster_compare.dart';
import 'package:dadguide2/screens/monster_info/monster_info_subtab.dart';
import 'package:dadguide2/screens/monster_list/monster_list_tab.dart';
import 'package:dadguide2/screens/monster_list/monster_search_modal.dart';
import 'package:dadguide2/screens/team_editor/edit_screen.dart';
import 'package:dadguide2/screens/team_editor/list_screen.dart';
import 'package:dadguide2/screens/team_editor/nav.dart';
import 'package:dadguide2/screens/team_editor/view_screen.dart';
import 'package:flutter/material.dart';

/// Paths to the various screens that the user can navigate to.
///
/// The root screen is actually a single route; hitting the back button does not move the user
/// between views.
///
/// All other screens are nested under the root, and respect the back button all the way up to the
/// root screen.
class TabNavigatorRoutes {
  static const String root = '/';
  static const String monsterList = MonsterListArgs.routeName;
  static const String monsterDetail = MonsterDetailArgs.routeName;
  static const String dungeonDetail = DungeonDetailArgs.routeName;
  static const String subDungeonSelection = SubDungeonSelectionArgs.routeName;
  static const String filterMonsters = FilterMonstersArgs.routeName;
  static const String eggMachines = EggMachineArgs.routeName;
  static const String exchanges = ExchangeArgs.routeName;
  static const String monsterCompare = MonsterCompareArgs.routeName;
  static const String teamList = BuildListArgs.routeName;
  static const String teamEdit = BuildEditArgs.routeName;
  static const String teamView = BuildViewArgs.routeName;
  static const String dungeonOverview = DungeonDetailArgs.dungeonOverviewRouteName;
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
              var args = routeSettings.arguments as MonsterDetailArgs;
              return MaterialPageRoute(builder: (context) => MonsterDetailScreen(args));
            case TabNavigatorRoutes.monsterList:
              var args = routeSettings.arguments as MonsterListArgs;
              return MaterialPageRoute<Monster>(builder: (context) => MonsterTab(args: args));
            case TabNavigatorRoutes.dungeonDetail:
              var args = routeSettings.arguments as DungeonDetailArgs;
              return MaterialPageRoute(builder: (context) => DungeonDetailScreen(args));
            case TabNavigatorRoutes.subDungeonSelection:
              var args = routeSettings.arguments as SubDungeonSelectionArgs;
              return MaterialPageRoute(builder: (context) => SelectSubDungeonScreen(args));
            case TabNavigatorRoutes.filterMonsters:
              var args = routeSettings.arguments as FilterMonstersArgs;
              return MaterialPageRoute(builder: (context) => FilterMonstersScreen(args));
            case TabNavigatorRoutes.eggMachines:
              var args = routeSettings.arguments as EggMachineArgs;
              return MaterialPageRoute(builder: (context) => EggMachineScreen(args));
            case TabNavigatorRoutes.exchanges:
              var args = routeSettings.arguments as ExchangeArgs;
              return MaterialPageRoute(builder: (context) => ExchangeScreen(args));
            case TabNavigatorRoutes.monsterCompare:
              var args = routeSettings.arguments as MonsterCompareArgs;
              return MaterialPageRoute(builder: (context) => MonsterCompareScreen(args));
            case TabNavigatorRoutes.teamList:
              var args = routeSettings.arguments as BuildListArgs;
              return MaterialPageRoute(builder: (context) => BuildListScreen(args));
            case TabNavigatorRoutes.teamEdit:
              var args = routeSettings.arguments as BuildEditArgs;
              return MaterialPageRoute(builder: (context) => BuildEditScreen(args));
            case TabNavigatorRoutes.teamView:
              var args = routeSettings.arguments as BuildViewArgs;
              return MaterialPageRoute(builder: (context) => BuildViewScreen(args));
            case TabNavigatorRoutes.dungeonOverview:
              var args = routeSettings.arguments as DungeonDetailArgs;
              return MaterialPageRoute(builder: (context) => DungeonOverviewScreen(args));
            default:
              throw 'Unexpected route';
          }
        });
  }
}
