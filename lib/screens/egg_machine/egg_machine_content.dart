import 'package:dadguide2/components/images/images.dart';
import 'package:dadguide2/components/models/data_objects.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A header-tabbed screen displaying events.
class EggMachineTabbedViewWidget extends StatelessWidget {
  final List<FullEggMachine> data;

  EggMachineTabbedViewWidget(this.data, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: EggMachineHeaderWidget(),
        ),
        body: Padding(
          padding: const EdgeInsets.all(4.0),
          child: EggMachineTabViewWidget(data),
        ),
      ),
    );
  }
}

/// The event tab header.
class EggMachineHeaderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: Row(
        children: [
          SizedBox(width: 48),
          Flexible(
            child: TabBar(tabs: [
              Tab(text: 'Collab'),
              Tab(text: 'Rare Egg'),
              Tab(text: 'Pal Egg'),
            ]),
          ),
        ],
      ),
    );
  }
}

/// The tab contents.
class EggMachineTabViewWidget extends StatelessWidget {
  final List<FullEggMachine> data;
  EggMachineTabViewWidget(this.data);

  @override
  Widget build(BuildContext context) {
    return TabBarView(children: [
      SingleChildScrollView(
          child: EggMachineViewWidget(data.where((fem) => fem.isCollab).toList())),
      SingleChildScrollView(child: EggMachineViewWidget(data.where((fem) => fem.isRem).toList())),
      SingleChildScrollView(child: EggMachineViewWidget(data.where((fem) => fem.isPem).toList())),
    ]);
  }
}

/// Displays a list of Events, chunked into sections by type.
class EggMachineViewWidget extends StatelessWidget {
  final List<FullEggMachine> data;

  EggMachineViewWidget(this.data);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (var em in data) EggMachineWidget(em),
      ],
    );
  }
}

class EggMachineWidget extends StatelessWidget {
  final FullEggMachine em;

  EggMachineWidget(this.em);

  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);

    var rateToSection = <double, EggMachineSection>{};
    for (var emm in em.data) {
      rateToSection.putIfAbsent(emm.rate, () => EggMachineSection(emm.rate, []));
      rateToSection[emm.rate].monsters.add(emm);
    }

    // All the sections computed, sorted by rate.
    var sortedSections = rateToSection.values.toList();
    sortedSections.sort((l, r) => ((l.totalRate - r.totalRate) * 100).floor());
    // Also sort the monster list in each.
    sortedSections
        .forEach((ems) => ems.monsters.sort((l, r) => l.monster.monsterId - r.monster.monsterId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(em.machine.name),
        Text(em.timedEvent.durationText(loc, DateTime.now())),
        Divider(),
        Flexible(
          child: ListView.separated(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (ctx, idx) => EggMachineSectionWidget(sortedSections[idx]),
              separatorBuilder: (ctx, idx) => Divider(),
              itemCount: sortedSections.length),
        ),
        Divider(),
      ],
    );
  }
}

class EggMachineSection {
  final percentFormat = NumberFormat.decimalPercentPattern(decimalDigits: 1);
  final simplePercentFormat = NumberFormat.decimalPercentPattern(decimalDigits: 0);

  final double rate;
  final List<EggMachineMonster> monsters;

  EggMachineSection(this.rate, this.monsters);

  double get totalRate => (rate * monsters.length);

  String get rateText {
    if (rate == 0) {
      return 'Unknown';
    }
    var totalRateStr = _pctFmt(totalRate);
    var text = '$totalRateStr total';
    if (monsters.length > 1) {
      var eachRateStr = _pctFmt(rate);
      text += '\n$eachRateStr each';
    }

    if (monsters.length == 1 && monsters.first.monster.orbSkinId != null) {
      text += '\nOrb Skin';
    } else {
      var rarities = monsters.map((emm) => emm.monster.rarity).toSet();
      if (rarities.length == 1) {
        text += '\n${rarities.first}★';
      }
    }
    return text;
  }

  String _pctFmt(double rate) {
    print('$rate - ${(rate * 1000).toInt() % 10}');
    if ((rate * 1000).round() % 10 == 0) {
      return simplePercentFormat.format(rate);
    } else {
      return percentFormat.format(rate);
    }
  }
}

class EggMachineSectionWidget extends StatelessWidget {
  final EggMachineSection ems;

  const EggMachineSectionWidget(this.ems);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Center(
              child: Text(
            ems.rateText,
            textAlign: TextAlign.center,
          )),
        ),
        VerticalDivider(),
        Expanded(
          child: Wrap(
            spacing: 4,
            runSpacing: 4,
            children: <Widget>[
              for (var m in ems.monsters) PadIcon(m.monster.monsterId, monsterLink: true)
            ],
          ),
        )
      ],
    );
  }
}
