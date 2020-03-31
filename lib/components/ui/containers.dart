import 'package:dadguide2/theme/style.dart';
import 'package:flutter/material.dart';

/// Grey bar suitible for sticking at the bottom of a tab, resting above the tab navigation.
class TabOptionsBar extends StatelessWidget {
  final List<IconButton> buttons;

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
