import 'package:dadguide2/components/config/service_locator.dart';
import 'package:dadguide2/components/config/settings_manager.dart';
import 'package:dadguide2/components/firebase/analytics.dart';
import 'package:dadguide2/components/images/icons.dart';
import 'package:dadguide2/components/images/images.dart';
import 'package:dadguide2/components/models/data_objects.dart';
import 'package:dadguide2/components/models/enums.dart';
import 'package:dadguide2/components/ui/buttons.dart';
import 'package:dadguide2/components/ui/containers.dart';
import 'package:dadguide2/components/ui/monster.dart';
import 'package:dadguide2/components/ui/navigation.dart';
import 'package:dadguide2/components/utils/email.dart';
import 'package:dadguide2/components/utils/youtube.dart';
import 'package:dadguide2/data/tables.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:dadguide2/screens/monster_info/utils.dart';
import 'package:dadguide2/theme/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fimber/flutter_fimber.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:tuple/tuple.dart';

import 'evolutions.dart';
import 'monster_info_image.dart';

/// Can be used to rebuild part of the screen.
class RebuildMonsterScreenNotifier with ChangeNotifier {
  void rebuild() {
    notifyListeners();
  }
}

/// Loads the monster data given by args, and displays it in a MonsterDetailContents.
class MonsterDetailScreen extends StatefulWidget {
  final MonsterDetailArgs args;

  MonsterDetailScreen(this.args) {
    screenChangeEvent(runtimeType.toString());
  }

  @override
  _MonsterDetailScreenState createState() => _MonsterDetailScreenState();
}

class _MonsterDetailScreenState extends State<MonsterDetailScreen> {
  Future<FullMonster> loadingFuture;
  ScreenshotController screenshotController = ScreenshotController();

  _MonsterDetailScreenState();

  @override
  void initState() {
    super.initState();
    loadingFuture = getIt<MonstersDao>().fullMonster(widget.args.monsterId);
  }

  @override
  Widget build(BuildContext context) {
    return OpaqueContainer(
      child: Column(
        children: [
          // TODO: The possibility to click screenshot before the widget is loaded exists, fix it.
          MonsterDetailBar(widget.args.monsterId, screenshotController),
          Expanded(child: _retrieveMonster()),
        ],
      ),
    );
  }

  FutureBuilder<FullMonster> _retrieveMonster() {
    return FutureBuilder<FullMonster>(
        future: loadingFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            Fimber.e('Failed to load monster data', ex: snapshot.error);
            return Center(child: Icon(Icons.error));
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
              child: Screenshot(
                  controller: screenshotController,
                  child: OpaqueContainer(child: MonsterDetailContents(snapshot.data))));
        });
  }
}

/// Displays info for a single monster, including the image, awakenings, active, leader, stats, etc.
class MonsterDetailContents extends StatelessWidget {
  final FullMonster _data;

  const MonsterDetailContents(this._data, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = DadGuideLocalizations.of(context);

    final activeSkill = _data.activeSkill;
    final hasSkillups = activeSkill != null && activeSkill.turnMin != activeSkill.turnMax;

    return Column(
      children: [
        MonsterDetailPortrait(_data),
        Divider(),
        // TODO: Probably split this up a bit more, it's a bit massive.
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Comment here to maintain spacing.
              MonsterDetailHeader(_data),

              SizedBox(height: 4),
              MonsterLevelStatTable(_data),

              SizedBox(height: 4),
              Text(loc.monsterInfo297Awoken, style: subtitle(context)),
              MonsterWeightedStatTable(_data),

              if (_data.monster.inheritable)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4),
                    Text(loc.monsterInfoStatBonus, style: subtitle(context)),
                    MonsterAssistStatTable(_data),
                  ],
                ),

              if (_data.monster.inheritable)
                SizedBox(height: 4),

              if (_data.killers.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4),
                    Text(loc.monsterInfoAvailableKillers),
                    Row(children: [
                      for (var killer in _data.killers)
                        Padding(
                            padding: EdgeInsets.only(right: 4),
                            child: latentContainer(killer.id, size: 36))
                    ]),
                  ],
                ),

              if (_data.leaderSkill != null || _data.activeSkill != null)
                Divider(thickness: 2),

              if (activeSkill != null)
                Padding(
                    child: MonsterActiveSkillSection(activeSkill),
                    padding: EdgeInsets.only(top: 4)),

              if (activeSkill != null)
                Divider(),

              if (_data.leaderSkill != null)
                Padding(
                    child: MonsterLeaderSkillSection(_data.leaderSkill),
                    padding: EdgeInsets.only(top: 4)),

              if (_data.leaderSkill != null)
                Padding(
                    child: MonsterLeaderInfoTable(_data),
                    padding: EdgeInsets.only(top: 4, bottom: 8)),

              if (hasSkillups)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: MonsterSkillups(_data.skillUpMonsters),
                ),

              if (hasSkillups)
                Padding(
                    child: MonsterSkillupDropLocations(_data), padding: EdgeInsets.only(top: 4)),

              SizedBox(height: 8),
              MonsterDropLocations(_data.dropLocations, loc.monsterInfoDropsTitle),

              if (_data.awakenings.isNotEmpty)
                Padding(
                  child: AwokenSkillSection(_data.awakenings),
                  padding: EdgeInsets.only(top: 8),
                ),

              if (_data.superAwakenings.isNotEmpty)
                Padding(
                    child: AwokenSkillSection(_data.superAwakenings),
                    padding: EdgeInsets.only(top: 8)),

              SizedBox(height: 8),
              MonsterBuySellFeedSection(_data.monster),

              if (_data.evolutions.isNotEmpty || _data.transformations.isNotEmpty)
                Padding(child: MonsterEvolutions(_data), padding: EdgeInsets.only(top: 8)),

              if (_data.fullSeries != null)
                Padding(child: MonsterSeries(_data), padding: EdgeInsets.only(top: 4)),

              if (_data.materialForMonsters.isNotEmpty)
                Padding(child: MonsterMaterialFor(_data), padding: EdgeInsets.only(top: 4)),

              SizedBox(height: 8),
              MonsterHistory(_data),

              SizedBox(height: 8),
              MonsterVideos(_data),

              SizedBox(height: 8),
              MailIssues(_data),
            ],
          ),
        ),
      ],
    );
  }
}

/// Chunk of info below the portrait, including the icon, name, typing, rarity, etc.
class MonsterDetailHeader extends StatelessWidget {
  final FullMonster _data;

  const MonsterDetailHeader(this._data, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);

    var rarity = _data.monster.rarity;
    var cost = loc.monsterInfoCost(_data.monster.cost);
    var topRightText = '★' * rarity + '($rarity) / $cost';

    var equipSkill = _data.equipSkill;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PadIcon(_data.monster.monsterId, inheritable: _data.monster.inheritable),
            Row(
              children: [
                DadGuideIcons.largeMp,
                Text(NumberFormat.decimalPattern().format(_data.monster.sellMp),
                    style: Theme.of(context).textTheme.caption),
              ],
            )
          ],
        ),
        SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DefaultTextStyle(
                style: Theme.of(context).textTheme.caption,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(loc.monsterInfoNo(_data.id())),
                    Text(topRightText),
                  ],
                ),
              ),
              FittedBox(
                alignment: Alignment.centerLeft,
                child: Text(_data.name(), style: Theme.of(context).textTheme.headline6),
              ),
              Row(children: [
                TypeIconText(_data.type1),
                TypeIconText(_data.type2),
                TypeIconText(_data.type3),
                if (equipSkill != null)
                  Row(children: [
                    SizedBox(width: 12),
                    awakeningContainer(equipSkill.awokenSkillId, size: 16),
                    SizedBox(width: 2),
                    Text(equipSkill.name(), style: Theme.of(context).textTheme.caption),
                  ]),
              ])
            ],
          ),
        )
      ],
    );
  }
}

/// Combination of the type icon and type name with padding (null safe for type).
class TypeIconText extends StatelessWidget {
  final MonsterType _monsterType;

  TypeIconText(this._monsterType);

  @override
  Widget build(BuildContext context) {
    if (_monsterType == null) return Container();

    return Row(children: [
      typeContainer(_monsterType.id, leftPadding: 4),
      Padding(
        padding: const EdgeInsets.only(left: 2),
        child: Text(_monsterType.name, style: Theme.of(context).textTheme.caption),
      )
    ]);
  }
}

/// Bar across the top of the monster view; currently only the back button.
class MonsterDetailBar extends StatelessWidget {
  final int monsterId;
  final ScreenshotController screenshotController;

  MonsterDetailBar(this.monsterId, this.screenshotController);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => RebuildMonsterScreenNotifier(),
      child: Consumer<RebuildMonsterScreenNotifier>(
        builder: (_, notifier, __) => Container(
            color: Colors.blue,
            padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
            child: Row(
              children: [
                TrimmedMaterialIconButton(
                    child: IconButton(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  icon: Icon(Icons.chevron_left),
                  onPressed: () => Navigator.of(context).pop(),
                )),
                Spacer(),
                ScreenshotButton(controller: screenshotController),
                TrimmedMaterialIconButton(
                  child: IconButton(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    icon: Icon(FontAwesome.balance_scale),
                    onPressed: () async {
                      var otherMonsterId = Prefs.lastComparedMonster;
                      Prefs.lastComparedMonster = monsterId;
                      await goToMonsterCompare(context, monsterId, otherMonsterId);
                    },
                  ),
                ),
                TopBarDivider(),
                TrimmedMaterialIconButton(
                    child: IconButton(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  icon: Prefs.isFavorite(monsterId) ? Icon(Icons.star) : Icon(Icons.star_border),
                  onPressed: () {
                    Prefs.toggleFavorite(monsterId);
                    notifier.rebuild();
                  },
                )),
              ],
            )),
      ),
    );
  }
}

/// Level 1/99/110 stat table, plus XP required.
class MonsterLevelStatTable extends StatelessWidget {
  final FullMonster _data;

  const MonsterLevelStatTable(this._data, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);

    var m = _data.monster;
    var limitMult = (m.limitMult ?? 0) + 100;
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.caption,
      child: Table(
        columnWidths: {0: FixedColumnWidth(40)},
        border: TableBorder.all(width: 1.0, color: grey(context, 800)),
        children: [
          TableRow(children: [
            cell(loc.monsterInfoLevel),
            cell(loc.monsterInfoHp),
            cell(loc.monsterInfoAtk),
            cell(loc.monsterInfoRcv),
            cell(loc.monsterInfoExp),
          ]),
          TableRow(children: [
            numCell(1),
            numCell(m.hpMin),
            numCell(m.atkMin),
            numCell(m.rcvMin),
            numCell(0),
          ]),
          if (m.level != 1)
            TableRow(children: [
              numCell(m.level),
              numCell(m.hpMax),
              numCell(m.atkMax),
              numCell(m.rcvMax),
              numCell(m.exp),
            ]),
          if (limitMult > 100)
            TableRow(children: [
              numCell(110),
              numCell((m.hpMax * limitMult / 100).round()),
              numCell((m.atkMax * limitMult / 100).round()),
              numCell((m.rcvMax * limitMult / 100).round()),
              numCell(m.exp + 50000000),
            ]),
        ],
      ),
    );
  }
}

/// Level 99/110 stat table, includes awakenings and 297.
class MonsterWeightedStatTable extends StatelessWidget {
  final FullMonster _data;

  const MonsterWeightedStatTable(this._data, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);

    var m = _data.monster;
    var a = _data.awakenings;
    var limitMult = (m.limitMult ?? 0) + 100;

    var maxHp = m.hpMax + 99 * 10;
    var atkMax = m.atkMax + 99 * 5;
    var rcvMax = m.rcvMax + 99 * 3;

    var lbMaxHp = (m.hpMax * limitMult / 100 + 99 * 10).round();
    var lbAtkMax = (m.atkMax * limitMult / 100 + 99 * 5).round();
    var lbRcvMax = (m.rcvMax * limitMult / 100 + 99 * 3).round();

    // Account for stat boosts
    a.forEach((awakening) {
      var aS = awakening.awokenSkill;
      maxHp += aS.adjHp;
      lbMaxHp += aS.adjHp;
      atkMax += aS.adjAtk;
      lbAtkMax += aS.adjAtk;
      rcvMax += aS.adjRcv;
      lbRcvMax += aS.adjRcv;
    });

    return DefaultTextStyle(
      style: Theme.of(context).textTheme.caption,
      child: Table(
        columnWidths: {0: FixedColumnWidth(40)},
        border: TableBorder.all(width: 1.0, color: grey(context, 800)),
        children: [
          TableRow(children: [
            cell(loc.monsterInfoLevel),
            cell(loc.monsterInfoHp),
            cell(loc.monsterInfoAtk),
            cell(loc.monsterInfoRcv),
            cell(loc.monsterInfoWeighted),
          ]),
          TableRow(children: [
            numCell(m.level),
            numCell(maxHp),
            numCell(atkMax),
            numCell(rcvMax),
            numCell(_weighted(maxHp, atkMax, rcvMax)),
          ]),
          if (limitMult > 100)
            TableRow(children: [
              numCell(110),
              numCell(lbMaxHp),
              numCell(lbAtkMax),
              numCell(lbRcvMax),
              numCell(_weighted(lbMaxHp, lbAtkMax, lbRcvMax)),
            ]),
        ],
      ),
    );
  }
}

// Level 99/99+297 stat table for assists.
class MonsterAssistStatTable extends StatelessWidget {
  final FullMonster _data;

  const MonsterAssistStatTable(this._data, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);

    var m = _data.monster;
    var a = _data.awakenings;

    var hp297Max = (m.hpMax + 99 * 10) * .1;
    var atk297Max = (m.atkMax + 99 * 5) * .05;
    var rcv297Max = (m.rcvMax + 99 * 3) * .15;

    var limitMult = (m.limitMult ?? 0) + 100;
    var lbMaxHp = ((m.hpMax * limitMult / 100 + 99 * 10) * .1).round();
    var lbAtkMax = ((m.atkMax * limitMult / 100 + 99 * 5) * .05).round();
    var lbRcvMax = ((m.rcvMax * limitMult / 100 + 99 * 3) * .15).round();

    // TODO: These tables got so damn ugly need to clean up calculation of these stats

    var isEquip = false;

    // Only add stat changes if assist type
    if (a.any((awakening) => awakening.awokenSkill.awokenSkillId == 49)) {
      isEquip = true;
    }

    if (isEquip) {
      a.forEach((awakening) {
        var aS = awakening.awokenSkill;
        hp297Max += aS.adjHp;
        atk297Max += aS.adjAtk;
        rcv297Max += aS.adjRcv;
        lbMaxHp += aS.adjHp;
        lbAtkMax += aS.adjAtk;
        lbRcvMax += aS.adjRcv;
      });
    }

    return DefaultTextStyle(
      style: Theme.of(context).textTheme.caption,
      child: Table(
        columnWidths: {0: FixedColumnWidth(40)},
        border: TableBorder.all(width: 1.0, color: grey(context, 800)),
        children: [
          TableRow(children: [
            cell(loc.monsterInfoLevel),
            cell(loc.monsterInfoHp),
            cell(loc.monsterInfoAtk),
            cell(loc.monsterInfoRcv),
            cell(loc.monsterInfoWeighted),
          ]),
          TableRow(children: [
            cell('${m.level}'),
            numCell(hp297Max),
            numCell(atk297Max),
            numCell(rcv297Max),
            numCell(_weighted(hp297Max, atk297Max, rcv297Max)),
          ]),
          if (limitMult > 100)
            TableRow(children: [
              cell('110'),
              numCell(lbMaxHp),
              numCell(lbAtkMax),
              numCell(lbRcvMax),
              numCell(_weighted(lbMaxHp, lbAtkMax, lbRcvMax)),
            ]),
        ],
      ),
    );
  }
}

int _weighted(num hp, num atk, num rcv) => (hp / 10 + atk / 5 + rcv / 3).round();

/// Active skill info.
class MonsterActiveSkillSection extends StatelessWidget {
  final FullActiveSkill _model;

  MonsterActiveSkillSection(ActiveSkill skill, {Key key})
      : _model = FullActiveSkill(skill),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);
    var lvlText = skillLevelText(loc, _model.skill);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          child: Row(
            children: [
              Text(loc.monsterInfoActiveSkillTitle, style: subtitle(context)),
              SizedBox(width: 8),
              Text(_model.name()),
            ],
          ),
        ),
        SizedBox(height: 2),
        Row(
          children: [
            Spacer(),
            Text(lvlText, style: Theme.of(context).textTheme.caption.copyWith(fontSize: 12)),
          ],
        ),
        SizedBox(height: 2),
        Text(_model.desc(), style: secondary(context)),
        SizedBox(height: 4),
        SkillTagsRow(tags: _model.tags),
      ],
    );
  }
}

/// Leader skill info.
class MonsterLeaderSkillSection extends StatelessWidget {
  final FullLeaderSkill _model;

  MonsterLeaderSkillSection(LeaderSkill skill, {Key key})
      : _model = FullLeaderSkill(skill),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          child: Row(
            children: [
              Text(loc.monsterInfoLeaderSkillTitle, style: subtitle(context)),
              SizedBox(width: 8),
              Text(_model.name()),
            ],
          ),
        ),
        SizedBox(height: 8),
        Text(_model.desc(), style: secondary(context)),
        SizedBox(height: 4),
        SkillTagsRow(tags: _model.tags),
      ],
    );
  }
}

class SkillTagsRow extends StatelessWidget {
  final List<dynamic> tags;

  const SkillTagsRow({Key key, this.tags}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: EdgeInsets.all(4),
      crossAxisCount: 2,
      childAspectRatio: 8 / 1,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        for (var tag in tags)
          TagButton(
            LanguageSelector.name(tag).call(),
            null,
          ),
      ],
    );
  }
}

class TagButton extends FlatButton {
  final String _text;
  final VoidCallback _selectedOnPressed;

  TagButton(this._text, this._selectedOnPressed);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      color: grey(context, 200),
      disabledColor: grey(context, 200),
      textColor: grey(context, 1000),
      disabledTextColor: grey(context, 1000),
      child: FittedBox(child: Text(_text)),
      onPressed: _selectedOnPressed,
    );
  }
}

/// Displays date monster was registered in DadGuide.
class MonsterHistory extends StatelessWidget {
  final FullMonster _data;

  const MonsterHistory(this._data, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(loc.monsterInfoHistoryTitle, style: subtitle(context)),
        Text(loc.monsterInfoHistoryAdded(_data.monster.regDate), style: secondary(context)),
      ],
    );
  }
}

/// Widget which, when clicked, launches an error reporting email.
class MailIssues extends StatelessWidget {
  final FullMonster _data;

  const MailIssues(this._data, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);

    return GestureDetector(
      onTap: () => sendMonsterErrorEmail(_data.monster),
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

/// Widget which, when clicked, launches youtube with the JP name prepopulated.
class MonsterVideos extends StatelessWidget {
  final FullMonster _data;

  const MonsterVideos(this._data, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);

    return GestureDetector(
      // Japanese name usually provides more results than the english
      onTap: () => {launchYouTubeSearch(_data.monster.nameJp)},
      child: Card(
          color: grey(context, 300),
          child: Row(
            children: [
              Icon(Icons.play_arrow),
              Expanded(
                  child: Text(loc.exampleYtVideos,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
            ],
          )),
    );
  }
}

/// Displays icons of monsters with the same active skill.
class MonsterSkillups extends StatelessWidget {
  final List<int> _monsterIds;

  const MonsterSkillups(this._monsterIds, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(loc.monsterInfoSkillupTitle),
        Wrap(children: [
          for (var id in _monsterIds)
            Padding(padding: EdgeInsets.all(2), child: PadIcon(id, monsterLink: true))
        ]),
      ],
    );
  }
}

/// Displays dungeons that the monster drops in.
class MonsterDropLocations extends StatelessWidget {
  final Map<int, List<BasicDungeon>> _dropLocations;
  final String _title;
  const MonsterDropLocations(this._dropLocations, this._title, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);

    if (_dropLocations.isEmpty) {
      return Text(
          _title == loc.monsterInfoSkillupDungeonsTitle
              ? loc.monsterInfoSkillupDungeonTitleNone
              : loc.monsterInfoDropsTitleNone,
          style: subtitle(context));
    }

    var keys = _dropLocations.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_title),
        for (var k in keys)
          Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  PadIcon(k),
                  Flexible(child: DropDungeonList(dungeons: _dropLocations[k])),
                ],
              ))
      ],
    );
  }
}

class DropDungeonList extends StatelessWidget {
  final List<BasicDungeon> dungeons;

  const DropDungeonList({Key key, this.dungeons}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: EdgeInsets.all(8),
      crossAxisCount: 2,
      childAspectRatio: 7 / 1,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [for (var tag in dungeons) DungeonButton(tag)],
    );
  }
}

class DungeonButton extends FlatButton {
  final BasicDungeon dungeon;

  DungeonButton(this.dungeon);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      color: grey(context, 200),
      textColor: grey(context, 1000),
      child: FittedBox(child: Text(LanguageSelector.name(dungeon)())),
      onPressed: goToDungeonFn(context, dungeon.dungeonId, null),
    );
  }
}

/// Locations where the skillup monsters drop.
class MonsterSkillupDropLocations extends StatelessWidget {
  final FullMonster _fullMonster;
  const MonsterSkillupDropLocations(this._fullMonster, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);
    // Remove duplicate information already displayed in the monster drop section
    _fullMonster.skillUpDungeons.removeWhere(
        (key, dungeon) => _fullMonster.dropLocations.keys.contains(key) || dungeon.isEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MonsterDropLocations(_fullMonster.skillUpDungeons, loc.monsterInfoSkillupDungeonsTitle)
      ],
    );
  }
}

/// Table with gold/mp/feed info at max level.
class MonsterBuySellFeedSection extends StatelessWidget {
  final Monster _monster;
  const MonsterBuySellFeedSection(this._monster, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);

    return DefaultTextStyle(
      style: Theme.of(context).textTheme.bodyText1,
      child: Table(
        border: TableBorder.all(width: 1.0, color: grey(context, 800)),
        children: [
          TableRow(children: [
            cell(''),
            cell(loc.monsterInfoTableInfoMaxLevel),
          ]),
          TableRow(children: [
            cell(loc.monsterInfoTableSellGold),
            numCell(_monster.sellGold),
          ]),
          TableRow(children: [
            cell(loc.monsterInfoTableSellMp),
            numCell(_monster.sellMp),
          ]),
          if (_monster.buyMp != null)
            TableRow(children: [
              cell(loc.monsterInfoTableBuyMp),
              numCell(_monster.buyMp),
            ]),
          TableRow(children: [
            cell(loc.monsterInfoTableFeedXp),
            numCell(_monster.fodderExp),
          ]),
          TableRow(children: [
            cell(loc.monsterInfoTableFeedXpOnColor),
            numCell(_monster.fodderExp * 1.5),
          ]),
        ],
      ),
    );
  }
}

/// Series name and icons for other monsters in the series.
class MonsterSeries extends StatelessWidget {
  final FullMonster _fullMonster;

  const MonsterSeries(this._fullMonster, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(loc.monsterInfoSeriesHeader(_fullMonster.fullSeries.name()), style: subtitle(context)),
        Wrap(
          runSpacing: 4,
          spacing: 4,
          children: [
            for (var id in _fullMonster.fullSeries.members) PadIcon(id, monsterLink: true),
          ],
        ),
      ],
    );
  }
}

/// Series name and icons for other monsters in the series.
class MonsterMaterialFor extends StatelessWidget {
  final FullMonster _fullMonster;

  const MonsterMaterialFor(this._fullMonster, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(loc.monsterInfoMaterialForHeader, style: subtitle(context)),
        Wrap(
          runSpacing: 4,
          spacing: 4,
          children: [
            for (var id in _fullMonster.materialForMonsters) PadIcon(id, monsterLink: true),
          ],
        ),
      ],
    );
  }
}

/// A chunk of awoken skills; displayed possibly twice (regular and super awokens).
class AwokenSkillSection extends StatelessWidget {
  final List<FullAwakening> _awakenings;

  const AwokenSkillSection(this._awakenings, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);

    // Create map to merge multiple instances of same awakening
    var map = <int, Tuple2<FullAwakening, int>>{};
    for (var a in _awakenings) {
      var value = map[a.awokenSkillId]?.item2 ?? 0;
      map[a.awokenSkillId] = Tuple2(a, value + 1);
    }

    var title = _awakenings[0].awakening.isSuper
        ? loc.monsterInfoSuperAwokenSkillSection
        : loc.monsterInfoAwokenSkillSection;
    return Column(
      children: [
        Row(
          children: [
            Text(title, style: subtitle(context)),
            Spacer(),
            for (var a in _awakenings)
              Padding(
                padding: EdgeInsets.only(left: 2),
                child: awakeningContainer(a.awokenSkillId, size: 16),
              ),
          ],
        ),
        SizedBox(height: 4),
        // TODO: I think this would look nicer if the awakening aligned with the name
        for (var data in map.values)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                awakeningContainer(data.item1.awokenSkillId, size: 16),
                SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Show number of same awakenings if applicable
                      if (data.item2 > 1)
                        Text(data.item1.name() + ' x' + data.item2.toString())
                      else
                        Text(data.item1.name()),
                      Text(data.item1.desc(), style: secondary(context)),
                    ],
                  ),
                )
              ],
            ),
          ),
      ],
    );
  }
}
