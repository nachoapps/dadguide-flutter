import 'package:cached_network_image/cached_network_image.dart';
import 'package:dadguide2/components/cache.dart';
import 'package:dadguide2/components/icons.dart';
import 'package:dadguide2/components/navigation.dart';
import 'package:dadguide2/components/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Removes the portrait and icon for a monster from the cache.
Future<void> clearImageCache(int monsterId) async {
  var cacheManager = getIt<PermanentCacheManager>();
  await cacheManager.removeFile(_imageUrl('portraits', monsterId, 5));
  await cacheManager.removeFile(_imageUrl('icons', monsterId, 5));
}

/// Returns a widget with a loading indicator until the image loads from the cache.
Widget portraitImage(int portraitId) {
  var url = _imageUrl('portraits', portraitId, 5);
  return _loadingImage(url);
}

/// Widget containing an icon for a monster or dungeon. When clicked it may optionally redirect
/// to the underlying data. This makes sense for a monster or dungeon, but not as much for an icon
/// representing an event or attached to a list.
class PadIcon extends StatelessWidget {
  final int iconId;
  final double size;
  final bool monsterLink;
  final bool dungeonLink;
  final int subDungeonId;
  final int dungeonId;
  final bool ink;
  final bool inheritable;

  PadIcon(this.iconId,
      {this.size = 48,
      this.monsterLink = false,
      this.dungeonLink = false,
      this.dungeonId,
      this.subDungeonId,
      this.ink = false,
      this.inheritable = false});

  @override
  Widget build(BuildContext context) {
    var finalIconId = iconId ?? 0;
    var url = _imageUrl('icons', finalIconId, 5);
    var container = _sizedContainer(_loadingImage(url), size);
    if (monsterLink && isMonsterId(finalIconId)) {
      container = wrapMonsterLink(context, container, finalIconId, ink: ink);
    } else if (dungeonLink) {
      container =
          wrapDungeonLink(context, container, dungeonId, subDungeonId: subDungeonId, ink: ink);
    }

    if (inheritable) {
      container = wrapInheritable(context, container, size);
    }
    return container;
  }
}

// TODO: should probably adjust the special icon range
bool isMonsterId(int monsterId) {
  return monsterId < 9000 || monsterId > 9999;
}

/// Returns a widget with a loading indicator until the image loads from the cache.
Widget awakeningContainer(int awakeningId, {double size: 24}) {
  var url = _imageUrl('awakenings', awakeningId, 3);
  return _sizedContainer(_loadingImage(url), size);
}

/// Returns a widget with a loading indicator until the image loads from the cache.
Widget latentContainer(int latentId, {double size: 24}) {
  var url = _imageUrl('latents', latentId, 3);
  return _sizedContainer(_loadingImage(url), size);
}

/// Returns a widget with a loading indicator until the image loads from the cache.
Widget typeContainer(int typeId, {double size: 16, double leftPadding: 0}) {
  if (typeId == null) return Container(width: 0.0, height: 0.0);
  var url = _imageUrl('types', typeId, 3);
  var container = _sizedContainer(_loadingImage(url), size);
  return leftPadding > 0
      ? Padding(padding: EdgeInsets.only(left: leftPadding), child: container)
      : container;
}

// TODO: convert to using Endpoints
String _imageUrl(String category, int value, int length) {
  var paddedNo = value.toString().padLeft(length, '0');
  return 'https://f002.backblazeb2.com/file/dadguide-data/media/$category/$paddedNo.png';
}

Widget _sizedContainer(Widget child, double size) {
  return new SizedBox(
    width: size,
    height: size,
    child: new Center(child: child),
  );
}

Widget _loadingImage(String url) {
  final cacheManager = getIt<PermanentCacheManager>();
  return CachedNetworkImage(
    placeholder: (context, url) => CircularProgressIndicator(),
    // Changed this from the default to try and minimize the presence of the progress indicator
    // if the item is already in the cache.
    fadeInDuration: Duration(),
    fadeOutDuration: Duration(),
    fadeInCurve: Curves.linear,
    fadeOutCurve: Curves.linear,
    imageUrl: url,
    cacheManager: cacheManager,
    errorWidget: (BuildContext context, String url, Object error) => Icon(Icons.error_outline),
  );
}

/// Given an icon, sticks it in a slightly larger container, shifts it to the lower left, and
/// inserts the inheritable badge in the upper right.
Widget wrapInheritable(BuildContext context, Widget child, double size) {
  return SizedBox(
    width: size + 2,
    height: size + 2,
    child: Stack(
      children: [
        Positioned(bottom: 0, left: 0, child: child),
        Positioned(
          top: 0,
          right: 0,
          child: DadGuideIcons.inheritableBadge,
        ),
      ],
    ),
  );
}
