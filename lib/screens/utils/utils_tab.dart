import 'package:flutter/material.dart';

/// Displays various hypothetical sub-utilities (none implemented yet).
/// This tab is currently hidden.
class UtilsScreen extends StatelessWidget {
  UtilsScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: TabBar(
            tabs: [
              Tab(text: "Data"),
              Tab(text: "Etc"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            DataListTab(),
            EtcTab(),
          ],
        ),
      ),
    );
  }
}

ListTile dummyTile(BuildContext context, String title) {
  return ListTile(
      title: Text('$title (WIP)'),
      onTap: () {
        Scaffold.of(context).removeCurrentSnackBar();
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('$title not implemented yet'),
        ));
      });
}

class DataListTab extends StatelessWidget {
  final _widgets = [
    'Skill Rotation',
    'MP Shop List',
    'Evolution List',
    'Skill Finder',
    'Active Skills',
    'Leader Skills',
    'Awoken Skills',
    'Series Info',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _widgets.length,
      itemBuilder: (context, index) => dummyTile(context, _widgets[index]),
    );
  }
}

class EtcTab extends StatelessWidget {
  final _widgets = [
    'Compare Monster',
    'Rank Chart',
    'Rank-Up Calculator',
    'Dungeon MP Ranking',
    'Dungeon Rankings',
    'EXP Calculator',
    'Stamina Timer',
    'Login Bonus',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _widgets.length,
      itemBuilder: (context, index) => dummyTile(context, _widgets[index]),
    );
  }
}
