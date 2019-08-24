import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

// TODO: try other implementations on iOS like this one:
// https://github.com/flutter/plugins/blob/master/packages/url_launcher/example/lib/main.dart

/// Try to launch YT natively, falling back to a browser.
///
/// This seems to work on Android but not on iOS. Needs some experimentation.
Future<void> launchYouTubeSearch(String query) async {
  var url = 'https://www.youtube.com/results?search_query=$query';
  var youtubePrefixUrl = 'youtube:$url';
  if (Platform.isIOS) {
    if (await canLaunch(youtubePrefixUrl)) {
      await launch(youtubePrefixUrl, forceSafariVC: false);
    } else {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }
  } else {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
