import 'package:dadguide2/screens/team_editor/nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

/// Displays various sub-utilities.
class UtilsTab extends StatelessWidget {
  UtilsTab({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: TabBar(
            tabs: [
              Tab(text: 'Etc'),
              Tab(text: 'Data'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            EtcTab(),
            DataListTab(),
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
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        ListTile(
          title: Text('Team editor'),
          leading: Icon(FlutterIcons.team_ant),
          onTap: () async =>
              Navigator.pushNamed(context, BuildListArgs.routeName, arguments: BuildListArgs()),
        ),
        Divider(),
        ListTile(
          title: Text('Build editor'),
          leading: Icon(FlutterIcons.teamspeak_faw5d),
        ),
        Divider(),
      ],
    );
  }
}
