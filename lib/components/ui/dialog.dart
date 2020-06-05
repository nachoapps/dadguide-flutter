import 'package:dadguide2/l10n/localizations.dart';
import 'package:flutter/material.dart';

/// Display a simple yes/no dialog and return true/false.
Future<bool> showConfirmDialog(BuildContext context, String title, String body,
    {String yes, String no}) async {
  yes ??= context.loc.confirm;
  no ??= context.loc.cancel;
  var result = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: <Widget>[
          FlatButton(
            child: Text(no),
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          FlatButton(
            child: Text(yes),
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      );
    },
  );

  return result ?? false;
}
