import 'package:dadguide2/components/config/service_locator.dart';
import 'package:dadguide2/components/models/data_objects.dart';
import 'package:dadguide2/components/models/enums.dart';
import 'package:dadguide2/data/tables.dart';
import 'package:dadguide2/screens/monster/monster_search_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fimber/flutter_fimber.dart';

/// Describes what should happen when a monster in the list is clicked on.
enum MonsterListAction {
  showDetails,
  returnResult,
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
Widget wrapMonsterLink(BuildContext context, Widget child, int monsterId, {bool ink: false}) {
  monsterId ??= 0;
  if (monsterId == 0) {
    return child;
  }
  var onTap = goToMonsterFn(context, monsterId);
  return ink ? InkWell(child: child, onTap: onTap) : GestureDetector(child: child, onTap: onTap);
}

/// Returns a Function which when executed, sends the user to a specific monster.
Function goToMonsterFn(BuildContext context, int monsterId, {bool replace: false}) {
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
/// subDungeonId is optional.
class DungeonDetailArgs {
  static const routeName = '/dungeonDetail';
  final int dungeonId;
  final int subDungeonId;

  const DungeonDetailArgs(this.dungeonId, this.subDungeonId);
}

/// Wraps a widget with an onClick that sends them to the dungeon. If ink is specified, will add a
/// ripple effect.
Widget wrapDungeonLink(BuildContext context, Widget child, int dungeonId,
    {int subDungeonId, bool ink: false}) {
  dungeonId ??= 0;
  if (dungeonId == 0) {
    return child;
  }
  var onTap = goToDungeonFn(context, dungeonId, subDungeonId);
  return ink ? InkWell(child: child, onTap: onTap) : GestureDetector(child: child, onTap: onTap);
}

/// Returns a Function which when executed, sends the user to a specific dungeon/subdungeon.
Function goToDungeonFn(BuildContext context, int dungeonId, [int subDungeonId]) {
  return () async {
    if ((dungeonId ?? 0) == 0) {
      return null;
    }
    Fimber.i('Navigating to dungeon $dungeonId / $subDungeonId');
    return Navigator.pushNamed(context, DungeonDetailArgs.routeName,
        arguments: DungeonDetailArgs(dungeonId, subDungeonId));
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
Function goToSubDungeonSelectionFn(BuildContext context, FullDungeon dungeon) {
  return () async {
    return Navigator.pushNamed(context, SubDungeonSelectionArgs.routeName,
        arguments: SubDungeonSelectionArgs(dungeon));
  };
}

/// Arguments for the sub dungeon selection view. We are guaranteed to have the dungeon data at
/// this point, so it's injected directly instead of by id.
class FilterMonstersArgs {
  static const routeName = '/filterMonsters';
  final MonsterDisplayState displayState;

  FilterMonstersArgs(this.displayState);
}

/// Returns a Function which when executed, sends the user to sub dungeon selection.
Function goToFilterMonstersFn(BuildContext context, MonsterDisplayState displayState) {
  return () async {
    return Navigator.pushNamed(context, FilterMonstersArgs.routeName,
        arguments: FilterMonstersArgs(displayState));
  };
}

/// Arguments to the egg machines route.
class EggMachineArgs {
  static const routeName = '/eggMachines';
  final Country server;

  EggMachineArgs(this.server);
}

/// Returns a Function which when executed, sends the user to the egg machines display.
Function goToEggMachineFn(BuildContext context, Country server) {
  return () async {
    return Navigator.pushNamed(context, EggMachineArgs.routeName,
        arguments: EggMachineArgs(server));
  };
}

/// Arguments to the exchange route.
class ExchangeArgs {
  static const routeName = '/exchanges';
  final Country server;

  ExchangeArgs(this.server);
}

/// Returns a Function which when executed, sends the user to the exchange display.
Function goToExchangeFn(BuildContext context, Country server) {
  return () async {
    return Navigator.pushNamed(context, ExchangeArgs.routeName, arguments: ExchangeArgs(server));
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
Function goToMonsterCompareFn(BuildContext context, {FullMonster left, FullMonster right}) {
  return () async {
    return Navigator.pushNamed(context, MonsterCompareArgs.routeName,
        arguments: MonsterCompareArgs(left, right));
  };
}

Future<void> goToMonsterCompare(BuildContext context, int leftMonsterId, int rightMonsterId) async {
  var dao = getIt<MonstersDao>();
  var left = await dao.fullMonster(leftMonsterId);
  var right = await dao.fullMonster(rightMonsterId);
  Navigator.pushNamed(context, MonsterCompareArgs.routeName,
      arguments: MonsterCompareArgs(left, right));
}
