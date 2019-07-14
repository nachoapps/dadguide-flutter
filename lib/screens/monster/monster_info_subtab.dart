import 'package:async/async.dart';
import 'package:dadguide2/components/enums.dart';
import 'package:dadguide2/components/images.dart';
import 'package:dadguide2/components/navigation.dart';
import 'package:dadguide2/data/database.dart';
import 'package:dadguide2/data/tables.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MonsterDetailScreen extends StatefulWidget {
  final MonsterDetailArgs _args;

  MonsterDetailScreen(this._args);

  @override
  _MonsterDetailScreenState createState() => _MonsterDetailScreenState(_args);
}

class _MonsterDetailScreenState extends State<MonsterDetailScreen> {
  final MonsterDetailArgs _args;
  final _memoizer = AsyncMemoizer<FullMonster>();

  _MonsterDetailScreenState(this._args);

  @override
  Widget build(BuildContext context) {
    print('adding a monsterdetail');
    return ChangeNotifierProvider(
      builder: (context) => MonsterDetailSearchState(),
      child: Column(
        children: <Widget>[
          MonsterDetailBar(),
          Expanded(child: SingleChildScrollView(child: _retrieveMonster())),
          MonsterDetailOptionsBar(),
        ],
      ),
    );
  }

  FutureBuilder<FullMonster> _retrieveMonster() {
    var dataFuture = _memoizer.runOnce(() async {
      var database = await DatabaseHelper.instance.database;
      return database.fullMonster(_args.monsterId);
    }).catchError((ex) {
      print(ex);
    });

    return FutureBuilder<FullMonster>(
        future: dataFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            print('no data!');
            return Center(child: CircularProgressIndicator());
          }
          print('got monster data!');

          return MonsterDetailContents(snapshot.data);
        });
  }
}

class MonsterDetailContents extends StatelessWidget {
  final FullMonster _data;

  const MonsterDetailContents(this._data, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MonsterDetailPortrait(_data),
        Divider(),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MonsterDetailHeader(_data),

              SizedBox(height: 4),
              MonsterLevelStatTable(_data),

              SizedBox(height: 4),
              Text('+297 & fully awoken'),
              MonsterWeightedStatTable(_data),

              SizedBox(height: 4),
              Text('Stat bonus when assisting'),
              MonsterAssistStatTable(_data),

              SizedBox(height: 4),
              Text('Available Killer Awoken'),
              // TODO: make this a widget; merge type2/type3 killers
              Row(children: [
                for (var killer in monsterTypeFor(_data.monster.type1Id).killers)
                  latentContainer(killer.id, size: 36)
              ]),

              if (_data.activeSkill != null)
                Divider(),

              if (_data.activeSkill != null)
                Padding(
                    child: MonsterActiveSkillSection(_data.activeSkill),
                    padding: EdgeInsets.only(top: 4)),

              if (_data.leaderSkill != null)
                Divider(),

              if (_data.leaderSkill != null)
                Padding(
                    child: MonsterLeaderSkillSection(_data.leaderSkill),
                    padding: EdgeInsets.only(top: 4)),

              SizedBox(height: 8),
              MonsterHistory(_data),

              SizedBox(height: 8),
              MailIssues(_data),
            ],
          ),
        ),
      ],
    );
  }
}

class MonsterDetailPortrait extends StatelessWidget {
  final FullMonster _data;

  const MonsterDetailPortrait(this._data, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
        aspectRatio: 5 / 3,
        child: Stack(children: [
          Center(child: portraitImage(_data.monster.monsterId)),
          Positioned(
            left: 10,
            top: 10,
            child: new Icon(Icons.autorenew),
          ),
          Positioned.fill(
            child: MonsterDetailPortraitAwakenings(_data),
          ),
          if (_data.prevMonsterId != null)
            Positioned(
              left: 10,
              bottom: 4,
              child: InkWell(
                child: Icon(Icons.chevron_left),
                onTap: goToMonsterFn(context, _data.prevMonsterId),
              ),
            ),
          if (_data.nextMonsterId != null)
            Positioned(
              right: 10,
              bottom: 4,
              child: InkWell(
                child: Icon(Icons.chevron_right),
                onTap: goToMonsterFn(context, _data.nextMonsterId),
              ),
            ),
        ]));
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
        PadIcon(_data.monster.monsterId),
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
          InkWell(
            child: Icon(Icons.chevron_left),
            onTap: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: TextField(
              decoration: InputDecoration(prefixIcon: Icon(Icons.search)),
            ),
          ),
          Icon(Icons.star_border),
        ],
      ),
    );
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
          TableRow(children: [
            numCell(m.level),
            numCell(m.hpMax),
            numCell(m.atkMax),
            numCell(m.rcvMax),
            numCell(m.exp),
          ]),
          if (limitMult > 1)
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
    var limitMult = m.limitMult ?? 0;
    var maxHp = m.hpMax + 99 * 10;
    var atkMax = m.atkMax + 99 * 5;
    var rcvMax = m.rcvMax + 99 * 3;
    // TODO: account for stat boosts
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
    // TODO: account for stat boosts
    var hpMax = m.hpMax * .1;
    var atkMax = m.atkMax * .05;
    var rcvMax = m.rcvMax * .15;
    var hp297Max = hpMax + 99 * 10 * .1;
    var atk297Max = atkMax + 99 * 5 * .05;
    var rcv297Max = rcvMax + 99 * 3 * .15;
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
  return TableCell(
    child: Padding(
      padding: EdgeInsets.all(4),
      child: Text(text, textAlign: TextAlign.center),
    ),
    verticalAlignment: TableCellVerticalAlignment.middle,
  );
}

TableCell numCell(num value) {
  return cell(value.toInt().toString());
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
    return Column(children: [
      Row(
        children: [
          Text('Skill:'),
          SizedBox(width: 8),
          Text(_skill.nameNa, style: TextStyle(color: Colors.blue)),
        ],
      ),
      SizedBox(height: 2),
      Row(
        children: [
          Spacer(),
          Text(lvlText, style: Theme.of(context).textTheme.caption),
        ],
      ),
      SizedBox(height: 2),
      Text(_skill.descNa),
    ]);
  }
}

class MonsterLeaderSkillSection extends StatelessWidget {
  final LeaderSkill _skill;

  const MonsterLeaderSkillSection(this._skill, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        children: [
          Text('Leader skill:'),
          SizedBox(width: 8),
          Text(_skill.nameNa, style: TextStyle(color: Colors.green)),
        ],
      ),
      SizedBox(height: 2),
      Text(_skill.descNa),
    ]);
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
        Text('[${_data.monster.regDate}] Added'),
      ],
    );
  }
}

// TODO: add onclick with implementation
class MailIssues extends StatelessWidget {
  final FullMonster _data;

  const MailIssues(this._data, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        color: Colors.grey[300],
        child: Row(
          children: [
            Icon(Icons.mail_outline),
            Text('Report incorrect information',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ));
  }
}
