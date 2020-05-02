import 'package:flutter/foundation.dart';

enum BuildMode {
  release,
  profile,
  debug,
}

BuildMode buildMode = (() {
  if (kReleaseMode) {
    return BuildMode.release;
  }
  var result = BuildMode.profile;
  assert(() {
    result = BuildMode.debug;
    return true;
  }());
  return result;
}());
