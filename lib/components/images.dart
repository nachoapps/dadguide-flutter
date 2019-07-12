import 'package:cached_network_image/cached_network_image.dart';
import 'package:dadguide2/components/cache.dart';
import 'package:dadguide2/components/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Widget portraitImage(int portraitId) {
  var url = _imageUrl('portraits', portraitId, 5);
  return _loadingImage(url);
}

Widget iconContainer(int iconId, {double size: 48}) {
  iconId ??= 0;
  var url = _imageUrl('icons', iconId, 5);
  return _sizedContainer(_loadingImage(url), size);
}

Widget awakeningContainer(int awakeningId, {double size: 24}) {
  var url = _imageUrl('awakenings', awakeningId, 3);
  return _sizedContainer(_loadingImage(url), size);
}

Widget latentContainer(int latentId, {double size: 24}) {
  var url = _imageUrl('latents', latentId, 3);
  return _sizedContainer(_loadingImage(url), size);
}

Widget typeContainer(int typeId, {double size: 24, double leftPadding: 0}) {
  if (typeId == null) return Container(width: 0.0, height: 0.0);
  var url = _imageUrl('types', typeId, 3);
  var container = _sizedContainer(_loadingImage(url), size);
  return leftPadding > 0
      ? Padding(padding: EdgeInsets.only(left: leftPadding), child: container)
      : container;
}

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
    fadeInDuration: Duration(),
    fadeOutDuration: Duration(),
    fadeInCurve: Curves.linear,
    fadeOutCurve: Curves.linear,
    imageUrl: url,
    cacheManager: cacheManager,
    errorWidget: (BuildContext context, String url, Object error) => Icon(Icons.error_outline),
  );
}
