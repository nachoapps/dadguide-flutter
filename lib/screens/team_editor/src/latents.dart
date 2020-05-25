import 'dart:math';

import 'package:dadguide2/components/images/images.dart';
import 'package:dadguide2/components/models/enums.dart';
import 'package:dadguide2/components/ui/containers.dart';
import 'package:dadguide2/screens/team_editor/team_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'common.dart';

class LatentsArea extends StatelessWidget {
  final TeamBase monster;

  const LatentsArea(this.monster, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var controller = Provider.of<TeamController>(context);
    var editable = controller.editable;

    var row1 = <Latent>[];
    var row2 = <Latent>[];
    int size = 0;
    for (var l in monster.latents) {
      var lSize = min(4, l.slots);
      if (size + lSize <= 4) {
        row1.add(l);
      } else {
        row2.add(l);
      }
      size += lSize;
    }

    var widget = monster.latents.isEmpty ? _contentWithout(editable) : _contentWith(row1, row2);

    return ClickDialogIfEditable(
        widget: widget,
        editableWidget: OutlineWidget(child: SizedBox(width: 64, child: Center(child: widget))),
        dialogBuilder: (_) => ChangeNotifierProvider.value(
              value: controller,
              child: EditLatentsDialog(monster),
            ));
  }

  Widget _contentWith(List<Latent> row1, List<Latent> row2) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            for (var l in row1) SizedBox(width: 64 / 4 * min(4, l.slots), child: latentImage(l.id)),
          ],
        ),
        Row(
          children: <Widget>[
            if (row2.isNotEmpty)
              for (var l in row2)
                SizedBox(width: 64 / 4 * min(4, l.slots), child: latentImage(l.id)),
          ],
        ),
      ],
    );
  }

  Widget _contentWithout(bool editable) {
    return editable
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Text('Latents'),
          )
        : Container();
  }
}

class EditLatentsDialog extends StatelessWidget {
  final TeamBase monster;

  const EditLatentsDialog(this.monster, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var controller = Provider.of<TeamController>(context);

    return AlertDialog(
      title: Text('Edit Latents'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (monster.latents.isNotEmpty) ...[
            Text('Selected'),
            Wrap(
              children: <Widget>[
                for (var l in monster.latents)
                  InputChip(
                    onDeleted: () {
                      monster.latents.remove(l);
                      controller.notify();
                    },
                    label: latentContainer(l.id, size: 32),
                  ),
              ],
            ),
          ],
          Text('Available'),
          Wrap(
            children: <Widget>[
              for (var l in Latent.all)
                InputChip(
                  onSelected: (v) {
                    monster.latents.add(l);
                    controller.notify();
                  },
                  label: latentContainer(l.id, size: 28),
                ),
            ],
          )
        ],
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('Done'),
          onPressed: () {
            Navigator.of(context).pop(); // Dismiss alert dialog
          },
        ),
      ],
    );
  }
}
