import 'package:dadguide2/components/navigation.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:dadguide2/screens/dungeon_info/sub_dungeon_items.dart';
import 'package:flutter/material.dart';

/// Displays a list of the SubDungeons in the Dungeon, which the user can pick from.
class SelectSubDungeonScreen extends StatelessWidget {
  final SubDungeonSelectionArgs args;

  SelectSubDungeonScreen(this.args);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SelectSubDungeonTopBar(),
        Expanded(child: SingleChildScrollView(child: SubDungeonList(args.fullDungeon))),
        SelectSubDungeonBottomBar(),
      ],
    );
  }
}

/// Contains a back button and instructional text.
class SelectSubDungeonTopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);

    return Container(
        color: Colors.blue,
        padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Row(
          children: [
            SizedBox(
                width: 32,
                height: 32,
                child: InkWell(
                  child: Icon(Icons.chevron_left),
                  onTap: () => Navigator.of(context).pop(),
                )),
            Expanded(child: Center(child: Text(loc.subDungeonSelectionTitle))),
            SizedBox(width: 32, height: 32),
          ],
        ));
  }
}

/// Contains a close button; just an alias for the back button.
class SelectSubDungeonBottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);

    return Container(
        color: Colors.grey,
        padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Row(
          children: [
            SizedBox(
              height: 24,
              child: FlatButton(
                child: Text(loc.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ));
  }
}
