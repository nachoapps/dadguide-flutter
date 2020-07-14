import 'package:dadguide2/components/config/service_locator.dart';
import 'package:dadguide2/components/utils/streams.dart';
import 'package:dadguide2/data_local/local_tables.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:dadguide2/screens/team_editor/src/display.dart';
import 'package:dadguide2/screens/team_editor/team_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'nav.dart';
import 'src/common.dart';

class BuildListScreen extends StatelessWidget {
  final BuildListArgs args;

  const BuildListScreen(this.args, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.teamListTitle),
      ),
      body: Column(
        children: [
          Expanded(child: TeamListContents()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await getIt<BuildsDao>().saveBuild(Build(
            buildId: null,
            title: '',
            description: '',
            team1: Team(),
          ));
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
      ),
    );
  }
}

class TeamListContents extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var buildsDao = getIt<BuildsDao>();
    return SimpleRxStreamBuilder<List<Build>>(
      stream: buildsDao.buildsStream(),
      builder: (context, data) {
        return ListView.builder(
          itemBuilder: (context, idx) {
            var item = data[idx];
            var editableItem = EditableBuild.copy(item);
            return ChangeNotifierProvider(
              key: ValueKey(item),
              create: (_) => TeamController(item: editableItem, editable: false, hideText: true),
              child: GestureDetector(
                  onTap: () async {
                    var loadedItem = await buildsDao.inflateBuild(item);
                    var loadedEditableItem = EditableBuild.copy(loadedItem);
                    return Navigator.of(context).pushNamed(BuildEditArgs.routeName,
                        arguments: BuildEditArgs(loadedEditableItem));
                  },
                  child: Card(elevation: 2, child: TeamDisplayTile())),
            );
          },
          itemCount: data.length,
          padding: EdgeInsets.only(bottom: 72), // spacer for FAB
        );
      },
    );
  }
}
