import 'package:dadguide2/screens/home/root_screen.dart';
import 'package:dadguide2/screens/settings/settings_manager.dart';
import 'package:dadguide2/theme/theme.dart';
import 'package:flutter/material.dart';

void main() async {
  await preferenceInit();
  runApp(DadGuideApp());
}

class DadGuideApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DadGuide',
      theme: appTheme(),
//      initialRoute: '/',
//      routes: <String, WidgetBuilder>{
//        "/": (BuildContext context) => HomeScreen(),
////        "/ExScreen2": (BuildContext context) => ExScreen2(),
//      },
//    ),
      home: StatefulHomeScreen(),
    );
  }
}
