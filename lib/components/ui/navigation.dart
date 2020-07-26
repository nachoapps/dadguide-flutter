import 'package:dadguide2/components/config/service_locator.dart';
import 'package:dadguide2/components/models/data_objects.dart';
import 'package:dadguide2/components/models/enums.dart';
import 'package:dadguide2/data_dadguide/tables.dart';
import 'package:dadguide2/screens/monster_list/monster_search_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fimber/flutter_fimber.dart';

/// Describes what should happen when a monster in the list is clicked on.
enum MonsterListAction {
  showDetails,
  returnResult,
}

extension MonsterListActionExtension on MonsterListAction {
  void execute(BuildContext context, Monster monster) {
    switch (this) {
      case MonsterListAction.showDetails:
        goToMonsterFn(context, monster.monsterId)();
        break;
      case MonsterListAction.returnResult:
        Navigator.of(context).pop(monster);
        break;
      default:
        Fimber.e('Unexpected action type: $this');
    }
  }
}

/// Arguments to the monster list route.
class MonsterListArgs {
  static const routeName = '/monsterList';
  final MonsterListAction action;
  final bool useArgsFromPrefs;

  MonsterListArgs(this.action, {this.useArgsFromPrefs = true});
}

/// Opens the monster list route, returning a Monster if one is selected.
Future<Monster> goToMonsterList(BuildContext context) {
  return Navigator.pushNamed(context, MonsterListArgs.routeName,
      arguments: MonsterListArgs(MonsterListAction.returnResult));
}

/// Arguments to the monster detail route.
class MonsterDetailArgs {
  static const routeName = '/monsterDetail';
  final int monsterId;

  const MonsterDetailArgs(this.monsterId);
}

/// Wraps a widget with an onClick that sends them to the monster. If ink is specified, will add a
/// ripple effect.
Widget wrapMonsterLink(BuildContext context, Widget child, int monsterId, {bool ink = false}) {
  monsterId ??= 0;
  if (monsterId == 0) {
    return child;
  }
  var onTap = goToMonsterFn(context, monsterId);
  return ink ? InkWell(child: child, onTap: onTap) : GestureDetector(child: child, onTap: onTap);
}

/// Returns a Function which when executed, sends the user to a specific monster.
VoidCallback goToMonsterFn(BuildContext context, int monsterId, {bool replace = false}) {
  return () async {
    if ((monsterId ?? 0) == 0) {
      return null;
    }
    Fimber.i('Navigating to monster $monsterId');
    if (replace) {
      return Navigator.pushReplacementNamed(context, MonsterDetailArgs.routeName,
          arguments: MonsterDetailArgs(monsterId));
    } else {
      return Navigator.pushNamed(context, MonsterDetailArgs.routeName,
          arguments: MonsterDetailArgs(monsterId));
    }
  };
}

/// Arguments to the dungeon detail route.
class DungeonDetailArgs {
  static const routeName = '/dungeonDetail';
  static const dungeonOverviewRouteName = '/dungeonDetail/dungeonOverview';
  final FullDungeon dungeon;

  const DungeonDetailArgs(this.dungeon);
}

/// Wraps a widget with an onClick that sends them to the dungeon. If ink is specified, will add a
/// ripple effect.
Widget wrapDungeonLink(BuildContext context, Widget child, int dungeonId,
    {int subDungeonId, bool ink = false}) {
  dungeonId ??= 0;
  if (dungeonId == 0) {
    return child;
  }
  var onTap = goToDungeonFn(context, dungeonId, subDungeonId);
  return ink ? InkWell(child: child, onTap: onTap) : GestureDetector(child: child, onTap: onTap);
}

/// Returns a Function which when executed, sends the user to a specific dungeon/subdungeon.
VoidCallback goToDungeonFn(BuildContext context, int dungeonId,
    [int subDungeonId, bool replace = false]) {
  return () async {
    if ((dungeonId ?? 0) == 0) {
      return null;
    }
    Fimber.i('Navigating to dungeon $dungeonId / $subDungeonId');
    final fullDungeon = await getIt<DungeonsDao>().lookupFullDungeon(dungeonId, subDungeonId);
    var args = DungeonDetailArgs(fullDungeon);
    if (replace) {
      return Navigator.pushReplacementNamed(context, DungeonDetailArgs.routeName, arguments: args);
    } else {
      return Navigator.pushNamed(context, DungeonDetailArgs.routeName, arguments: args);
    }
  };
}

/// Arguments for the sub dungeon selection view. We are guaranteed to have the dungeon data at
/// this point, so it's injected directly instead of by id.
class SubDungeonSelectionArgs {
  static const routeName = '/subDungeonSelection';
  final FullDungeon fullDungeon;

  SubDungeonSelectionArgs(this.fullDungeon);
}

/// Returns a Function which when executed, sends the user to sub dungeon selection.
VoidCallback goToSubDungeonSelectionFn(BuildContext context, FullDungeon dungeon) {
  return () async {
    return Navigator.pushNamed(context, SubDungeonSelectionArgs.routeName,
        arguments: SubDungeonSelectionArgs(dungeon));
  };
}

/// Arguments for the filter modification view. Contains the filter that needs to be updated.
class FilterMonstersArgs {
  static const routeName = '/filterMonsters';
  final MonsterDisplayState displayState;

  FilterMonstersArgs(this.displayState);
}

/// Returns a Function which when executed, sends the user to modify filter screen.
VoidCallback goToFilterMonstersFn(BuildContext context, MonsterDisplayState displayState) {
  return () async {
    return Navigator.pushNamed(context, FilterMonstersArgs.routeName,
        arguments: FilterMonstersArgs(displayState));
  };
}

/// Arguments to the egg machines route.
class EggMachineArgs {
  static const routeName = '/eggMachines';
  final Country server;
  final List<FullEggMachine> machines;

  EggMachineArgs(this.server, this.machines);
}

/// Returns a Function which when executed, sends the user to the egg machines display.
VoidCallback goToEggMachineFn(BuildContext context, Country server) {
  return () async {
    final machines = await getIt<EggMachinesDao>().findEggMachines(server);
    return Navigator.pushNamed(context, EggMachineArgs.routeName,
        arguments: EggMachineArgs(server, machines));
  };
}

/// Arguments to the exchange route.
class ExchangeArgs {
  static const routeName = '/exchanges';
  final Country server;
  final List<FullExchange> exchanges;

  ExchangeArgs(this.server, this.exchanges);
}

/// Returns a Function which when executed, sends the user to the exchange display.
VoidCallback goToExchangeFn(BuildContext context, Country server) {
  return () async {
    var exchanges = await getIt<ExchangesDao>().findExchanges(server);
    return Navigator.pushNamed(context, ExchangeArgs.routeName,
        arguments: ExchangeArgs(server, exchanges));
  };
}

/// Arguments to the monster compare route.
class MonsterCompareArgs {
  static const routeName = '/monsterCompare';
  final FullMonster left;
  final FullMonster right;

  MonsterCompareArgs(this.left, this.right);
}

/// Returns a Function which when executed, sends the user to the monster compare screen.
///
/// left and right are optional, used to prepopulate the view.
VoidCallback goToMonsterCompareFn(BuildContext context, {FullMonster left, FullMonster right}) {
  return () async {
    return Navigator.pushNamed(context, MonsterCompareArgs.routeName,
        arguments: MonsterCompareArgs(left, right));
  };
}

Future<void> goToMonsterCompare(BuildContext context, int leftMonsterId, int rightMonsterId) async {
  var dao = getIt<MonstersDao>();
  var left = await dao.fullMonster(leftMonsterId);
  var right = await dao.fullMonster(rightMonsterId);
  return Navigator.pushNamed(context, MonsterCompareArgs.routeName,
      arguments: MonsterCompareArgs(left, right));
}
