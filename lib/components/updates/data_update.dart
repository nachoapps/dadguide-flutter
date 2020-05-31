import 'dart:async';

import 'package:dadguide2/components/config/settings_manager.dart';
import 'package:dadguide2/components/firebase/analytics.dart';
import 'package:dadguide2/components/updates/update_service.dart';
import 'package:dadguide2/components/updates/update_state.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:dadguide2/theme/style.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fimber/flutter_fimber.dart';

void flash(BuildContext context, String text) async {
  await showFlash(
      context: context,
      duration: Duration(seconds: 3),
      builder: (_, controller) {
        return Flash.dialog(
          controller: controller,
          backgroundColor: grey(context, 300),
          borderColor: Colors.black,
          onTap: () => controller.dismiss(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(text),
          ),
        );
      });
}

/// Helper wrapper widget that triggers a UI refresh when an update completes.
/// Automatically starts an update if necessary.
class DataUpdaterWidget extends StatefulWidget {
  final Widget child;

  const DataUpdaterWidget(this.child);

  @override
  _DataUpdaterWidgetState createState() => _DataUpdaterWidgetState();
}

class _DataUpdaterWidgetState extends State<DataUpdaterWidget> {
  StreamSubscription<void> _subscription;

  @override
  void initState() {
    super.initState();
    subscribe();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    super.dispose();
    if (_subscription != null) {
      _subscription.cancel();
    }
  }

  void subscribe() {
    var loc = localized;
    _subscription = updateStatusSubject.listen((event) {
      if (event != UpdateStatus.completed) return;
      recordEvent('update_on_ui_open_succeded');
      flash(context, loc.updateComplete);
      setState(() {});
    }, onError: (error) {
      if (error is ApplicationUpdateRequired) {
        Fimber.w('Application update required');
        flash(context, loc.updateFailedTooOld);
      } else {
        Fimber.e('Update failed', ex: error);
        recordEvent('update_on_ui_open_failed');
        flash(context, loc.updateFailed);
      }
    });
    if (Prefs.updateRequired()) {
      Fimber.w('Update is required, triggering');
      recordEvent('update_on_ui_open');
      updateManager.start();
    }
  }
}
