import 'package:dadguide2/components/config/service_locator.dart';
import 'package:dadguide2/data/local_tables.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:dadguide2/screens/team_editor/team_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'nav.dart';
import 'src/common.dart';
import 'src/display.dart';

class TeamEditScreen extends StatelessWidget {
  final TeamEditArgs args;

  const TeamEditScreen(this.args, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.teamEditorTitle),
      ),
      body: SingleChildScrollView(child: TeamEditorContents(args.team)),
      resizeToAvoidBottomInset: false, // Prevent the keyboard from adjusting the view
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
  final Team team;
  const TeamEditorContents(this.team, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TeamController(editable: true),
      child: TeamDisplayTile(team),
    );
  }
}
