import 'dart:math';

import 'package:dadguide2/components/firebase/src/ads.dart';
import 'package:dadguide2/components/images/images.dart';
import 'package:dadguide2/components/models/enums.dart';
import 'package:dadguide2/components/ui/buttons.dart';
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
    var size = 0;
    for (var l in monster.latents) {
      var lSize = min(4, l.slots);
      if (size + lSize <= 4) {
        row1.add(l);
      } else {
        row2.add(l);
      }
      size += lSize;
    }

    Widget widget;
    if (monster.latents.isEmpty) {
      if (editable) {
        widget = OutlineWidget(
          child: SizedBox(
            width: 64,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(monster.hasMonster ? 'Latents' : '-'),
              ),
            ),
          ),
        );
      } else {
        widget = SizedBox(width: 100, height: 1);
      }
    } else {
      widget = SizedBox(width: 64, child: _contentWith(row1, row2));
    }

    if (editable && monster.hasMonster) {
      return ClickDialogIfEditable(
          widget: widget,
          dialogBuilder: (_) => ChangeNotifierProvider.value(
                value: controller,
                child: EditLatentsDialog(monster),
              ));
    } else {
      return widget;
    }
  }

  Widget _contentWith(List<Latent> row1, List<Latent> row2) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            for (var l in row1)
              SizedBox(width: 64 / 4 * min(4, l.slots), child: latentImage(l.id, tslim: true)),
          ],
        ),
        SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (row2.isEmpty) SizedBox(height: 16),
            if (row2.isNotEmpty)
              for (var l in row2)
                SizedBox(width: 64 / 4 * min(4, l.slots), child: latentImage(l.id, tslim: true)),
          ],
        ),
      ],
    );
  }
}

class EditLatentsDialog extends StatelessWidget {
  final TeamBase monster;

  const EditLatentsDialog(this.monster, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var controller = Provider.of<TeamController>(context);

    return AlertDialog(
      insetPadding: dialogInsetsAccountingForAd(context),
      title: Row(
        children: <Widget>[
          Text('Edit Latents'),
          Spacer(),
          ExitButton(),
        ],
      ),
      content: Theme(
        data: Theme.of(context).copyWith(visualDensity: VisualDensity.compact),
        child: SingleChildScrollView(
          child: Column(
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
                        label: latentImage(l.id, tslim: true),
                      ),
                  ],
                ),
              ],
              Text('Available'),
              Wrap(
                children: <Widget>[
                  for (var l in monster.availableLatents)
                    InputChip(
                      isEnabled: monster.maxLatents >= (monster.currentLatents + l.slots),
                      onSelected: (v) {
                        monster.latents.add(l);
                        controller.notify();
                      },
                      label: latentImage(l.id, tslim: true),
                    ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
