import 'package:dadguide2/data/data_objects.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fimber/flutter_fimber.dart';

class MonsterDetailArgs {
  static const routeName = '/monsterDetail';
  final int monsterId;

  const MonsterDetailArgs(this.monsterId);
}

Widget wrapMonsterLink(BuildContext context, Widget child, int monsterId, {bool ink: false}) {
  monsterId ??= 0;
  if (monsterId == 0) {
    return child;
  }
  var onTap = goToMonsterFn(context, monsterId);
  return ink ? InkWell(child: child, onTap: onTap) : GestureDetector(child: child, onTap: onTap);
}

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

class DungeonDetailArgs {
  static const routeName = '/dungeonDetail';
  final int dungeonId;
  final int subDungeonId;

  const DungeonDetailArgs(this.dungeonId, this.subDungeonId);
}

Widget wrapDungeonLink(BuildContext context, Widget child, int dungeonId,
    {int subDungeonId, bool ink: false}) {
  dungeonId ??= 0;
  if (dungeonId == 0) {
    return child;
  }
  var onTap = goToDungeonFn(context, dungeonId, subDungeonId);
  return ink ? InkWell(child: child, onTap: onTap) : GestureDetector(child: child, onTap: onTap);
}

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

class SubDungeonSelectionArgs {
  static const routeName = '/subDungeonSelection';
  final FullDungeon fullDungeon;

  SubDungeonSelectionArgs(this.fullDungeon);
}

Function goToSubDungeonSelectionFn(BuildContext context, FullDungeon dungeon) {
  return () async {
    return Navigator.pushNamed(context, SubDungeonSelectionArgs.routeName,
        arguments: SubDungeonSelectionArgs(dungeon));
  };
}
