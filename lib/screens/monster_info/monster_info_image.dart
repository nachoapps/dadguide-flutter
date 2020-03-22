import 'dart:io';

import 'package:dadguide2/components/config/settings_manager.dart';
import 'package:dadguide2/components/firebase/remote_config.dart';
import 'package:dadguide2/components/images/images.dart';
import 'package:dadguide2/components/models/data_objects.dart';
import 'package:dadguide2/components/ui/navigation.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fimber/flutter_fimber.dart';
import 'package:provider/provider.dart';

import 'monster_media.dart';

enum ImageState {
  portrait,
  hqPortrait,
  animation,
  jpVoice,
  naVoice,
  orbSkin,
}

class ImageDisplayState with ChangeNotifier {
  ImageState selected = ImageState.portrait;

  set newState(ImageState newState) {
    selected = newState;
    notifyListeners();
  }
}

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
    var m = widget.data.monster;
    var showActions = m.hasAnimation ||
//        m.hasHqimage ||
        m.orbSkinId != null ||
        m.voiceIdJp != null ||
        m.voiceIdNa != null;

    return ChangeNotifierProvider(
      create: (context) => ImageDisplayState(),
      child: Column(
        children: <Widget>[
          AspectRatio(
              aspectRatio: 5 / 3,
              child: Stack(children: [
                Center(child: MediaViewWidget(widget.data)),
                Positioned(
                  left: 10,
                  top: 10,
                  child: Column(
                    children: [
                      if (m.linkedMonsterId != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: PadIcon(
                            m.linkedMonsterId,
                            size: 36,
                            monsterLink: true,
                          ),
                        ),
                      InkWell(
                        child: new Icon(Icons.autorenew),
                        onTap: _refreshIcon,
                      ),
                    ],
                  ),
                ),
                Positioned.fill(
                  child: MonsterDetailPortraitAwakenings(widget.data),
                ),
                Positioned(
                  bottom: 0,
                  left: 10,
                  right: 10,
                  child: ImageActionsWidget(widget.data),
                ),
              ])),
          if (showActions && !RemoteConfigWrapper.disableMedia) MediaSelectionWidget(widget.data),
        ],
      ),
    );
  }

  Future<void> _refreshIcon() async {
    await clearImageCache(widget.data.monster.monsterId);
    setState(() {});
  }
}

class MediaViewWidget extends StatelessWidget {
  final FullMonster data;

  const MediaViewWidget(this.data);

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<ImageDisplayState>(context);
    switch (state.selected) {
      case ImageState.portrait:
        return portraitImage(data.monster.monsterId);
      case ImageState.hqPortrait:
        return hqPortraitImage(data.monster.monsterId);
        break;
      case ImageState.animation:
        String url = animationUrl(data.monster.monsterId);
        return CachedMediaPlayerWidget(url, key: ValueKey(url), video: true);
      case ImageState.jpVoice:
        String url = voiceUrl('jp', data.monster.voiceIdJp);
        return CachedMediaPlayerWidget(url, key: ValueKey(url), video: false);
      case ImageState.naVoice:
        String url = voiceUrl('na', data.monster.voiceIdJp);
        return CachedMediaPlayerWidget(url, key: ValueKey(url), video: false);
      case ImageState.orbSkin:
        return OrbMediaWidget(data.monster.orbSkinId);
    }
    Fimber.e('Unexpected state: ${state.selected}');
    return Icon(Icons.error_outline, size: 48);
  }
}

class ImageActionsWidget extends StatelessWidget {
  final FullMonster data;

  const ImageActionsWidget(this.data);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (data.prevMonsterId != null)
          InkWell(
            child: Icon(Icons.chevron_left),
            onTap: goToMonsterFn(context, data.prevMonsterId, replace: true),
          ),
        Spacer(),
        if (data.nextMonsterId != null)
          InkWell(
            child: Icon(Icons.chevron_right),
            onTap: goToMonsterFn(context, data.nextMonsterId, replace: true),
          ),
      ],
    );
  }
}

class MediaSelectionWidget extends StatelessWidget {
  final FullMonster data;

  MediaSelectionWidget(this.data);

  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);
    var state = Provider.of<ImageDisplayState>(context);

    var m = data.monster;
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        ChoiceChip(
          label: Text(loc.monsterMediaImage),
          selected: state.selected == ImageState.portrait,
          onSelected: (v) => state.newState = ImageState.portrait,
        ),
//        if (m.hasHqimage)
//          ChoiceChip(
//            label: Text('HQ'),
//            selected: state.selected == ImageState.hqPortrait,
//            onSelected: (v) => state.newState = ImageState.hqPortrait,
//          ),
        if (m.hasAnimation)
          ChoiceChip(
            label: Text(loc.monsterMediaVideo),
            selected: state.selected == ImageState.animation,
            onSelected: (v) async {
              if (!Prefs.mediaWarningDisplayed) {
                Prefs.mediaWarningDisplayed = true;
                showDialog(
                    context: context,
                    child: AlertDialog(
                      title: Text(loc.warning),
                      content: Text(loc.monsterMediaWarningBody),
                      actions: [
                        RaisedButton(
                          child: Text(loc.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ));
                return false;
              }
              state.newState = ImageState.animation;
              return true;
            },
          ),
        if (m.orbSkinId != null)
          ChoiceChip(
            label: Text(loc.monsterMediaOrbs),
            selected: state.selected == ImageState.orbSkin,
            onSelected: (v) => state.newState = ImageState.orbSkin,
          ),
        if (m.voiceIdJp != null && Platform.isAndroid)
          ChoiceChip(
            label: Text(loc.monsterMediaJPVoice),
            selected: state.selected == ImageState.jpVoice,
            onSelected: (v) => state.newState = ImageState.jpVoice,
          ),
        if (m.voiceIdNa != null && Platform.isAndroid)
          ChoiceChip(
            label: Text(loc.monsterMediaNAVoice),
            selected: state.selected == ImageState.naVoice,
            onSelected: (v) => state.newState = ImageState.naVoice,
          ),
      ],
    );
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
