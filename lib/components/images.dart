import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

String portraitFor(int portraitId) {
  var paddedNo = portraitId.toString().padLeft(4, '0');
  return 'http://miru.info/padguide/images/icons/portrait_$paddedNo.png';
}

String _iconFor(int iconId) {
  var paddedNo = iconId.toString().padLeft(4, '0');
  return 'http://miru.info/padguide/images/icons/icon_$paddedNo.png';
}

String _awakeningFor(int awakeningId) {
  var paddedNo = awakeningId.toString().padLeft(4, '0');
  return 'http://miru.info/padguide/images/icons/awakening_$paddedNo.png';
}

Widget _sizedContainer(Widget child, double size) {
  return new SizedBox(
    width: size,
    height: size,
    child: new Center(child: child),
  );
}

Widget loadingImage(String url) {
  return CachedNetworkImage(
    placeholder: (context, url) => CircularProgressIndicator(),
    imageUrl: url,
  );
}

Widget iconContainer(int iconId) {
  return _sizedContainer(loadingImage(_iconFor(iconId)), 48);
}

Widget awakeningContainer(int awakeningId) {
  return _sizedContainer(loadingImage(_awakeningFor(awakeningId)), 12);
}
