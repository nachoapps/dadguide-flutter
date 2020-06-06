import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

/// Automatically wraps a ScrollablePositionedList with go-to-top/bottom overlay buttons.
class ScrollableStackWidget extends StatelessWidget {
  final controller = ItemScrollController();
  final listener = ItemPositionsListener.create();

  final int numItems;
  final ScrollablePositionedList Function(BuildContext, ItemScrollController, ItemPositionsListener)
      builder;

  ScrollableStackWidget({Key key, @required this.numItems, @required this.builder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var iconColor = Theme.of(context).iconTheme.color.withOpacity(.5);
    return Stack(
      children: [
        builder(context, controller, listener),
        Positioned(
          top: 5,
          right: 5,
          child: GestureDetector(
            onTap: () => controller.jumpTo(index: (numItems - 1)),
            child: Icon(MaterialCommunityIcons.chevron_down_circle_outline, color: iconColor),
          ),
        ),
        Positioned(
          bottom: 5,
          right: 5,
          child: GestureDetector(
            onTap: () => controller.jumpTo(index: 0),
            child: Icon(MaterialCommunityIcons.chevron_up_circle_outline, color: iconColor),
          ),
        ),
      ],
    );
  }
}
