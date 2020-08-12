import 'package:dadguide2/components/firebase/remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fimber/flutter_fimber.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class AnnouncementPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (RemoteConfigWrapper.announcement.isEmpty) {
      return Container();
    }
    return ExpansionTile(
      title: Text('Announcement', style: TextStyle(fontWeight: FontWeight.bold)),
      children: [
        Markdown(
          data: RemoteConfigWrapper.announcement,
          onTapLink: quietLaunchUrl,
          shrinkWrap: true,
        ),
      ],
    );
  }
}

Future<void> quietLaunchUrl(String url) async {
  try {
    await launch(url);
  } catch (ex) {
    Fimber.e('Failed to launch link', ex: ex);
  }
}
