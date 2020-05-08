import 'package:dadguide2/components/ui/task_progress.dart';
import 'package:dadguide2/components/updates/update_service.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fimber/flutter_fimber.dart';

/// Starts the update and then displays the update dialog. Can be manually triggered by users.
Future<void> showUpdateDialog(BuildContext context) async {
  var loc = DadGuideLocalizations.of(context);

  Fimber.i('Displaying update dialog');
  return showDialog(
      context: context,
      builder: (innerContext) {
        updateManager.start().then((isFirst) {
          try {
            Navigator.pop(innerContext);
          } catch (e) {} // Suppress this failure
        }).catchError((e, st) {
          try {
            Navigator.pop(innerContext);
          } catch (e) {} // Suppress this failure
        });
        return SimpleDialog(
          title: Text(loc.updateModalTitle),
          children: [TaskListProgress(updateManager)],
        );
      });
}
