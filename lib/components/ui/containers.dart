import 'package:dadguide2/theme/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

/// A widget that ensures it is always visible when focused.
class EnsureVisibleWhenFocused extends StatefulWidget {
  const EnsureVisibleWhenFocused({
    Key key,
    @required this.child,
    @required this.focusNode,
    this.curve: Curves.ease,
    this.duration: const Duration(milliseconds: 100),
  }) : super(key: key);

  /// The node we will monitor to determine if the child is focused
  final FocusNode focusNode;

  /// The child widget that we are wrapping
  final Widget child;

  /// The curve we will use to scroll ourselves into view.
  ///
  /// Defaults to Curves.ease.
  final Curve curve;

  /// The duration we will use to scroll ourselves into view
  ///
  /// Defaults to 100 milliseconds.
  final Duration duration;

  EnsureVisibleWhenFocusedState createState() => new EnsureVisibleWhenFocusedState();
}

/// Ensures a widget is in view when the supplied focus node is activated.
/// This is a workaround for what appears to be a framework bug.
/// https://github.com/flutter/flutter/issues/10826
/// Primarily this is used in dialogs with editable text fields.
class EnsureVisibleWhenFocusedState extends State<EnsureVisibleWhenFocused> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_ensureVisible);
  }

  @override
  void dispose() {
    super.dispose();
    widget.focusNode.removeListener(_ensureVisible);
  }

  Future<Null> _ensureVisible() async {
    // Wait for the keyboard to come into view
    // TODO: position doesn't seem to notify listeners when metrics change,
    // perhaps a NotificationListener around the scrollable could avoid
    // the need insert a delay here.
    await new Future.delayed(const Duration(milliseconds: 300));

    if (!widget.focusNode.hasFocus) return;

    final RenderObject object = context.findRenderObject();
    final RenderAbstractViewport viewport = RenderAbstractViewport.of(object);
    assert(viewport != null);

    ScrollableState scrollableState = Scrollable.of(context);
    assert(scrollableState != null);

    ScrollPosition position = scrollableState.position;
    double alignment;
    if (position.pixels > viewport.getOffsetToReveal(object, 0.0).offset) {
      // Move down to the top of the viewport
      alignment = 0.0;
    } else if (position.pixels < viewport.getOffsetToReveal(object, 1.0).offset) {
      // Move up to the bottom of the viewport
      alignment = 1.0;
    } else {
      // No scrolling is necessary to reveal the child
      return;
    }
    position.ensureVisible(
      object,
      alignment: alignment,
      duration: widget.duration,
      curve: widget.curve,
    );
  }

  Widget build(BuildContext context) => widget.child;
}
