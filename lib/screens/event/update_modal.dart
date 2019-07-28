import 'package:dadguide2/components/task_progress.dart';
import 'package:dadguide2/services/update_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fimber/flutter_fimber.dart';

Future<void> showUpdateDialog(BuildContext context) async {
  Fimber.i('Displaying update dialog');
  return showDialog(
      context: context,
      builder: (innerContext) {
        updateManager.start().then((isFirst) {
          try {
            Navigator.pop(innerContext);
          } catch (e) {} // Suppress this failure
          if (isFirst) {
            Scaffold.of(context).showSnackBar(
                SnackBar(content: Text('Update complete'), duration: Duration(seconds: 1)));
          }
        }).catchError((e, st) {
          try {
            Navigator.pop(innerContext);
          } catch (e) {} // Suppress this failure
          Scaffold.of(context).showSnackBar(
              SnackBar(content: Text('Update failed'), duration: Duration(seconds: 2)));
        });
        return SimpleDialog(
          title: const Text('Updating DadGuide data'),
          children: [TaskListProgress(updateManager)],
        );
      });
}
