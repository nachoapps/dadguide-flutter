import 'package:dadguide2/theme/style.dart';
import 'package:flutter/material.dart';

// TODO: convert this to use TextEditingController; it's currently impossible
// to clear the text contents via the X button.

/// Bar across the top of a couple of screens. Has a spot for a left-button, a text entry widget,
/// and a clear text widget.
class TopTextInputBar extends StatelessWidget {
  final String _displayText;
  final String _hintText;
  final Widget _leftWidget;
  final Widget _rightWidget;
  final void Function(String) _onSubmitted;

  const TopTextInputBar(
    this._displayText,
    this._hintText,
    this._leftWidget,
    this._rightWidget,
    this._onSubmitted, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.blue,
        padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Row(
          children: <Widget>[
            SizedBox(width: 32, height: 32, child: _leftWidget),
            Expanded(
              child: TextFormField(
                initialValue: _displayText,
                autocorrect: false,
                onFieldSubmitted: _onSubmitted,
                decoration: InputDecoration(
                  border: new OutlineInputBorder(borderRadius: new BorderRadius.circular(5.0)),
                  focusedBorder:
                      new OutlineInputBorder(borderRadius: new BorderRadius.circular(5.0)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  hintText: _hintText,
                  fillColor: grey(context, 200),
                  filled: true,
                ),
              ),
            ),
            SizedBox(width: 32, height: 32, child: _rightWidget),
          ],
        ));
  }
}
