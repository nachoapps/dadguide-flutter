import 'package:dadguide2/components/settings_manager.dart';
import 'package:flutter/material.dart';

ThemeData themeFromPrefs() {
  return !Prefs.uiDarkMode ? appTheme() : darkAppTheme();
}

ThemeData appTheme() {
  return ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    textTheme: TextTheme(caption: TextStyle(fontSize: 10)),
    typography: Typography(
      platform: TargetPlatform.android,
      englishLike: Typography.englishLike2018,
      dense: Typography.dense2018,
      tall: Typography.tall2018,
    ),
  );
}

ThemeData darkAppTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.blue,
    textTheme: TextTheme(caption: TextStyle(fontSize: 10)),
    typography: Typography(
      platform: TargetPlatform.android,
      englishLike: Typography.englishLike2018,
      dense: Typography.dense2018,
      tall: Typography.tall2018,
    ),
  );
}
