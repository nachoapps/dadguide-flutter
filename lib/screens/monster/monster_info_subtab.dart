import 'dart:collection';
import 'dart:math';

import 'package:dadguide2/components/email.dart';
import 'package:dadguide2/components/enums.dart';
import 'package:dadguide2/components/icons.dart';
import 'package:dadguide2/components/images.dart';
import 'package:dadguide2/components/navigation.dart';
import 'package:dadguide2/components/service_locator.dart';
import 'package:dadguide2/components/youtube.dart';
import 'package:dadguide2/data/data_objects.dart';
import 'package:dadguide2/data/tables.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MonsterDetailScreen extends StatefulWidget {
  final MonsterDetailArgs _args;

  MonsterDetailScreen(this._args);

  @override
  _MonsterDetailScreenState createState() => _MonsterDetailScreenState(_args);
}

class _MonsterDetailScreenState extends State<MonsterDetailScreen> {
  final MonsterDetailArgs _args;
  Future<FullMonster> loadingFuture;

  _MonsterDetailScreenState(this._args);

  @override
  void initState() {
    super.initState();
    loadingFuture = getIt<MonstersDao>().fullMonster(_args.monsterId);
  }

  @override
  Widget build(BuildContext context) {
    print('adding a monsterdetail');
    return ChangeNotifierProvider(
      builder: (context) => MonsterDetailSearchState(),
      child: Column(
        children: <Widget>[
          MonsterDetailBar(),
          Expanded(child: SingleChildScrollView(child: _retrieveMonster())),
//          Disabled for now; nothing here is implemented
//          MonsterDetailOptionsBar(),
        ],
      ),
    );
  }

  FutureBuilder<FullMonster> _retrieveMonster() {
    return FutureBuilder<FullMonster>(
        future: loadingFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
            return Center(child: Icon(Icons.error));
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          return MonsterDetailContents(snapshot.data);
        });
  }
}

class MonsterDetailContents extends StatelessWidget {
  final FullMonster _data;

  const MonsterDetailContents(this._data, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var activeSkill = _data.activeSkill;
    bool hasSkillups = activeSkill != null && activeSkill.turnMin != activeSkill.turnMax;

    return Column(
      children: [
        MonsterDetailPortrait(_data),
        Divider(),
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
              Text('+297 & fully awoken'),
              MonsterWeightedStatTable(_data),

              if (_data.monster.inheritable)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 4),
                    Text('Stat bonus when assisting'),
                    MonsterAssistStatTable(_data),
                  ],
                ),

              if (_data.killers.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 4),
                    Text('Available Killer Awoken'),
                    Row(children: [
                      for (var killer in _data.killers) latentContainer(killer.id, size: 36)
                    ]),
                  ],
                ),

              if (activeSkill != null)
                Divider(),

              if (activeSkill != null)
                Padding(
                    child: MonsterActiveSkillSection(activeSkill),
                    padding: EdgeInsets.only(top: 4)),

              if (_data.leaderSkill != null)
                Divider(),

              if (_data.leaderSkill != null)
                Padding(
                    child: MonsterLeaderSkillSection(_data.leaderSkill),
                    padding: EdgeInsets.only(top: 4)),

              if (_data.leaderSkill != null)
                Padding(child: MonsterLeaderInfoTable(_data), padding: EdgeInsets.only(top: 4)),

              if (hasSkillups)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: MonsterSkillups(_data.skillUpMonsters),
                ),

              if (hasSkillups)
                Padding(child: MonsterSkillupDropLocations(), padding: EdgeInsets.only(top: 4)),

              SizedBox(height: 8),
              MonsterDropLocations(_data),

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

              if (_data.evolutions.isNotEmpty)
                Padding(child: MonsterEvolutions(_data), padding: EdgeInsets.only(top: 8)),

              if (_data.fullSeries != null)
                Padding(child: MonsterSeries(_data), padding: EdgeInsets.only(top: 4)),

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

class MonsterDetailPortrait extends StatefulWidget {
  final FullMonster _data;

  const MonsterDetailPortrait(this._data, {Key key}) : super(key: key);

  @override
  _MonsterDetailPortraitState createState() => _MonsterDetailPortraitState();
}

class _MonsterDetailPortraitState extends State<MonsterDetailPortrait> {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
        aspectRatio: 5 / 3,
        child: Stack(children: [
          Center(child: portraitImage(widget._data.monster.monsterId)),
          Positioned(
            left: 10,
            top: 10,
            child: InkWell(
              child: new Icon(Icons.autorenew),
              onTap: _refreshIcon,
            ),
          ),
          Positioned.fill(
            child: MonsterDetailPortraitAwakenings(widget._data),
          ),
          if (widget._data.prevMonsterId != null)
            Positioned(
              left: 10,
              bottom: 4,
              child: InkWell(
                child: Icon(Icons.chevron_left),
                onTap: goToMonsterFn(context, widget._data.prevMonsterId),
              ),
            ),
          if (widget._data.nextMonsterId != null)
            Positioned(
              right: 10,
              bottom: 4,
              child: InkWell(
                child: Icon(Icons.chevron_right),
                onTap: goToMonsterFn(context, widget._data.nextMonsterId),
              ),
            ),
        ]));
  }

  _refreshIcon() async {
    await clearImageCache(widget._data.monster.monsterId);
    setState(() {});
  }
}

class MonsterDetailPortraitAwakenings extends StatelessWidget {
  final FullMonster _data;

  const MonsterDetailPortraitAwakenings(this._data, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, right: 10, bottom: 30),
      child: Align(
        alignment: Alignment.topRight,
        child: LayoutBuilder(
          builder: (context, constraints) {
            var maxHeight = constraints.biggest.height / 10;
            return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                if (_data.superAwakenings.isNotEmpty)
                  Column(
                    children: [
                      for (var a in _data.superAwakenings)
                        Padding(
                            padding: EdgeInsets.only(bottom: 2),
                            child: awakeningContainer(a.awokenSkillId, size: maxHeight)),
                    ],
                  ),
                if (_data.awakenings.isNotEmpty)
                  Column(
                    children: [
                      for (var a in _data.awakenings)
                        Padding(
                            padding: EdgeInsets.only(bottom: 2),
                            child: awakeningContainer(a.awokenSkillId, size: maxHeight)),
                    ],
                  )
              ],
            );
          },
        ),
      ),
    );
  }
}

class MonsterDetailHeader extends StatelessWidget {
  final FullMonster _data;

  const MonsterDetailHeader(this._data, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var rarity = _data.monster.rarity;
    var topRightText = '★' * rarity + '($rarity) / Cost ${_data.monster.cost}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PadIcon(_data.monster.monsterId),
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
                    Text('No. ${_data.monster.monsterNoNa}'),
                    Text(topRightText),
                  ],
                ),
              ),
              FittedBox(
                alignment: Alignment.centerLeft,
                child: Text(_data.monster.nameNa, style: Theme.of(context).textTheme.title),
              ),
              FittedBox(
                alignment: Alignment.centerLeft,
                child: Text(_data.monster.nameJp, style: Theme.of(context).textTheme.body1),
              ),
              Row(children: [
                TypeIconText(_data.type1),
                TypeIconText(_data.type2),
                TypeIconText(_data.type3),
              ])
            ],
          ),
        )
      ],
    );
  }
}

class TypeIconText extends StatelessWidget {
  final MonsterType _monsterType;

  TypeIconText(this._monsterType);

  @override
  Widget build(BuildContext context) {
    if (_monsterType == null) return Container(width: 0.0, height: 0.0);

    return Row(children: [
      typeContainer(_monsterType.id, leftPadding: 4),
      Padding(
        padding: const EdgeInsets.only(left: 2),
        child: Text(_monsterType.name, style: Theme.of(context).textTheme.caption),
      )
    ]);
  }
}

class MonsterDetailBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.blue,
        padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 32,
              height: 32,
              child: InkWell(
                child: Icon(Icons.chevron_left),
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
            Spacer(),
            Container(),
//            Favorites are disabled for now
//            SizedBox(
//              width: 32,
//              height: 32,
//              child: Icon(Icons.star_border),
//            ),
          ],
        ));
  }
}

IconButton dummyIconButton(BuildContext context, IconData icon, String title) {
  return IconButton(
      icon: Icon(icon),
      onPressed: () {
        Scaffold.of(context).removeCurrentSnackBar();
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('$title not implemented yet'),
        ));
      });
}

class MonsterDetailOptionsBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          dummyIconButton(context, Icons.compare_arrows, 'Compare Monster'),
          dummyIconButton(context, Icons.live_tv, 'YT Link'),
          dummyIconButton(context, Icons.save_alt, 'Save view'),
        ],
      ),
    );
  }
}

class MonsterDetailSearchState with ChangeNotifier {}

class MonsterLevelStatTable extends StatelessWidget {
  final FullMonster _data;

  const MonsterLevelStatTable(this._data, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var m = _data.monster;
    var limitMult = (m.limitMult ?? 0) + 100;
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.caption,
      child: Table(
        columnWidths: {0: FixedColumnWidth(40)},
        border: TableBorder.all(width: 1.0, color: Colors.black26),
        children: [
          TableRow(children: [
            cell('Lv.'),
            cell('HP'),
            cell('ATK'),
            cell('RCV'),
            cell('EXP'),
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
              numCell(m.hpMax * limitMult ~/ 100),
              numCell(m.atkMax * limitMult ~/ 100),
              numCell(m.rcvMax * limitMult ~/ 100),
              numCell(m.exp + 50000000),
            ]),
        ],
      ),
    );
  }
}

class MonsterWeightedStatTable extends StatelessWidget {
  final FullMonster _data;

  const MonsterWeightedStatTable(this._data, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var m = _data.monster;
    var a = _data.awakenings;
    var limitMult = (m.limitMult ?? 0) + 100;
    var maxHp = m.hpMax + 99 * 10;
    var atkMax = m.atkMax + 99 * 5;
    var rcvMax = m.rcvMax + 99 * 3;
    
    // Account for stat boosts
    a.forEach((awakening) {
      var aS = awakening.awokenSkill;
      maxHp += aS.adjHp;
      atkMax += aS.adjAtk;
      rcvMax += aS.adjRcv;
    });

    return DefaultTextStyle(
      style: Theme.of(context).textTheme.caption,
      child: Table(
        columnWidths: {0: FixedColumnWidth(40)},
        border: TableBorder.all(width: 1.0, color: Colors.black26),
        children: [
          TableRow(children: [
            cell('Lv.'),
            cell('HP'),
            cell('ATK'),
            cell('RCV'),
            cell('Weighted'),
          ]),
          TableRow(children: [
            numCell(m.level),
            numCell(maxHp),
            numCell(atkMax),
            numCell(rcvMax),
            numCell(_weighted(maxHp, atkMax, rcvMax)),
          ]),
          if (limitMult > 1)
            TableRow(children: [
              numCell(110),
              numCell(maxHp * limitMult ~/ 100),
              numCell(atkMax * limitMult ~/ 100),
              numCell(rcvMax * limitMult ~/ 100),
              numCell(_weighted(maxHp, atkMax, rcvMax, limitMult: limitMult)),
            ]),
        ],
      ),
    );
  }
}

class MonsterAssistStatTable extends StatelessWidget {
  final FullMonster _data;

  const MonsterAssistStatTable(this._data, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var m = _data.monster;
    var a = _data.awakenings;
    var hpMax = m.hpMax * .1;
    var atkMax = m.atkMax * .05;
    var rcvMax = m.rcvMax * .15;
    var hp297Max = hpMax + 99 * 10 * .1;
    var atk297Max = atkMax + 99 * 5 * .05;
    var rcv297Max = rcvMax + 99 * 3 * .15;
    var isEquip = false;
    
    // Only add stat changes if assist type
    if (a.any((awakening) => awakening.awokenSkill.awokenSkillId == 49)) {
      isEquip = true;
    }

    if (isEquip) {
      a.forEach((awakening) {
        var aS = awakening.awokenSkill;
        hpMax += aS.adjHp;
        hp297Max += aS.adjHp;
        atkMax += aS.adjAtk;
        atk297Max += aS.adjAtk;
        rcvMax += aS.adjRcv;
        rcv297Max += aS.adjRcv;
      });
    }
    
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.caption,
      child: Table(
        columnWidths: {0: FixedColumnWidth(40)},
        border: TableBorder.all(width: 1.0, color: Colors.black26),
        children: [
          TableRow(children: [
            cell('Lv.'),
            cell('HP'),
            cell('ATK'),
            cell('RCV'),
            cell('Weighted'),
          ]),
          TableRow(children: [
            cell('99'),
            numCell(hpMax),
            numCell(atkMax),
            numCell(rcvMax),
            numCell(_weighted(hpMax, atkMax, rcvMax)),
          ]),
          TableRow(children: [
            cell('99\n+297'),
            numCell(hp297Max),
            numCell(atk297Max),
            numCell(rcv297Max),
            numCell(_weighted(hp297Max, atk297Max, rcv297Max)),
          ]),
        ],
      ),
    );
  }
}

TableCell cell(String text) {
  return widgetCell(Text(text, textAlign: TextAlign.center));
}

TableCell emptyCell() {
  return TableCell(child: Container());
}

TableCell numCell(num value) {
  return cell(NumberFormat.decimalPattern().format(value.toInt()));
}

TableCell widgetCell(Widget widget) {
  return TableCell(
    child: Padding(
      padding: EdgeInsets.all(4),
      child: widget,
    ),
    verticalAlignment: TableCellVerticalAlignment.middle,
  );
}

//Widget cell(String text) =>
//    TableCell(child: Text(text), verticalAlignment: TableCellVerticalAlignment.fill);
////  Widget cell(String text) => TableCell(child: Text(text, textAlign: TextAlign.end));
//Widget intCell(int value) => cell(value?.toString() ?? '');

int _weighted(num hp, num atk, num rcv, {limitMult: 100}) =>
    (hp / 10 + atk / 5 + rcv / 3) * limitMult ~/ 100;

class MonsterActiveSkillSection extends StatelessWidget {
  final ActiveSkill _skill;

  const MonsterActiveSkillSection(this._skill, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var skillLevels = _skill.turnMax - _skill.turnMin;
    var lvlText = skillLevels == 0
        ? 'Lv.MAX Turn : ${_skill.turnMax}'
        : 'Lv.1 Turn : ${_skill.turnMax} (Lv.$skillLevels Turn: ${_skill.turnMin})';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          child: Row(
            children: [
              Text('Skill:'),
              SizedBox(width: 8),
              Text(_skill.nameNa, style: TextStyle(color: Colors.blue)),
            ],
          ),
        ),
        SizedBox(height: 2),
        Row(
          children: [
            Spacer(),
            Text(lvlText, style: Theme.of(context).textTheme.caption),
          ],
        ),
        SizedBox(height: 2),
        Text(_skill.descNa, style: Theme.of(context).textTheme.body2),
      ],
    );
  }
}

class MonsterLeaderSkillSection extends StatelessWidget {
  final LeaderSkill _skill;

  const MonsterLeaderSkillSection(this._skill, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          child: Row(
            children: [
              Text('Leader skill:'),
              SizedBox(width: 8),
              Text(_skill.nameNa, style: TextStyle(color: Colors.green)),
            ],
          ),
        ),
        SizedBox(height: 8),
        Text(_skill.descNa, style: Theme.of(context).textTheme.body2),
      ],
    );
  }
}

class MonsterHistory extends StatelessWidget {
  final FullMonster _data;

  const MonsterHistory(this._data, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('History'),
        Text('[${_data.monster.regDate}] Added', style: Theme.of(context).textTheme.body2),
      ],
    );
  }
}

class MailIssues extends StatelessWidget {
  final FullMonster _data;

  const MailIssues(this._data, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => sendMonsterErrorEmail(_data.monster),
      child: Card(
          color: Colors.grey[300],
          child: Row(
            children: [
              Icon(Icons.mail_outline),
              Text('Report incorrect information',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          )),
    );
  }
}

class MonsterVideos extends StatelessWidget {
  final FullMonster _data;

  const MonsterVideos(this._data, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Japanese name usually provides more results than the english
      onTap: () => {launchYouTubeSearch(_data.monster.nameJp)},
      child: Card(
          color: Colors.grey[300],
          child: Row(
            children: [
              Icon(Icons.play_arrow),
              Expanded(
                  child: Text("Example team compositions and dungeon clears",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
            ],
          )),
    );
  }
}

class MonsterLeaderInfoTable extends StatelessWidget {
  final FullMonster _data;

  const MonsterLeaderInfoTable(this._data, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var m = _data.monster;
    var ls = _data.leaderSkill;
    // truncates to 1 or 2 decimal places depending on significant decimals
    var _truncateNumber = (double n) =>
        n.toStringAsFixed((n * 10).truncateToDouble() == n * 10 ? 1 : 2);

    return DefaultTextStyle(
      style: Theme.of(context).textTheme.caption,
      child: Table(
        border: TableBorder.all(width: 1.0, color: Colors.black26),
        children: [
          TableRow(children: [
            Container(),
            widgetCell(PadIcon(
              m.monsterId,
              size: 24,
            )),
            widgetCell(Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PadIcon(m.monsterId, size: 24),
                SizedBox(width: 4),
                PadIcon(m.monsterId, size: 24),
              ],
            )),
          ]),
          TableRow(children: [
            cell('HP'),
            cell(ls.maxHp == 1 ? '-' : 'x ${ls.maxHp}'),
            cell(ls.maxHp == 1 ? '-' : 'x ${_truncateNumber(ls.maxHp * ls.maxHp)}'),
          ]),
          TableRow(children: [
            cell('ATK'),
            cell(ls.maxAtk == 1 ? '-' : 'x ${ls.maxAtk}'),
            cell(ls.maxAtk == 1 ? '-' : 'x ${_truncateNumber(ls.maxAtk * ls.maxAtk)}'),
          ]),
          TableRow(children: [
            cell('RCV'),
            cell(ls.maxRcv == 1 ? '-' : 'x ${ls.maxRcv}'),
            cell(ls.maxRcv == 1 ? '-' : 'x ${_truncateNumber(ls.maxRcv * ls.maxRcv)}'),
          ]),
          TableRow(children: [
            cell('Reduce Dmg.'),
            cell(ls.maxShield == 0 ? '-' : '${ls.maxShield * 100} %'),
            cell(ls.maxShield == 0 ? '-' : '${_truncateNumber(100 * (1 - pow(1 - ls.maxShield, 2)))} %'),
          ]),
        ],
      ),
    );
  }
}

class MonsterSkillups extends StatelessWidget {
  final List<int> _monsterIds;

  const MonsterSkillups(this._monsterIds, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Skill Up - Monster'),
        Wrap(children: [
          for (var id in _monsterIds)
            Padding(padding: EdgeInsets.all(2), child: PadIcon(id, monsterLink: true))
        ]),
      ],
    );
  }
}

class MonsterDropLocations extends StatelessWidget {
  final FullMonster _data;
  const MonsterDropLocations(this._data, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (_data.dropLocations.isEmpty) {
      return Text('Drop Dungeons: None');
    }

    var keys = _data.dropLocations.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Drop Dungeons'),
        for (var k in keys)
          Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: <Widget>[
                  PadIcon(k),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      for (var dungeon in _data.dropLocations[k])
                        FlatButton(
                          onPressed: () => print('pressed'),
                          color: Colors.orange,
                          child: Text(dungeon.nameNa),
                        )
                    ],
                  )
                ],
              ))
      ],
    );
  }
}

class MonsterSkillupDropLocations extends StatelessWidget {
  const MonsterSkillupDropLocations({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Skill Up - Dungeon'),
        // TODO: if monster appears in a skill-up dungeon should not that too
        Text('Not implemented yet =(', style: Theme.of(context).textTheme.body2),
      ],
    );
  }
}

class MonsterBuySellFeedSection extends StatelessWidget {
  final Monster _monster;

  const MonsterBuySellFeedSection(this._monster, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.body2,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Table(
              border: TableBorder.all(width: 1.0, color: Colors.black26),
              children: [
                TableRow(children: [
                  cell(''),
                  cell('At max level'),
                ]),
                TableRow(children: [
                  cell('Sell Gold'),
                  numCell(_monster.sellGold),
                ]),
                TableRow(children: [
                  cell('Sell MP'),
                  numCell(_monster.sellMp),
                ]),
                if (_monster.buyMp != null)
                  TableRow(children: [
                    cell('Buy MP'),
                    numCell(_monster.buyMp),
                  ]),
                TableRow(children: [
                  cell('Feed XP'),
                  numCell(_monster.fodderExp),
                ]),
                TableRow(children: [
                  cell('Feed XP\n(on color)'),
                  numCell(_monster.fodderExp * 1.5),
                ]),
              ],
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }
}

class MonsterSeries extends StatelessWidget {
  final FullMonster _fullMonster;

  const MonsterSeries(this._fullMonster, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Series - ${_fullMonster.fullSeries.series.nameNa}'),
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

class MonsterEvolutions extends StatelessWidget {
  final FullMonster _fullMonster;

  const MonsterEvolutions(this._fullMonster, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var evos = _fullMonster.evolutions;
    List<FullEvolution> baseEvos = evos.where((e) => e.type == EvolutionType.evo).toList();
    List<FullEvolution> reversableEvos =
        evos.where((e) => e.type == EvolutionType.reversible).toList();
    List<FullEvolution> nonReversableEvos =
        evos.where((e) => e.type == EvolutionType.non_reversible).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (baseEvos.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: MonsterEvoSection('Evolution', baseEvos),
          ),
        if (reversableEvos.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: MonsterEvoSection('Reversable Evolutions', reversableEvos),
          ),
        if (nonReversableEvos.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: MonsterEvoSection('Non-Reversable Evolutions', nonReversableEvos),
          ),
      ],
    );
  }
}

class MonsterEvoSection extends StatelessWidget {
  final String name;
  final List<FullEvolution> evos;

  MonsterEvoSection(this.name, this.evos);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(name),
        for (var evo in evos)
          Padding(
            child: MonsterEvoRow(evo),
            padding: EdgeInsets.symmetric(vertical: 4),
          ),
      ],
    );
  }
}

class MonsterEvoRow extends StatelessWidget {
  final FullEvolution _evo;

  const MonsterEvoRow(this._evo, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var hpDiff = _evo.toMonster.hpMax - _evo.fromMonster.hpMax;
    var atkDiff = _evo.toMonster.atkMax - _evo.fromMonster.atkMax;
    var rcvDiff = _evo.toMonster.rcvMax - _evo.fromMonster.rcvMax;
    var deltas = [];

    if (hpDiff > 0)
      deltas.add('HP +$hpDiff');
    else if (hpDiff < 0) deltas.add('HP $hpDiff');

    if (atkDiff > 0)
      deltas.add('ATK +$atkDiff');
    else if (atkDiff < 0) deltas.add('ATK $atkDiff');

    if (rcvDiff > 0)
      deltas.add('RCV +$rcvDiff');
    else if (rcvDiff < 0) deltas.add('RCV $rcvDiff');

    var statText = deltas.join(' / ');

    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.bottom,
      columnWidths: {
        0: IntrinsicColumnWidth(),
        2: IntrinsicColumnWidth(),
        4: IntrinsicColumnWidth(),
      },
      children: [
        TableRow(
          children: [
            PadIcon(_evo.fromMonster.monsterId, monsterLink: true),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Icon(Icons.add),
            ),
            Row(children: [
              for (var matId in _evo.evoMatIds)
                Padding(
                  child: PadIcon(matId, size: 38, monsterLink: true),
                  padding: EdgeInsets.symmetric(horizontal: 2),
                ),
            ]),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Icon(Icons.chevron_right),
            ),
            PadIcon(_evo.toMonster.monsterId, monsterLink: true),
          ],
        ),
        TableRow(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                typeContainer(_evo.fromMonster.type1Id),
                typeContainer(_evo.fromMonster.type2Id),
                typeContainer(_evo.fromMonster.type3Id),
              ],
            ),
            Container(),
            Center(child: Text(statText, style: Theme.of(context).textTheme.caption)),
            Container(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                typeContainer(_evo.toMonster.type1Id),
                typeContainer(_evo.toMonster.type2Id),
                typeContainer(_evo.toMonster.type3Id),
              ],
            ),
          ],
        )
      ],
    );
  }
}

class AwokenSkillSection extends StatelessWidget {
  final List<FullAwakening> _awakenings;

  const AwokenSkillSection(this._awakenings, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create map to merge multiple instances of same awakening
    var map = LinkedHashMap();
    _awakenings.map((a) => a.awokenSkill).forEach((as) => map[as] = (map[as] ?? 0) + 1);
	
    var title = _awakenings[0].awakening.isSuper ? 'Super Awoken Skills' : 'Awoken Skills';
    return Column(
      children: [
        Row(
          children: [
            Text(title),
            Spacer(),
            for (var a in _awakenings) awakeningContainer(a.awokenSkillId, size: 16),
          ],
        ),
        for (var a in map.keys)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              awakeningContainer(a.awokenSkillId, size: 16),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Show number of same awakenings if applicable
                    if (map[a] > 1)
                      Text(a.nameNa + " x" + map[a].toString())
                    else
                      Text(a.nameNa),
                    Text(a.descNa),
                  ],
                ),
              )
            ],
          ),
      ],
    );
  }
}
