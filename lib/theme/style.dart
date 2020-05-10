import 'package:dadguide2/components/config/settings_manager.dart';
import 'package:flutter/material.dart';

Color grey(BuildContext context, int value) {
  var isLight = !Prefs.uiDarkMode;
  if (value >= 1000) return isLight ? Colors.black : Colors.white;
  if (value <= 0) return isLight ? Colors.white : Colors.black;
  return isLight ? Colors.grey[value] : Colors.grey[1000 - value];
}

/// Slightly more compact than body1 with a bolder weight for headers.
TextStyle subtitle(BuildContext context) {
  return Theme.of(context).textTheme.subtitle1.copyWith(fontWeight: FontWeight.w500);
}

/// Slightly more compact than body1 with a bolder weight for headers.
TextStyle caption(BuildContext context) {
  return Theme.of(context).textTheme.caption;
}

/// A slightly smaller, greyer text for supporting info
TextStyle secondary(BuildContext context) {
  return Theme.of(context).textTheme.bodyText1.copyWith(color: grey(context, 600));
}

/// A slightly smaller but still obvious text for ES descriptions.
TextStyle esDescription(BuildContext context) {
  return Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 14);
}
