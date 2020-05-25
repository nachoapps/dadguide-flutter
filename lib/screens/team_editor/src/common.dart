import 'dart:math';

import 'package:dadguide2/theme/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class OutlineText extends StatelessWidget {
  final String text;
  final Color color;
  final double size;
  final double outlineWidth;

  const OutlineText(this.text,
      {Key key, this.color = Colors.white, this.size = 14, this.outlineWidth = 2})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // Stroked text as border.
        Text(
          text,
          style: TextStyle(
            fontSize: size,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = outlineWidth
              ..color = Colors.black,
          ),
        ),
        // Solid text as fill.
        Text(
          text,
          style: TextStyle(
            fontSize: size,
            color: color,
          ),
        ),
      ],
    );
  }
}

class ClickDialogIfEditable extends StatelessWidget {
  final Widget widget;
  final Widget editableWidget;
  final WidgetBuilder dialogBuilder;

  const ClickDialogIfEditable(
      {@required this.widget, this.editableWidget, @required this.dialogBuilder});

  @override
  Widget build(BuildContext context) {
    var controller = Provider.of<TeamController>(context);
    var editable = controller.editable;

    return !editable
        ? widget
        : GestureDetector(
            child: editableWidget ?? widget,
            onTap: () async {
              await showDialog<void>(
                context: context,
                builder: (dialogContext) {
                  return ChangeNotifierProvider.value(
                      value: controller, child: dialogBuilder(dialogContext));
                },
              );
            },
          );
  }
}

class TeamController with ChangeNotifier {
  final bool editable;

  TeamController({this.editable = true});

  void notify() {
    notifyListeners();
  }
}

class StatRow extends StatelessWidget {
  final String title;
  final int Function() getValue;
  final void Function(int) setValue;
  final int minValue;
  final int altValue;
  final int maxValue;

  const StatRow(
      {Key key,
      this.title,
      this.getValue,
      this.setValue,
      this.minValue,
      this.altValue,
      this.maxValue})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var controller = Provider.of<TeamController>(context);

    return Row(
      children: <Widget>[
        Text(title),
        SizedBox(width: 8),
        SizedBox(
          width: 46,
          child: BoxedNumberInput(
            getValue().toString(),
            (v) {
              var intVal = int.parse(v);
              intVal = max(minValue, intVal);
              intVal = min(maxValue, intVal);
              setValue(intVal);
              controller.notify();
            },
            key: ValueKey(getValue),
          ),
        ),
        SizedBox(width: 8),
        if (altValue != null)
          SizedBox(
            width: 88,
            child: FlatButton(
                onPressed: () {
                  setValue(altValue);
                  controller.notify();
                },
                child: Text('Set $altValue')),
          ),
        SizedBox(
          width: 88,
          child: FlatButton(
              onPressed: () {
                setValue(maxValue);
                controller.notify();
              },
              child: Text('Set $maxValue')),
        ),
      ],
    );
  }
}

class BoxedNumberInput extends StatelessWidget {
  final String _text;
  final ValueChanged<String> _onChanged;

  const BoxedNumberInput(this._text, this._onChanged, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: TextFormField(
        keyboardType: TextInputType.number,
        inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
        initialValue: _text,
        onChanged: _onChanged,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(2.0)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2.0)),
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          fillColor: grey(context, 200),
          filled: true,
        ),
      ),
    );
  }
}
