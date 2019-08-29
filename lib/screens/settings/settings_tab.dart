import 'package:dadguide2/components/settings_manager.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';

/// Displays user-configurable settings, and some misc items like copyright/contact etc.
class SettingsScreen extends StatelessWidget {
  SettingsScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);

    return PreferencePage([
      Container(
        color: Colors.blue,
        height: 36,
        child: Center(child: Text(loc.settingsTitle)),
      ),
      PreferenceTitle(loc.settingsGeneralSection),
      DropdownPreference(
        loc.settingsUiLanguage,
        PrefKeys.uiLanguage,
        defaultVal: Prefs.defaultUiLanguageValue,
        values: Prefs.languageValues,
        displayValues: Prefs.languageDisplayValues,
      ),
      DropdownPreference(
        loc.settingsInfoLanguage,
        PrefKeys.infoLanguage,
        defaultVal: Prefs.defaultInfoLanguageValue,
        values: Prefs.languageValues,
        displayValues: Prefs.languageDisplayValues,
      ),
      DropdownPreference(
        loc.settingsGameCountry,
        PrefKeys.gameCountry,
        defaultVal: Prefs.defaultGameCountryValue,
        values: Prefs.countryValues,
        displayValues: Prefs.countryDisplayValues,
      ),
      PreferenceTitle(loc.settingsEventsSection),
      DropdownPreference(
        loc.settingsEventCountry,
        PrefKeys.eventCountry,
        defaultVal: Prefs.defaultEventCountryValue,
        values: Prefs.countryValues,
        displayValues: Prefs.countryDisplayValues,
      ),
      CheckboxPreference(loc.settingsEventsHideClosed, PrefKeys.eventsHideClosed),
      CheckboxPreference(loc.settingsEventsStarterRed, PrefKeys.eventsShowRed),
      CheckboxPreference(loc.settingsEventsStarterBlue, PrefKeys.eventsShowBlue),
      CheckboxPreference(loc.settingsEventsStarterGreen, PrefKeys.eventsShowGreen),
      PreferenceTitle(loc.settingsInfoSection),
      ListTile(
        title: Text(loc.settingsContactUs),
        trailing: Icon(Icons.keyboard_arrow_right),
        onTap: () {
          print('tapped');
        },
      ),
      PreferencePageLink(
        loc.settingsAbout,
        trailing: Icon(Icons.keyboard_arrow_right),
        page: PreferencePage([
          PreferenceText('Some about text'),
        ]),
      ),
      PreferenceDialogLink(
        loc.settingsCopyright,
        trailing: Icon(Icons.keyboard_arrow_right),
        dialog: PreferenceDialog(
          [
            PreferenceText('Some copyright text'),
          ],
          submitText: loc.close,
        ),
      ),
    ]);
  }
}
