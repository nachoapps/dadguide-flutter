import 'package:dadguide2/components/config/settings_manager.dart';
import 'package:flutter/material.dart';

ThemeData themeFromPrefs() {
  return !Prefs.uiDarkMode ? appTheme() : darkAppTheme();
}

ThemeData appTheme() {
  return ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    textTheme: TextTheme(caption: TextStyle(fontSize: 10)),
    typography: Typography.material2018(),
  );
}

ThemeData darkAppTheme() {
  return ThemeData(
    // TODO: experiment with setting compact density. in general this looks better, except the text
    // input bars get a bit too small which could be my fault.
    //    visualDensity: VisualDensity.compact,
    visualDensity: VisualDensity(),
    brightness: Brightness.dark,
    primaryColor: Colors.blue,
    textTheme: TextTheme(caption: TextStyle(fontSize: 10)),
    typography: Typography.material2018(),
  );
}
