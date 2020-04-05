import 'package:dadguide2/theme/style.dart';
import 'package:flutter/material.dart';

/// A smaller-than-standard icon button. This is used in top bars mainly.
///
/// It's wrapped with a transparent Material to fix the inkwell, and the size
/// is fixed to 32.
class TrimmedMaterialIconButton extends StatelessWidget {
  // TODO: can we move the padding horizontal 16 in here?
  final IconButton child;
  const TrimmedMaterialIconButton({Key key, @required this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: SizedBox(
          height: 32,
          child: child,
        ));
  }
}

/// Divider intended to be used in top-bars
class TopBarDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 32,
        child: VerticalDivider(
          color: grey(context, 1000),
        ));
  }
}
