import 'package:dadguide2/data/data_objects.dart';
import 'package:dadguide2/screens/monster/monster_search_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fimber/flutter_fimber.dart';

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
Function goToMonsterFn(BuildContext context, int monsterId) {
  return () async {
    if ((monsterId ?? 0) == 0) {
      return null;
    }
    Fimber.i('Navigating to monster $monsterId');
    return Navigator.pushNamed(context, MonsterDetailArgs.routeName,
        arguments: MonsterDetailArgs(monsterId));
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
