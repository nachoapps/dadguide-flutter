import 'package:dadguide2/components/enums.dart';
import 'package:dadguide2/components/settings_manager.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:dadguide2/screens/event/event_search_bloc.dart';
import 'package:dadguide2/screens/event/update_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fimber/flutter_fimber.dart';
import 'package:provider/provider.dart';

import 'monster_search_bloc.dart';

/// Displays a dialog that lets the user toggle their event server, or kick off the update.
Future<void> showDungeonSortDialog(BuildContext context) async {
  var loc = DadGuideLocalizations.of(context);

  var displayState = Provider.of<MonsterDisplayState>(context);
  return showDialog(
      context: context,
      builder: (innerContext) {
        return SimpleDialog(
          title: Text(loc.serverModalTitle),
          children: [
//            CountryTile(displayState, Country.jp),
//            CountryTile(displayState, Country.na),
//            CountryTile(displayState, Country.kr),
            ListTile(
              onTap: () {
                Navigator.pop(innerContext);
                showUpdateDialog(context);
              },
              leading: Icon(Icons.refresh),
              title: Text(loc.dataSync),
            ),
          ],
        );
      });
}
