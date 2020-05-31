import 'package:dadguide2/theme/style.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';

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

/// Outline a widget with a theme-appropriate color.
class OutlineWidget extends StatelessWidget {
  final Widget child;

  const OutlineWidget({@required this.child, Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: child,
      decoration: BoxDecoration(border: Border.all(color: grey(context, 1000))),
    );
  }
}

/// Helper widget for development, wraps a widget with a red outline border.
class RedOutlineWidget extends StatelessWidget {
  final Widget child;

  const RedOutlineWidget({@required this.child, Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: child,
      decoration: BoxDecoration(border: Border.all(color: Colors.red)),
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

/// Helper class that makes the widget have the appropriate background.
/// This is useful for tabs that might otherwise animate into view see-through.
class OpaqueContainer extends StatelessWidget {
  final Widget child;

  const OpaqueContainer({Key key, @required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(color: Theme.of(context).scaffoldBackgroundColor, child: child);
  }
}

var _greyscaleFilter = ColorFilter.matrix([
  .33, .59, .11, 0, 0, // red
  .33, .59, .11, 0, 0, //green
  .33, .59, .11, 0, 0, // blue
  .33, .59, .11, 1, 0, // alpha
]);

/// Converts a widget (probably an image) to greyscale.
class Greyscale extends StatelessWidget {
  final Widget child;

  const Greyscale(this.child);
  @override
  Widget build(BuildContext context) {
    return ColorFiltered(colorFilter: _greyscaleFilter, child: child);
  }
}

/// Wraps a child widget with a Screenshot and provides a background matching the scaffold.
/// This prevents screenshots from being transparent.
class ScreenshotContainer extends StatelessWidget {
  final ScreenshotController controller;
  final Widget child;

  const ScreenshotContainer({Key key, @required this.controller, @required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Screenshot(controller: controller, child: OpaqueContainer(child: child));
  }
}
