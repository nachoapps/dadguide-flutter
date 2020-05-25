import 'package:dadguide2/data/local_tables.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'nav.dart';
import 'src/common.dart';
import 'src/display.dart';

class BuildEditScreen extends StatelessWidget {
  final BuildEditArgs args;

  const BuildEditScreen(this.args, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.teamEditorTitle),
      ),
      body: SingleChildScrollView(child: BuildEditContents(args.build)),
      resizeToAvoidBottomInset: false, // Prevent the keyboard from adjusting the view
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
//          await getIt<BuildsDao>().saveBuild(args.build);
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
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
      child: TeamDisplayTile(item),
    );
  }
}
