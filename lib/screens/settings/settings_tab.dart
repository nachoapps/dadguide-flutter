import 'package:dadguide2/components/settings_manager.dart';
import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PreferencePage([
      Container(
        color: Colors.blue,
        height: 36,
        child: Center(child: Text('Settings')),
      ),
      PreferenceTitle('General'),
      DropdownPreference(
        'UI language',
        PrefKeys.uiLanguage,
        defaultVal: Prefs.defaultUiLanguageValue,
        values: Prefs.languageValues,
        displayValues: Prefs.languageDisplayValues,
      ),
      DropdownPreference(
        'Info language',
        PrefKeys.infoLanguage,
        defaultVal: Prefs.defaultInfoLanguageValue,
        values: Prefs.languageValues,
        displayValues: Prefs.languageDisplayValues,
      ),
      DropdownPreference(
        'Game Country',
        PrefKeys.gameCountry,
        defaultVal: Prefs.defaultGameCountryValue,
        values: Prefs.countryValues,
        displayValues: Prefs.countryDisplayValues,
      ),
      PreferenceTitle('Events'),
      DropdownPreference(
        'Event Country',
        PrefKeys.eventCountry,
        defaultVal: Prefs.defaultEventCountryValue,
        values: Prefs.countryValues,
        displayValues: Prefs.countryDisplayValues,
      ),
      CheckboxPreference('Hide closed events', PrefKeys.eventsHideClosed),
      CheckboxPreference('Show red starter', PrefKeys.eventsShowRed),
      CheckboxPreference('Show blue starter', PrefKeys.eventsShowBlue),
      CheckboxPreference('Show green starter', PrefKeys.eventsShowGreen),
      PreferenceTitle('Info'),
      ListTile(
        title: Text('Contact us'),
        trailing: Icon(Icons.keyboard_arrow_right),
        onTap: () {
          print('tapped');
        },
      ),
      PreferencePageLink(
        'About',
        trailing: Icon(Icons.keyboard_arrow_right),
        page: PreferencePage([
          PreferenceText('Some about text'),
        ]),
      ),
      PreferenceDialogLink(
        'Copyright',
        trailing: Icon(Icons.keyboard_arrow_right),
        dialog: PreferenceDialog(
          [
            PreferenceText('Some copyright text'),
          ],
          submitText: 'Close',
        ),
      ),
    ]);
  }
}
