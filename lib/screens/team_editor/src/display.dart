import 'package:dadguide2/components/ui/containers.dart';
import 'package:dadguide2/data/local_tables.dart';
import 'package:dadguide2/screens/team_editor/team_data.dart';
import 'package:dadguide2/theme/style.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'assist_icon.dart';
import 'base_icon.dart';
import 'common.dart';
import 'latents.dart';

class TeamDisplayTile extends StatelessWidget {
  final EditableBuild item;

  const TeamDisplayTile(this.item, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var controller = Provider.of<TeamController>(context);
    var team = item.team1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: item.title),
                  onSubmitted: (v) {
                    item.title = v;
                    controller.notify();
                  },
                  decoration: InputDecoration(hintText: 'Enter build name'),
                  style: subtitle(context),
                ),
              ),
              SizedBox(width: 8),
              OutlineWidget(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Badge'),
              ))
            ],
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            TeamSlot(team.leader),
            SizedBox(width: 4),
            TeamSlot(team.sub1),
            TeamSlot(team.sub2),
            TeamSlot(team.sub3),
            TeamSlot(team.sub4),
            SizedBox(width: 4),
            TeamSlot(team.friend),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            maxLines: null,
            decoration: InputDecoration(hintText: 'Enter build details'),
            onSubmitted: (v) {
              item.description = v;
              controller.notify();
            },
          ),
        ),
      ],
    );
  }
}

class TeamSlot extends StatelessWidget {
  final TeamMonster monster;
  final bool invert;

  const TeamSlot(this.monster, {Key key, this.invert = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var widgets = <Widget>[
      AssistImage(monster.assist),
      SizedBox(height: 2),
      BaseImage(monster.base),
      SizedBox(height: 2),
      LatentsArea(monster.base),
    ];

    if (invert) widgets = widgets.reversed.toList();

    return Column(children: widgets);
  }
}
