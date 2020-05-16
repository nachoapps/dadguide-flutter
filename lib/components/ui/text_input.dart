import 'package:dadguide2/theme/style.dart';
import 'package:flutter/material.dart';

// TODO: convert this to use TextEditingController; it's currently impossible
// to clear the text contents via the X button.

/// Bar across the top of a couple of screens. Has a spot for a left-button, a text entry widget,
/// and a clear text widget.
class TopTextInputBar extends StatelessWidget {
  final Widget leftWidget;
  final Widget rightWidget;

  final String hintText;
  final TextEditingController controller;
  final ValueChanged onSubmitted;
  final ValueChanged onChanged;

  const TopTextInputBar(
    this.hintText,
    this.leftWidget,
    this.rightWidget, {
    this.controller,
    this.onSubmitted,
    this.onChanged,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.blue,
        padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Row(
          children: <Widget>[
            SizedBox(width: 32, height: 32, child: leftWidget),
            Expanded(
              child: SizedBox(
                height: 32,
                child: TextEditWidget(
                    hintText: hintText,
                    controller: controller,
                    onSubmitted: onSubmitted,
                    onChanged: onChanged),
              ),
            ),
            SizedBox(width: 32, height: 32, child: rightWidget),
          ],
        ));
  }
}

class TextEditWidget extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final ValueChanged onSubmitted;
  final ValueChanged onChanged;

  const TextEditWidget({Key key, this.hintText, this.controller, this.onSubmitted, this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autocorrect: false,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        hintText: hintText,
        fillColor: grey(context, 200),
        filled: true,
      ),
    );
  }
}
