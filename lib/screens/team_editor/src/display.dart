import 'package:dadguide2/components/firebase/src/ads.dart';
import 'package:dadguide2/components/images/images.dart';
import 'package:dadguide2/components/models/enums.dart';
import 'package:dadguide2/screens/team_editor/team_data.dart';
import 'package:dadguide2/theme/style.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'assist_icon.dart';
import 'base_icon.dart';
import 'common.dart';
import 'latents.dart';

class TeamDisplayTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var controller = Provider.of<TeamController>(context);
    var item = controller.item;

    if (item.team2 == null) {
      return TeamDisplayTile1P();
    } else if (item.team3 == null) {
      return TeamDisplayTile2P();
    } else {
      return TeamDisplayTile3P();
    }
  }
}

class TeamDisplayTile1P extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var controller = Provider.of<TeamController>(context);
    var item = controller.item;

    var team = item.team1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(child: BuildNameArea()),
              SizedBox(width: 16),
              BadgeButton(team),
            ],
          ),
        ),
        TeamRow(team),
        if (!controller.hideText) ...[
          Divider(),
          BuildDescriptionArea(),
        ],
      ],
    );
  }
}

class TeamDisplayTile2P extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var controller = Provider.of<TeamController>(context);
    var item = controller.item;

    var team1 = item.team1;
    var team2 = item.team2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: BuildNameArea(),
        ),
        Row(
          children: <Widget>[
            Flexible(flex: 5, fit: FlexFit.tight, child: TeamRow(team1, isTwoPlayer: true)),
            Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Center(child: Text('P1', style: subtitle(context)))),
          ],
        ),
        SizedBox(height: 8),
        Row(
          children: <Widget>[
            Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Center(child: Text('P2', style: subtitle(context)))),
            Flexible(
                flex: 5,
                fit: FlexFit.tight,
                child: TeamRow(team2, isTwoPlayer: true, isSecondPlayer: true)),
          ],
        ),
        if (!controller.hideText) ...[
          Divider(),
          BuildDescriptionArea(),
        ],
      ],
    );
  }
}

class TeamDisplayTile3P extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var controller = Provider.of<TeamController>(context);
    var item = controller.item;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: BuildNameArea(),
        ),
        Title3P(1, item.team1),
        TeamRow(item.team1),
        SizedBox(height: 8),
        Title3P(2, item.team2),
        TeamRow(item.team2),
        SizedBox(height: 8),
        Title3P(3, item.team3),
        TeamRow(item.team3),
        if (!controller.hideText) ...[
          Divider(),
          BuildDescriptionArea(),
        ],
      ],
    );
  }
}

/// Title above a 3P team listing the player ID and their badge.
class Title3P extends StatelessWidget {
  final int playerId;
  final Team team;

  const Title3P(this.playerId, this.team, {Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Text('Player $playerId', style: subtitle(context)),
            SizedBox(width: 8),
            BadgeButton(team),
          ],
        ));
  }
}

class BuildNameArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var controller = Provider.of<TeamController>(context);
    var item = controller.item;

    return controller.editable
        ? Focus(
            onFocusChange: (v) {
              if (!v) {
                controller.notify();
              }
            },
            child: TextField(
              controller: TextEditingController(text: item.title),
              onChanged: (v) => item.title = v,
              decoration: InputDecoration(hintText: 'Enter build name'),
              style: headline(context),
            ),
          )
        : Text(item.displayTitle, style: headline(context));
  }
}

class BuildDescriptionArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var controller = Provider.of<TeamController>(context);
    var item = controller.item;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: controller.editable
          ? Focus(
              onFocusChange: (v) {
                if (!v) {
                  controller.notify();
                }
              },
              child: TextField(
                controller: TextEditingController(text: item.description),
                maxLines: null,
                decoration: InputDecoration(hintText: 'Enter build details'),
                onChanged: (v) => item.description = v,
              ),
            )
          : Text(item.description),
    );
  }
}

class BadgeButton extends StatelessWidget {
  final Team team;

  const BadgeButton(this.team, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var controller = Provider.of<TeamController>(context);

    if (!controller.badgeEnabled || (!controller.editable && team.badge.id == 0)) {
      return Container();
    }

    return ClickDialogIfEditable(
        widget: SizedBox(width: 40, child: badgeImage(team.badge.id)),
        dialogBuilder: (_) => ChangeNotifierProvider.value(
              value: controller,
              child: SelectBadgeDialog(team),
            ));
  }
}

class SelectBadgeDialog extends StatelessWidget {
  final Team item;

  const SelectBadgeDialog(this.item, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var controller = Provider.of<TeamController>(context);

    return AlertDialog(
      insetPadding: dialogInsetsAccountingForAd(context),
      title: Text('Select Badge'),
      content: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: [
          for (var b in Badge.all)
            GestureDetector(
              child: SizedBox(width: 60, child: badgeImage(b.id)),
              onTap: () {
                item.badge = b;
                controller.notify();
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }
}

/// Standard team display row, used in 1P and 3P.
class TeamRow extends StatelessWidget {
  final Team team;
  final bool isTwoPlayer;
  final bool isSecondPlayer;

  const TeamRow(this.team, {Key key, this.isTwoPlayer = false, this.isSecondPlayer = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var assistRow = generateRow(
      AssistImage(team.leader.assist),
      AssistImage(team.sub1.assist),
      AssistImage(team.sub2.assist),
      AssistImage(team.sub3.assist),
      AssistImage(team.sub4.assist),
      AssistImage(team.friend.assist),
    );
    var baseRow = generateRow(
      BaseImage(team.leader.base),
      BaseImage(team.sub1.base),
      BaseImage(team.sub2.base),
      BaseImage(team.sub3.base),
      BaseImage(team.sub4.base),
      BaseImage(team.friend.base),
    );
    var latentsRow = generateRow(
      LatentsArea(team.leader.base),
      LatentsArea(team.sub1.base),
      LatentsArea(team.sub2.base),
      LatentsArea(team.sub3.base),
      LatentsArea(team.sub4.base),
      LatentsArea(team.friend.base),
    );
    var rowData = isTwoPlayer ? [assistRow, latentsRow, baseRow] : [assistRow, baseRow, latentsRow];
    if (isSecondPlayer) rowData.reversed.toList();
    return Table(children: rowData);
  }

  TableRow generateRow(
      Widget lead, Widget sub1, Widget sub2, Widget sub3, Widget sub4, Widget friend,
      {bool doFit = true}) {
    Widget leadWidget;
    Widget friendWidget;
    if (!isTwoPlayer) {
      leadWidget = lead;
      friendWidget = friend;
    } else {
      if (!isSecondPlayer) {
        leadWidget = lead;
      } else {
        friendWidget = lead;
      }
    }

    return TableRow(
      children: [
        if (leadWidget != null) leadWidget,
        sub1,
        sub2,
        sub3,
        sub4,
        if (friendWidget != null) friendWidget,
      ].map((e) => fitAndPad(e, doFit, 2)).toList(),
    );
  }
}

Widget fitAndPad(Widget child, bool fit, double bottom) {
  // I'm not sure why this is necessary, but it sometimes explodes with height is not > 0 errors
  // unless this is put in, although rendering works properly.
  child = ConstrainedBox(
    constraints: BoxConstraints(
      minHeight: 1,
      minWidth: 1,
    ),
    child: child,
  );
  return Padding(
    padding: EdgeInsets.only(bottom: bottom),
    child: FittedBox(child: child),
  );
}
