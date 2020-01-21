import 'package:dadguide2/components/images/images.dart';
import 'package:dadguide2/components/models/data_objects.dart';
import 'package:dadguide2/components/ui/navigation.dart';
import 'package:flutter/material.dart';

// Displays the monster image, refresh icon, awakenings, and left/right buttons.
class MonsterDetailPortrait extends StatefulWidget {
  final FullMonster data;

  const MonsterDetailPortrait(this.data, {Key key}) : super(key: key);

  @override
  _MonsterDetailPortraitState createState() => _MonsterDetailPortraitState();
}

class _MonsterDetailPortraitState extends State<MonsterDetailPortrait> {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
        aspectRatio: 5 / 3,
        child: Stack(children: [
          Center(child: portraitImage(widget.data.monster.monsterId)),
          Positioned(
            left: 10,
            top: 10,
            child: InkWell(
              child: new Icon(Icons.autorenew),
              onTap: _refreshIcon,
            ),
          ),
          Positioned.fill(
            child: MonsterDetailPortraitAwakenings(widget.data),
          ),
          if (widget.data.prevMonsterId != null)
            Positioned(
              left: 10,
              bottom: 4,
              child: InkWell(
                child: Icon(Icons.chevron_left),
                onTap: goToMonsterFn(context, widget.data.prevMonsterId),
              ),
            ),
          if (widget.data.nextMonsterId != null)
            Positioned(
              right: 10,
              bottom: 4,
              child: InkWell(
                child: Icon(Icons.chevron_right),
                onTap: goToMonsterFn(context, widget.data.nextMonsterId),
              ),
            ),
        ]));
  }

  Future<void> _refreshIcon() async {
    await clearImageCache(widget.data.monster.monsterId);
    setState(() {});
  }
}

/// The awakenings and super awakenings to display over the portrait.
class MonsterDetailPortraitAwakenings extends StatelessWidget {
  final FullMonster _data;

  const MonsterDetailPortraitAwakenings(this._data, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, right: 10, bottom: 30),
      child: Align(
        alignment: Alignment.topRight,
        child: LayoutBuilder(
          builder: (context, constraints) {
            var maxHeight = constraints.biggest.height / 10;
            return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_data.superAwakenings.isNotEmpty)
                  Column(
                    children: [
                      for (var a in _data.superAwakenings)
                        Padding(
                            padding: EdgeInsets.only(bottom: 2),
                            child: awakeningContainer(a.awokenSkillId, size: maxHeight)),
                    ],
                  ),
                if (_data.superAwakenings.isNotEmpty && _data.awakenings.isNotEmpty)
                  SizedBox(width: 8),
                if (_data.awakenings.isNotEmpty)
                  Column(
                    children: [
                      for (var a in _data.awakenings)
                        Padding(
                            padding: EdgeInsets.only(bottom: 2),
                            child: awakeningContainer(a.awokenSkillId, size: maxHeight)),
                    ],
                  )
              ],
            );
          },
        ),
      ),
    );
  }
}
