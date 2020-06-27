import 'package:dadguide2/components/config/settings_manager.dart';
import 'package:dadguide2/components/firebase/analytics.dart';
import 'package:dadguide2/components/images/images.dart';
import 'package:dadguide2/components/models/data_objects.dart';
import 'package:dadguide2/components/models/enums.dart';
import 'package:dadguide2/components/ui/buttons.dart';
import 'package:dadguide2/components/ui/containers.dart';
import 'package:dadguide2/components/ui/navigation.dart';
import 'package:dadguide2/data/tables.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:dadguide2/theme/style.dart';
import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

class DungeonOverviewOptions with ChangeNotifier {
  final FullDungeon data;
  final killerEncounters = <MonsterType, Map<int, FullEncounter>>{};

  DungeonOverviewOptions(this.data) {
    for (var encounter in data.selectedSubDungeon.encounters) {
      for (var type in encounter.monster.types) {
        killerEncounters.putIfAbsent(type, () => {});
        killerEncounters[type][encounter.encounter.enemyId] = encounter;
      }
    }
  }

  void notify() {
    notifyListeners();
  }

  bool get oneColumn => Prefs.dungeonOverviewColumns == 1;
  DungeonOverviewType get type => Prefs.dungeonOverviewType;
  bool get showType => Prefs.dungeonOverviewShowType;
  bool get showAbilities => Prefs.dungeonOverviewShowAbilities;
}

class DungeonOverviewScreen extends StatelessWidget {
  final DungeonDetailArgs args;
  final screenshotController = ScreenshotController();

  DungeonOverviewScreen(this.args) {
    screenChangeEvent(runtimeType.toString());
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DungeonOverviewOptions(args.dungeon),
      child: Scaffold(
        appBar: AppBar(
          title: FittedBox(child: Text('Dungeon Overview')),
          actions: [
            SettingsButton(),
            ScreenshotButton(controller: screenshotController),
          ],
        ),
        body: DungeonOverviewContents(args.dungeon, screenshotController),
      ),
    );
  }
}

class SettingsButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var options = Provider.of<DungeonOverviewOptions>(context);
    return IconButton(
        icon: Icon(Icons.settings),
        onPressed: () =>
            showDialog<void>(context: context, builder: (_) => SettingsDialog(options)));
  }
}

class SettingsDialog extends StatelessWidget {
  final DungeonOverviewOptions options;

  const SettingsDialog(this.options, {Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).copyWith(
      accentColor: grey(context, 1000),
      toggleableActiveColor: Colors.lightBlueAccent,
    );

    return Theme(
      data: theme,
      child: SimpleDialog(
        title: Text('Settings'),
        children: <Widget>[
          DropdownPreference<int>(
            'Columns',
            PrefKeys.dungeonOverviewColumns,
            defaultVal: 1,
            values: [1, 2],
            onChange: (_) => options.notify(),
          ),
          DropdownPreference<int>(
            'Type',
            PrefKeys.dungeonOverviewType,
            defaultVal: DungeonOverviewType.floors.id,
            values: DungeonOverviewType.all.map((e) => e.id).toList(),
            displayValues: DungeonOverviewType.all.map((e) => e.name).toList(),
            onChange: (_) => options.notify(),
          ),
          CheckboxPreference(
            'Show Type',
            PrefKeys.dungeonOverviewShowType,
            onChange: () => options.notify(),
          ),
//        Abilities not supported yet
//        CheckboxPreference(
//          'Show Abilities',
//          PrefKeys.dungeonOverviewShowAbilities,
//          onChange: () => options.notify(),
//        ),
        ],
      ),
    );
  }
}

class BattleRow {
  final Battle left;
  final Battle right;
  BattleRow(this.left, this.right);
}

class DungeonOverviewContents extends StatelessWidget {
  final FullDungeon data;
  final ScreenshotController screenshotController;

  const DungeonOverviewContents(this.data, this.screenshotController, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var options = Provider.of<DungeonOverviewOptions>(context);

    return SingleChildScrollView(
      child: ScreenshotContainer(
        controller: screenshotController,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  PadIcon(data.selectedSubDungeon.subDungeon.iconId),
                  SizedBox(width: 8),
                  Flexible(child: FittedBox(child: Text(data.name(), style: headline(context)))),
                ],
              ),
              SizedBox(height: 8),
              options.type == DungeonOverviewType.floors ? FloorsLayout() : KillersLayout(),
            ],
          ),
        ),
      ),
    );
  }
}

class FloorsLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var options = Provider.of<DungeonOverviewOptions>(context);
    return options.oneColumn ? FloorsOneColumnLayout() : FloorsTwoColumnLayout();
  }
}

class FloorsTwoColumnLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var options = Provider.of<DungeonOverviewOptions>(context);
    var battles = options.data.selectedSubDungeon.battles;

    var col2Start = (battles.length / 2).ceil();
    var rows = [
      for (int i = 0, j = col2Start; i < col2Start; i++, j++)
        BattleRow(
          battles[i],
          j >= battles.length ? null : battles[j],
        ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Table(
          columnWidths: {1: FixedColumnWidth(8)},
          children: [
            for (var row in rows)
              TableRow(children: [
                DungeonBattle(row.left),
                SizedBox(),
                row.right != null ? DungeonBattle(row.right) : SizedBox(),
              ]),
          ],
        ),
      ],
    );
  }
}

class FloorsOneColumnLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var options = Provider.of<DungeonOverviewOptions>(context);
    var battles = options.data.selectedSubDungeon.battles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (var b in battles) DungeonBattle(b),
      ],
    );
  }
}

class DungeonBattle extends StatelessWidget {
  final Battle battle;

  const DungeonBattle(this.battle, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var loc = context.loc;

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(loc.battleForStage(battle.stage), style: subtitle(context)),
          Wrap(
            runSpacing: 4,
            children: <Widget>[
              for (var e in battle.encounters) DungeonEncounter(e),
            ],
          )
        ],
      ),
    );
  }
}

class KillersLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var options = Provider.of<DungeonOverviewOptions>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (var entry in options.killerEncounters.entries) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              typeContainer(entry.key.id, size: 48),
              Expanded(
                child: Wrap(
                  runSpacing: 4,
                  children: <Widget>[
                    for (var encounter
                        in entry.value.values.toList()
                          ..sort((l, r) => l.monster.monsterId - r.monster.monsterId))
                      DungeonEncounter(encounter),
                  ],
                ),
              ),
            ],
          ),
          Divider(),
        ],
      ],
    );
  }
}

class DungeonEncounter extends StatelessWidget {
  final FullEncounter encounter;

  const DungeonEncounter(this.encounter, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var options = Provider.of<DungeonOverviewOptions>(context);

    return Column(
      children: <Widget>[
        PadIcon(encounter.monster.monsterId, size: 64),
        if (options.showType) TypesRowChunk(encounter.monster),
      ],
    );
  }
}

// TODO: This was c/p from elsewhere, maybe make it shared. Some modifications though.
class TypesRowChunk extends StatelessWidget {
  final Monster monster;

  const TypesRowChunk(this.monster);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        typeContainer(monster.type1Id, size: 20),
        typeContainer(monster.type2Id, size: 20),
        typeContainer(monster.type3Id, size: 20),
      ],
    );
  }
}
