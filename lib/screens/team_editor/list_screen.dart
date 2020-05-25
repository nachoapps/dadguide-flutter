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
    return SimpleRxStreamBuilder<List<Build>>(
      stream: getIt<BuildsDao>().buildsStream(),
      builder: (context, data) {
        print('got new data');
        return ListView.separated(
          itemBuilder: (context, idx) {
            var item = data[idx];
            return ChangeNotifierProvider(
              create: (_) => TeamController(editable: false),
              child: ListBuildTile(item),
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

class ListBuildTile extends StatelessWidget {
  final Build item;

  const ListBuildTile(this.item, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var team = item.team1;
    return ListTile(
      title: Text(item.title.isNotEmpty ? item.title : 'Untitled'),
      leading: IconButton(
        icon: Icon(Icons.edit),
        onPressed: () => Navigator.of(context)
            .pushNamed(BuildEditArgs.routeName, arguments: BuildEditArgs(EditableBuild.copy(item))),
      ),
      trailing: IconButton(
        icon: Icon(Icons.image),
        onPressed: () => Navigator.of(context)
            .pushNamed(BuildViewArgs.routeName, arguments: BuildViewArgs(EditableBuild.copy(item))),
      ),
      subtitle: FittedBox(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
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
