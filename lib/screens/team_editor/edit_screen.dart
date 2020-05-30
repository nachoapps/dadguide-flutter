import 'package:dadguide2/components/config/service_locator.dart';
import 'package:dadguide2/components/ui/dialog.dart';
import 'package:dadguide2/data/local_tables.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:dadguide2/screens/team_editor/team_data.dart';
import 'package:dadguide2/theme/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';

import 'nav.dart';
import 'src/common.dart';
import 'src/display.dart';

class BuildEditScreen extends StatelessWidget {
  final BuildEditArgs args;

  const BuildEditScreen(this.args, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var build = args.build;

    return GestureDetector(
      // Forces text widgets to unselect when a user clicks outside of them.
      onTap: () => WidgetsBinding.instance.focusManager.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.loc.teamEditorTitle),
        ),
        body: SingleChildScrollView(child: BuildEditContents(build)),
        resizeToAvoidBottomInset: false, // Prevent the keyboard from adjusting the view
        floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          curve: Curves.bounceIn,
          overlayColor: Colors.black,
          overlayOpacity: 0.3,
          elevation: 8.0,
          shape: CircleBorder(),
          children: [
            SpeedDialChild(
                child: Icon(Icons.delete_forever),
                backgroundColor: Colors.red,
                label: 'Delete',
                labelStyle: TextStyle(fontSize: 18.0, color: grey(context, 0)),
                labelBackgroundColor: grey(context, 800),
                onTap: () async {
                  final result = await showConfirmDialog(context, 'Delete team',
                      'Are you sure you want to permanently delete this team?');
                  if (result) {
                    await getIt<BuildsDao>().deleteBuild(build.toBuild());
                    Navigator.of(context).pop();
                  }
                }),
            if (build.team3 == null)
              SpeedDialChild(
                child: Icon(Icons.swap_horizontal_circle),
                backgroundColor: Colors.yellow,
                label: 'Convert 3P',
                labelStyle: TextStyle(fontSize: 18.0, color: grey(context, 0)),
                labelBackgroundColor: grey(context, 800),
                onTap: () async {
                  build.team2 ??= Team();
                  build.team3 = Team();
                  await getIt<BuildsDao>().saveBuild(build.toBuild());
                  await Navigator.of(context).pushReplacementNamed(BuildEditArgs.routeName,
                      arguments: BuildEditArgs(build));
                },
              ),
            if (build.team2 == null || build.team3 != null)
              SpeedDialChild(
                child: Icon(Icons.swap_horizontal_circle),
                backgroundColor: Colors.yellow,
                label: 'Convert 2P',
                labelStyle: TextStyle(fontSize: 18.0, color: grey(context, 0)),
                labelBackgroundColor: grey(context, 800),
                onTap: () async {
                  if (build.team3 != null) {
                    final result = await showConfirmDialog(context, 'Convert to 1P',
                        'Are you sure? This will permanently delete the 3P team.');
                    if (result) {
                      build.team2 = null;
                      build.team3 = null;
                      await getIt<BuildsDao>().saveBuild(build.toBuild());
                      await Navigator.of(context).pushReplacementNamed(BuildEditArgs.routeName,
                          arguments: BuildEditArgs(build));
                    }
                  } else {
                    build.team2 = Team();
                    await getIt<BuildsDao>().saveBuild(build.toBuild());
                    await Navigator.of(context).pushReplacementNamed(BuildEditArgs.routeName,
                        arguments: BuildEditArgs(build));
                  }
                },
              ),
            if (build.team2 != null)
              SpeedDialChild(
                child: Icon(Icons.swap_horizontal_circle),
                backgroundColor: Colors.yellow,
                label: 'Convert 1P',
                labelStyle: TextStyle(fontSize: 18.0, color: grey(context, 0)),
                labelBackgroundColor: grey(context, 800),
                onTap: () async {
                  final result = await showConfirmDialog(context, 'Convert to 1P',
                      'Are you sure? This will permanently delete the 2P/3P teams.');
                  if (result) {
                    build.team2 = null;
                    build.team3 = null;
                    await getIt<BuildsDao>().saveBuild(build.toBuild());
                    await Navigator.of(context).pushReplacementNamed(BuildEditArgs.routeName,
                        arguments: BuildEditArgs(build));
                  }
                },
              ),
            SpeedDialChild(
              child: Icon(Icons.tv),
              backgroundColor: Colors.green,
              label: 'View',
              labelStyle: TextStyle(fontSize: 18.0, color: grey(context, 0)),
              labelBackgroundColor: grey(context, 800),
              onTap: () => Navigator.of(context)
                  .pushNamed(BuildViewArgs.routeName, arguments: BuildViewArgs(build)),
            ),
          ],
        ),
      ),
    );
  }
}

class BuildEditContents extends StatelessWidget {
  final EditableBuild item;
  const BuildEditContents(this.item, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TeamController(editable: true, item: item),
      child: Column(
        children: <Widget>[
          TeamDisplayTile(),
          SizedBox(height: 64),
        ],
      ),
    );
  }
}
