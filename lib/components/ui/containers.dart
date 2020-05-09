import 'package:dadguide2/theme/style.dart';
import 'package:flutter/material.dart';

/// Grey bar suitible for sticking at the bottom of a tab, resting above the tab navigation.
class TabOptionsBar extends StatelessWidget {
  final List<Widget> buttons;

  const TabOptionsBar(this.buttons);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: grey(context, 200),
      child: SizedBox(
        height: 36,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: buttons,
        ),
      ),
    );
  }
}

/// Helper widget for development, wraps a widget with a red outline border.
class OutlineWidget extends StatelessWidget {
  final Widget child;

  const OutlineWidget({@required this.child, Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: child,
      decoration: BoxDecoration(color: Colors.red, border: Border.all()),
    );
  }
}

/// Helper class that fixes a common problem, a Widget with Material Ink that spills out of bounds.
class FixInk extends StatelessWidget {
  final Widget child;
  const FixInk({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(color: Colors.transparent, child: child);
  }
}
