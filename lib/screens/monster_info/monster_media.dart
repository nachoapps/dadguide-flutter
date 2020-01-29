import 'dart:io';
import 'dart:math';

import 'package:dadguide2/components/config/service_locator.dart';
import 'package:dadguide2/components/images/cache.dart';
import 'package:dadguide2/components/images/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_fimber/flutter_fimber.dart';
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

class CachedMediaPlayerWidget extends StatefulWidget {
  final String url;
  final bool video;
  const CachedMediaPlayerWidget(this.url, {Key key, this.video}) : super(key: key);

  @override
  _CachedMediaPlayerWidgetState createState() => _CachedMediaPlayerWidgetState();
}

class _CachedMediaPlayerWidgetState extends State<CachedMediaPlayerWidget> {
  Future<File> loadingFuture;

  @override
  void initState() {
    super.initState();
    loadingFuture = getIt<PermanentCacheManager>().getSingleFile(widget.url);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File>(
        future: loadingFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            Fimber.e('Failed to load media to cache', ex: snapshot.error);
            return Icon(Icons.error_outline, size: 48);
          } else if (snapshot.hasData) {
            if (widget.video) {
              return MediaPlayerWidget.video(snapshot.data);
            } else {
              return MediaPlayerWidget.audio(snapshot.data);
            }
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}

class MediaPlayerWidget extends StatelessWidget {
  final File file;
  final bool looping;
  final bool autoPlay;
  final bool displayControls;

  MediaPlayerWidget.video(this.file)
      : looping = true,
        autoPlay = true,
        displayControls = false;

  MediaPlayerWidget.audio(this.file)
      : looping = false,
        autoPlay = false,
        displayControls = true;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<VideoPlayerController>(
      create: (context) {
        var player = VideoPlayerController.file(file);
        player.setLooping(looping);
        player.initialize().then((_) {
          if (autoPlay) {
            player.play();
          }
        });
        return player;
      },
      child: Consumer<VideoPlayerController>(
        builder: (context, controller, widget) {
          if (controller.value.hasError) {
            Fimber.e('Failed to load cached media: ${controller.value.errorDescription}');
            return Icon(Icons.error_outline, size: 48);
          } else if (!controller.value.initialized) {
            return Icon(Icons.cloud_download, size: 48);
          } else if (controller.value.isPlaying) {
            return GestureDetector(
              onTap: () async {
                await controller.pause();
              },
              child: Stack(
                children: <Widget>[
                  VideoPlayer(controller),
                  if (displayControls) Center(child: Icon(Icons.pause_circle_filled, size: 48)),
                ],
              ),
            );
          } else {
            return GestureDetector(
              onTap: () async {
                await controller.seekTo(Duration());
                await controller.play();
              },
              child: Stack(
                children: <Widget>[
                  VideoPlayer(controller),
                  if (displayControls) Center(child: Icon(Icons.play_circle_filled, size: 48)),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
