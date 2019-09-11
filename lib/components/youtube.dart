import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

/// Try to launch YT natively, falling back to a browser.
Future<void> launchYouTubeSearch(String query) async {
  var androidUrl = Uri.encodeFull('https://www.youtube.com/results?search_query=$query');
  var iosUrl = Uri.encodeFull('youtube://www.youtube.com/results?search_query=$query');
  if (Platform.isIOS) {
    var launched = false;
    launched = await launch(iosUrl, forceSafariVC: false, universalLinksOnly: true);
    if (!launched) {
      launched = await launch(iosUrl, forceSafariVC: false);
    }
    if (!launched) {
      throw 'Could not launch $iosUrl';
    }
  } else {
    if (!await launch(androidUrl)) {
      throw 'Could not launch $androidUrl';
    }
  }
}
