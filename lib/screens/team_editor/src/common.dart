import 'dart:math';

import 'package:dadguide2/components/config/service_locator.dart';
import 'package:dadguide2/components/ui/containers.dart';
import 'package:dadguide2/data/local_tables.dart';
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
            behavior: HitTestBehavior.opaque,
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
  final EditableBuild item;
  final bool hideText;

  TeamController({@required this.item, this.editable = true, this.hideText = false});

  void notify() {
    notifyListeners();
    getIt<BuildsDao>().saveBuild(item.toBuild());
  }

  bool get is1p => item.team2 == null;
  bool get is2p => item.team2 != null && item.team3 == null;
  bool get is3p => item.team3 != null;

  bool get badgeEnabled => !is2p;
  bool get saEnabled => !is2p;
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
        SizedBox(width: 50, child: Text(title)),
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
      ],
    );
  }
}

class BoxedNumberInput extends StatelessWidget {
  final String _text;
  final ValueChanged<String> _onChanged;
  final focusNode = FocusNode();

  BoxedNumberInput(this._text, this._onChanged, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('hi');
    return SizedBox(
      height: 24,
      child: EnsureVisibleWhenFocused(
        focusNode: focusNode,
        child: TextFormField(
          focusNode: focusNode,
          textAlign: TextAlign.right,
          keyboardType: TextInputType.number,
          inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
          initialValue: _text,
          onFieldSubmitted: _onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(2.0)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2.0)),
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            fillColor: grey(context, 200),
            filled: true,
          ),
        ),
      ),
    );
  }
}
