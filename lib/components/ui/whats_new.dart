import 'package:dadguide2/components/ui/flutter_whatsnew.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fimber/flutter_fimber.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showChangelog(BuildContext context) {
  return Navigator.push(context,
      MaterialPageRoute(builder: (context) => DadGuideChangelog(), fullscreenDialog: true));
}

class DadGuideChangelog extends StatelessWidget {
  static final changelogVersion = 'v16';

  final VoidCallback onButtonPressed;

  const DadGuideChangelog({Key key, this.onButtonPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = DadGuideLocalizations.of(context);

    return WhatsNewPage.changelog(
      forceAndroid: true,
      title: Center(
        child: Text(
          loc.changelogTitle,
          style: Theme.of(context).textTheme.headline5,
        ),
      ),
      onTapLink: (url) async {
        try {
          await launch(url);
        } catch (ex) {
          Fimber.e('Failed to launch link', ex: ex);
        }
      },
      onButtonPressed: onButtonPressed,
      buttonText: Text(loc.changelogButton),
    );
  }
}
