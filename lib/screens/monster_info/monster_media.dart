import 'dart:math';

import 'package:dadguide2/components/images/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class OrbMediaWidget extends StatelessWidget {
  final int orbSkinId;

  OrbMediaWidget(this.orbSkinId);

  @override
  Widget build(BuildContext context) {
    var mq = MediaQuery.of(context);
    var minSize = min(mq.size.width, mq.size.height);
    var orbSize = minSize / 8;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            orbSkinOrb(orbSkinId, 0, false, size: orbSize),
            SizedBox(width: 4),
            orbSkinOrb(orbSkinId, 1, false, size: orbSize),
            SizedBox(width: 4),
            orbSkinOrb(orbSkinId, 2, false, size: orbSize),
            SizedBox(width: 4),
            orbSkinOrb(orbSkinId, 3, false, size: orbSize),
            SizedBox(width: 4),
            orbSkinOrb(orbSkinId, 4, false, size: orbSize),
          ],
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            orbSkinOrb(orbSkinId, 0, true, size: orbSize),
            SizedBox(width: 4),
            orbSkinOrb(orbSkinId, 1, true, size: orbSize),
            SizedBox(width: 4),
            orbSkinOrb(orbSkinId, 2, true, size: orbSize),
            SizedBox(width: 4),
            orbSkinOrb(orbSkinId, 3, true, size: orbSize),
            SizedBox(width: 4),
            orbSkinOrb(orbSkinId, 4, true, size: orbSize),
          ],
        ),
        Spacer(),
      ],
    );
  }
}

class VideoOnlyVideoPlayerWidget extends StatelessWidget {
  final int monsterId;

  VideoOnlyVideoPlayerWidget(this.monsterId);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<VideoPlayerController>(
      create: (context) {
        var url = animationUrl(monsterId);
        var player = VideoPlayerController.network(url);
        player.setLooping(true);
        player.initialize().then((_) => player.play());
        return player;
      },
      child: Consumer<VideoPlayerController>(
        builder: (context, controller, widget) {
          if (controller.value.hasError) {
            return Icon(Icons.error_outline);
          } else if (!controller.value.initialized) {
            return Icon(Icons.cloud_download);
          } else if (controller.value.isPlaying) {
            return GestureDetector(
              onTap: () async {
                await controller.pause();
              },
              child: VideoPlayer(controller),
            );
          } else {
            return Stack(
              children: <Widget>[
                VideoPlayer(controller),
                Center(
                  child: IconButton(
                    iconSize: 48,
                    onPressed: () async {
                      await controller.seekTo(Duration());
                      await controller.play();
                    },
                    icon: Icon(Icons.play_circle_filled),
                  ),
                )
              ],
            );
          }
        },
      ),
    );
  }
}

class AudioOnlyVideoPlayerWidget extends StatelessWidget {
  final String server;
  final int voiceId;

  const AudioOnlyVideoPlayerWidget(this.server, this.voiceId);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<VideoPlayerController>(
      create: (context) {
        var url = voiceUrl(server, voiceId);
        return VideoPlayerController.network(url)
          ..setLooping(false)
          ..initialize();
      },
      child: Consumer<VideoPlayerController>(
        builder: (context, controller, widget) {
          if (controller.value.hasError) {
            return Icon(Icons.error_outline, size: 48);
          } else if (!controller.value.initialized) {
            return Icon(Icons.cloud_download, size: 48);
          } else if (controller.value.isPlaying) {
            return IconButton(
              iconSize: 48,
              onPressed: () async {
                await controller.pause();
              },
              icon: Icon(Icons.pause_circle_filled),
            );
          } else {
            return IconButton(
              iconSize: 48,
              onPressed: () async {
                await controller.seekTo(Duration());
                await controller.play();
              },
              icon: Icon(Icons.play_circle_filled),
            );
          }
        },
      ),
    );
  }
}
