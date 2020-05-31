import 'package:dadguide2/components/config/service_locator.dart';
import 'package:dadguide2/components/firebase/analytics.dart';
import 'package:dadguide2/components/images/icons.dart';
import 'package:dadguide2/components/images/images.dart';
import 'package:dadguide2/components/models/data_objects.dart';
import 'package:dadguide2/components/ui/buttons.dart';
import 'package:dadguide2/components/ui/containers.dart';
import 'package:dadguide2/components/ui/navigation.dart';
import 'package:dadguide2/components/utils/email.dart';
import 'package:dadguide2/components/utils/formatting.dart';
import 'package:dadguide2/components/utils/youtube.dart';
import 'package:dadguide2/data/tables.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:dadguide2/screens/dungeon_info/sub_dungeon_items.dart';
import 'package:dadguide2/theme/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fimber/flutter_fimber.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';
import 'package:quiver/iterables.dart';
import 'package:screenshot/screenshot.dart';

import 'dungeon_behavior.dart';

class DungeonDetailScreen extends StatefulWidget {
  final DungeonDetailArgs args;

  DungeonDetailScreen(this.args) {
    screenChangeEvent(runtimeType.toString());
  }

  @override
  _DungeonDetailScreenState createState() => _DungeonDetailScreenState(args);
}

class _DungeonDetailScreenState extends State<DungeonDetailScreen> {
  final DungeonDetailArgs _args;

  Future<FullDungeon> loadingFuture;
  ScreenshotController screenshotController = ScreenshotController();

  _DungeonDetailScreenState(this._args);

  @override
  void initState() {
    super.initState();
    loadingFuture = getIt<DungeonsDao>().lookupFullDungeon(_args.dungeonId, _args.subDungeonId);
  }

  @override
  Widget build(BuildContext context) {
    return OpaqueContainer(
      child: Column(
        children: [
          DungeonDetailActionsBar(screenshotController),
          Expanded(child: _retrieveDungeon()),
        ],
      ),
    );
  }

  FutureBuilder<FullDungeon> _retrieveDungeon() {
    return FutureBuilder<FullDungeon>(
        future: loadingFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            Fimber.e('Error retrieving dungeon', ex: snapshot.error);
            return Center(child: Icon(Icons.error));
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          return DungeonDetailContents(snapshot.data, screenshotController);
        });
  }
}

class DungeonDetailContents extends StatelessWidget {
  final FullDungeon _data;
  final ScreenshotController screenshotController;

  const DungeonDetailContents(this._data, this.screenshotController, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);

    var battles = _data.selectedSubDungeon.battles;
    var battleWidgets = <Widget>[
      ...(battles.length > 11
          ? partition(battles, 5).map((c) => ExpandableDungeonTile(c))
          : battles.map((b) => DungeonBattle(b)))
    ];

    return Provider.value(
      value: _data,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: ScreenshotContainer(
                controller: screenshotController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DungeonHeader(_data),
                    DungeonSubHeader(_data.selectedSubDungeon),
                    ...battleWidgets,
                    SizedBox(height: 8),
                    GreyBar(
                        children: [Text(loc.subDungeonSelectionTitle, style: subtitle(context))]),
                    SubDungeonList(_data),
                    MailIssues(_data),
                  ],
                ),
              ),
            ),
          ),
          DungeonDetailOptionsBar(_data),
        ],
      ),
    );
  }
}

class DungeonHeader extends StatelessWidget {
  final FullDungeon _model;

  const DungeonHeader(this._model, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var m = _model;
    var loc = DadGuideLocalizations.of(context);

    var subDungeon = _model.selectedSubDungeon.subDungeon;
    var mp = subDungeon.mpAvg ?? 0;
    var mpPerStam = mp / subDungeon.stamina;

    return Container(
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          children: [
            PadIcon(_model.dungeon.iconId),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.name()),
                  DefaultTextStyle(
                      style: Theme.of(context).textTheme.caption,
                      child: Row(children: [
                        DadGuideIcons.mp,
                        Text(loc.mpAndMpPerStam(mp, mpPerStam.toStringAsFixed(1))),
                      ])),
                ],
              ),
            ),
          ],
        ));
  }
}

class DungeonSubHeader extends StatelessWidget {
  final FullSubDungeon _model;

  const DungeonSubHeader(this._model, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);

    var m = _model;
    return Container(
      color: grey(context, 300),
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    alignment: Alignment.centerLeft,
                    child: Text(m.name()),
                  ),
                ],
              ),
              Spacer(),
              for (var rewardIconId in m.rewardIconIds)
                PadIcon(rewardIconId, size: 32, monsterLink: true)
            ],
          ),
          // Probably should be a row with col, sizedbox, col
          DefaultTextStyle(
            style: Theme.of(context).textTheme.caption,
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(loc.dungeonStamina(m.subDungeon.stamina)),
                    Text(loc.dungeonFloors(m.subDungeon.floors)),
                  ],
                ),
                SizedBox(width: 20),
                Expanded(child: ExpCoinTable(m.subDungeon)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ExpCoinTable extends StatelessWidget {
  final SubDungeon sd;
  const ExpCoinTable(this.sd, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (sd.expMin == null) return Container(width: 0.0, height: 0.0);

    var loc = DadGuideLocalizations.of(context);

    return Table(
      children: [
        TableRow(children: [
          cell(''),
          cell(loc.min),
          cell(loc.max),
          cell(loc.avg),
          cell(loc.avgPerStam),
        ]),
        TableRow(children: [
          cell(loc.exp),
          intCell(sd.expMin),
          intCell(sd.expMax),
          intCell(sd.expAvg),
          intCell(sd.stamina == 0 ? 0 : ((sd.expAvg ?? 0) ~/ sd.stamina)),
        ]),
        TableRow(children: [
          cell(loc.coin),
          intCell(sd.coinMin),
          intCell(sd.coinMax),
          intCell(sd.coinAvg),
          intCell(sd.stamina == 0 ? 0 : ((sd.coinAvg ?? 0) ~/ sd.stamina)),
        ]),
      ],
    );
  }

  Widget cell(String text) => TableCell(child: Text(text, textAlign: TextAlign.end));
  Widget intCell(int value) =>
      TableCell(child: Text(value != null ? commaFormat(value) : '', textAlign: TextAlign.end));
}

class DungeonBattle extends StatelessWidget {
  final Battle _model;

  const DungeonBattle(this._model, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);

    var text = loc.battleFloor(_model.stage);
    if (_model.stage == -1) {
      text = loc.battleInvades;
    } else if (_model.stage == 0) {
      text = loc.battleCommon;
    }
    return Column(children: [
      GreyBar(children: [
        Text(text),
        Spacer(),
        Text(loc.battleDrop),
      ]),
      for (var encounter in _model.encounters) DungeonEncounter(encounter)
    ]);
  }
}

class DungeonEncounter extends StatelessWidget {
  final FullEncounter model;

  const DungeonEncounter(this.model, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var dungeon = Provider.of<FullDungeon>(context);
    var inputs = BehaviorWidgetInputs(model.encounter.atk, dungeon.selectedSubDungeon.esLibrary);

    var showBehaviors =
        dungeon.selectedSubDungeon.subDungeon.technical && model.levelBehaviors.isNotEmpty;

    return Provider.value(
      value: inputs,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PortraitAndColorBar(monster: model.monster),
                SizedBox(width: 4),
                Expanded(child: EncounterDetailsBar(model: model)),
                Column(children: [
                  for (var drop in model.drops) PadIcon(drop.monsterId, size: 24, monsterLink: true)
                ])
              ],
            ),
            if (showBehaviors)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 2, right: 2),
                child: EncounterBehavior(model.approved, model.levelBehaviors),
              )
          ],
        ),
      ),
    );
  }
}

class PortraitAndColorBar extends StatelessWidget {
  final Monster monster;
  const PortraitAndColorBar({Key key, this.monster}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PadIcon(monster.monsterId, monsterLink: true),
        SizedBox(height: 2),
        MonsterColorBar(monster),
      ],
    );
  }
}

/// The 1 or 2 part attribute bar that displays below an encounter icon.
class MonsterColorBar extends StatelessWidget {
  final Monster _model;

  const MonsterColorBar(this._model, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: The SizedBox here is a hack because I can't get it to expand properly =(
    return Container(
      decoration: BoxDecoration(border: Border.all()),
      child: Row(
        children: [
          Container(
            color: _colorFor(_model.attribute1Id),
            child: SizedBox(width: 23, height: 6),
          ),
          Container(
            color: _colorFor(_model.attribute2Id ?? _model.attribute1Id),
            child: SizedBox(width: 23, height: 6),
          ),
        ],
      ),
    );
  }

  Color _colorFor(int attributeId) {
    switch (attributeId) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.yellow;
      case 4:
        return Colors.deepPurple;
      default:
        throw 'Unexpected attribute id: $attributeId';
    }
  }
}

class EncounterDetailsBar extends StatelessWidget {
  final FullEncounter model;
  const EncounterDetailsBar({Key key, this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () async {
        await showDialog<void>(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: Text('Details for ${model.name()}'),
              content: Table(
                children: [
                  TableRow(children: [Text('Enemy ID'), Text('${model.encounter.enemyId}')]),
                  TableRow(children: [Text('Level'), Text('${model.encounter.level}')]),
                  TableRow(children: [Text('XP'), Text('TODO: set this')]),
                ],
              ),
            );
          },
        );
      },
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(children: [
              typeContainer(model.monster.type1Id, size: 18, leftPadding: 4),
              typeContainer(model.monster.type2Id, size: 18, leftPadding: 4),
              typeContainer(model.monster.type3Id, size: 18, leftPadding: 4),
            ]),
            Text(model.name()),
            IconTheme(
              data: IconThemeData(size: Theme.of(context).textTheme.caption.fontSize),
              child: DefaultTextStyle(
                  style: Theme.of(context).textTheme.caption,
                  child: Row(
                    children: [
                      item(1, Icons.refresh, model.encounter.turns, context),
                      item(3, Feather.heart, model.encounter.hp, context),
                      item(3, MaterialCommunityIcons.sword, model.encounter.atk, context),
                      item(3, Feather.shield, model.encounter.defence, context),
                    ],
                  )),
            ),
          ]),
    );
  }

  Widget item(int flex, IconData iconData, int value, BuildContext context) {
    return Expanded(
        flex: flex,
        child:
            Row(children: [Icon(iconData, color: grey(context, 1000)), Text(commaFormat(value))]));
  }
}

/// Bar at the top of the view, currently only contains the back button.
class DungeonDetailActionsBar extends StatelessWidget {
  final ScreenshotController screenshotController;
  DungeonDetailActionsBar(this.screenshotController);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.blue,
        padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Row(
          children: [
            SizedBox(
                width: 32,
                height: 32,
                child: InkWell(
                  child: Icon(Icons.chevron_left),
                  onTap: () => Navigator.of(context).pop(),
                )),
            Spacer(),
            ScreenshotButton(controller: screenshotController),
          ],
        ));
  }
}

/// Bar at the bottom with action buttons, e.g. open YouTube.
class DungeonDetailOptionsBar extends StatelessWidget {
  final FullDungeon _data;

  DungeonDetailOptionsBar(this._data);

  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);

    return TabOptionsBar([
      IconButton(
        padding: EdgeInsets.all(0),
        icon: Icon(Icons.format_list_bulleted),
        onPressed: goToSubDungeonSelectionFn(context, _data),
      ),
      IconButton(
        padding: EdgeInsets.all(0),
        icon: Icon(Icons.live_tv),
        onPressed: () async {
          try {
            await launchYouTubeSearch(_data.dungeon.nameJp);
          } catch (ex, st) {
            Fimber.w('Failed to launch YT', ex: ex, stacktrace: st);
            Scaffold.of(context).showSnackBar(SnackBar(content: Text(loc.ytLaunchError)));
          }
        },
      ),
    ]);
  }
}

/// Widget which, when clicked, sends an error email.
class MailIssues extends StatelessWidget {
  final FullDungeon _data;

  const MailIssues(this._data, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);

    return GestureDetector(
      onTap: () => sendDungeonErrorEmail(_data.dungeon, _data.selectedSubDungeon.subDungeon),
      child: Card(
          color: grey(context, 300),
          child: Row(
            children: [
              Icon(Icons.mail_outline),
              Text(loc.reportBadInfo, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          )),
    );
  }
}

class GreyBar extends StatelessWidget {
  final List<Widget> children;

  const GreyBar({Key key, this.children}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: grey(context, 400),
      padding: const EdgeInsets.all(4.0),
      child: Row(children: children),
    );
  }
}

class ExpandableDungeonTile extends StatelessWidget {
  final List<Battle> battles;
  ExpandableDungeonTile(this.battles);

  @override
  Widget build(BuildContext context) {
    var title = battles.length > 1
        ? 'Floors ${battles.first.stage} - ${battles.last.stage}'
        : 'Floor ${battles.first.stage}';

    return ExpansionTile(
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      key: PageStorageKey(title),
      subtitle: Wrap(
        children: <Widget>[
          for (var battle in battles)
            for (var encounter in battle.encounters.take(3)) PadIcon(encounter.monster.monsterId)
        ],
      ),
      children: <Widget>[for (var battle in battles) DungeonBattle(battle)],
    );
  }
}
