import 'package:dadguide2/components/config/service_locator.dart';
import 'package:dadguide2/components/utils/streams.dart';
import 'package:dadguide2/data/local_tables.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:dadguide2/screens/team_editor/src/display.dart';
import 'package:dadguide2/screens/team_editor/team_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'nav.dart';
import 'src/common.dart';

class TeamListScreen extends StatelessWidget {
  final TeamListArgs args;

  const TeamListScreen(this.args, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.teamListTitle),
      ),
      body: Column(
        children: [
          Expanded(child: TeamEditorContents()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          getIt<LocalStorageDatabase>().saveTeam(TeamRow(
            teamId: null,
            jsonData: Team().toJsonString(),
          ));
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
      ),
    );
  }
}

class TeamEditorContents extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SimpleRxStreamBuilder<List<TeamRow>>(
      stream: getIt<LocalStorageDatabase>().teamsStream(),
      builder: (context, data) {
        return ListView.separated(
          itemBuilder: (context, idx) {
            var team = Team.fromJsonString(data[idx].jsonData);
            return ChangeNotifierProvider(
              create: (_) => TeamController(editable: false),
              child: TeamTile(team),
            );
          },
          separatorBuilder: (_, __) => Divider(),
          itemCount: data.length,
          padding: EdgeInsets.only(bottom: 72), // spacer for FAB
        );
      },
    );
  }
}

class TeamTile extends StatelessWidget {
  final Team team;

  const TeamTile(this.team, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(team.hasName() ? team.name : 'Untitled'),
      leading: IconButton(
        icon: Icon(Icons.edit),
        onPressed: () =>
            Navigator.of(context).pushNamed(TeamEditArgs.routeName, arguments: TeamEditArgs(team)),
      ),
      trailing: IconButton(
        icon: Icon(Icons.image),
        onPressed: () =>
            Navigator.of(context).pushNamed(TeamViewArgs.routeName, arguments: TeamViewArgs(team)),
      ),
      subtitle: FittedBox(
        child: Row(
          children: <Widget>[
            TeamSlot(team.leader),
            SizedBox(width: 4),
            TeamSlot(team.sub1),
            TeamSlot(team.sub2),
            TeamSlot(team.sub3),
            TeamSlot(team.sub4),
            SizedBox(width: 4),
            TeamSlot(team.friend),
          ],
        ),
      ),
    );
  }
}
