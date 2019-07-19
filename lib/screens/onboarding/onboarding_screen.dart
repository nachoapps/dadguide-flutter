import 'package:dadguide2/components/settings_manager.dart';
import 'package:dadguide2/components/task_progress.dart';
import 'package:dadguide2/services/onboarding_task.dart';
import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';

class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('DadGuide'),
        ),
        body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'First-launch setup',
                  style: Theme.of(context).textTheme.headline,
                ),
                SizedBox(height: 5),
                Divider(),
                TaskListProgress(onboardingManager.instance),
                SizedBox(height: 5),
                Divider(),
                ListTile(
                  title: Text('While you\'re waiting...'),
                  subtitle: Text('You can change these value later in the settings tab'),
                ),
                DropdownPreference(
                  'Display language',
                  PrefKeys.infoLanguage,
                  desc: 'Applies to UI elements and PAD data',
                  defaultVal: Prefs.defaultUiLanguageValue,
                  values: Prefs.languageValues,
                  displayValues: Prefs.languageDisplayValues,
                  onChange: (v) => Prefs.setAllLanguage(v),
                ),
                DropdownPreference(
                  'Game Country',
                  PrefKeys.gameCountry,
                  desc: 'Sets your default events, news, and data alerts',
                  defaultVal: Prefs.defaultGameCountryValue,
                  values: Prefs.countryValues,
                  displayValues: Prefs.countryDisplayValues,
                  onChange: (v) => Prefs.setAllCountry(v),
                ),
              ],
            )),
      ),
    );
  }
}
