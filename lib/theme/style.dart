import 'package:dadguide2/components/settings_manager.dart';
import 'package:flutter/material.dart';

Color grey(BuildContext context, int value) {
  var isLight = !Prefs.uiDarkMode;
  if (value >= 1000) return isLight ? Colors.black : Colors.white;
  if (value <= 0) return isLight ? Colors.white : Colors.black;
  return isLight ? Colors.grey[value] : Colors.grey[1000 - value];
}

/// Slightly more compact than body1 with a bolder weight for headers.
TextStyle subtitle(BuildContext context) {
  return Theme.of(context).textTheme.subhead.copyWith(fontWeight: FontWeight.w500);
}

/// A slightly smaller, greyer text for supporting info
TextStyle secondary(BuildContext context) {
  return Theme.of(context).textTheme.body2.copyWith(color: grey(context, 600));
}
