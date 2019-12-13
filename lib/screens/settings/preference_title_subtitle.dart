import 'package:dadguide2/theme/style.dart';
import 'package:flutter/material.dart';

class PreferenceTitleSubtitle extends StatelessWidget {
  final String subtitle;
  final double leftPadding;
  final TextStyle style;

  PreferenceTitleSubtitle(this.subtitle, {this.leftPadding = 10.0, this.style});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: leftPadding),
      child: Text(
        subtitle,
        style: style ?? secondary(context),
      ),
    );
  }
}
