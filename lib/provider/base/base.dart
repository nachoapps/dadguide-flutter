import 'package:flutter/material.dart';

class BaseProvider extends InheritedWidget {
  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static BaseProvider of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(BaseProvider) as BaseProvider);
  }

  BaseProvider({Key key, Widget child}) : super(child: child, key: key);
}
