import 'package:dadguide2/components/task_progress.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:dadguide2/screens/onboarding/onboarding_task.dart';
import 'package:flutter/material.dart';

/// Displays the post-update database upgrading page.
///
/// Similar to the onboarding screen, fewer tasks, fewer options, more explanation.
class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(title: Text(loc.title)),
        body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.upgradingDbTitle,
                  style: Theme.of(context).textTheme.headline,
                ),
                SizedBox(height: 8),
                Divider(),
                TaskListProgress(onboardingManager.instance),
                SizedBox(height: 5),
                Divider(),
                ListTile(
                  title: Text(loc.upgradingInfoTitle),
                  subtitle: Text(loc.upgradingInfoText),
                ),
              ],
            )),
      ),
    );
  }
}
