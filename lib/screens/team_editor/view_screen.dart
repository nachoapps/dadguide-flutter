import 'package:dadguide2/components/ui/buttons.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:dadguide2/screens/team_editor/team_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

import 'nav.dart';
import 'src/common.dart';
import 'src/display.dart';

class TeamViewScreen extends StatelessWidget {
  final TeamViewArgs args;
  final screenshotController = ScreenshotController();

  TeamViewScreen(this.args, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.teamViewerTitle),
        actions: <Widget>[
          ScreenshotButton(controller: screenshotController),
        ],
      ),
      body: SingleChildScrollView(
        child: Screenshot(
          controller: screenshotController,
          child: TeamViewContents(args.team),
        ),
      ),
    );
  }
}

class TeamViewContents extends StatelessWidget {
  final Team team;
  const TeamViewContents(this.team, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TeamController(editable: false),
      child: TeamDisplayTile(team),
    );
  }
}
