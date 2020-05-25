import 'package:dadguide2/components/firebase/analytics.dart';
import 'package:dadguide2/components/ui/containers.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:dadguide2/theme/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fimber/flutter_fimber.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:screenshot/screenshot.dart';

/// A smaller-than-standard icon button. This is used in top bars mainly.
///
/// It's wrapped with a transparent Material to fix the inkwell, and the size
/// is fixed to 32.
class TrimmedMaterialIconButton extends StatelessWidget {
  // TODO: can we move the padding horizontal 16 in here?
  final IconButton child;
  const TrimmedMaterialIconButton({Key key, @required this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FixInk(
        child: SizedBox(
      height: 32,
      child: child,
    ));
  }
}

/// Divider intended to be used in top-bars
class TopBarDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 32,
        child: VerticalDivider(
          color: grey(context, 1000),
        ));
  }
}

class ScreenshotButton extends StatelessWidget {
  final ScreenshotController controller;

  const ScreenshotButton({Key key, @required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = DadGuideLocalizations.of(context);

    return TrimmedMaterialIconButton(
      child: IconButton(
        padding: EdgeInsets.symmetric(horizontal: 16),
        icon: Icon(FontAwesome.camera),
        onPressed: () async {
          try {
            Fimber.i('Capturing screen');
            var file = await controller.capture();
            Fimber.i('Captured to ${file.path}, saving');
            var saved = await GallerySaver.saveImage(file.path, albumName: 'DadGuide');
            Fimber.i('Saved: $saved');
            screenshotSuccess();
            Scaffold.of(context).showSnackBar(SnackBar(content: Text(loc.screenshotFinished)));
          } catch (ex) {
            Fimber.e('Failed to save screenshot', ex: ex);
            screenshotFailure();
            Scaffold.of(context).showSnackBar(SnackBar(content: Text(loc.screenshotFailed)));
          }
        },
      ),
    );
  }
}
