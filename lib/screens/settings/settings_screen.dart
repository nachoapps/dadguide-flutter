import 'package:dadguide2/screens/settings/settings_manager.dart';
import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PreferencePage([
      PreferenceTitle('General'),
      DropdownPreference(
        'Info language',
        'info_language',
        defaultVal: langPrefValues[1],
        values: langPrefValues,
        displayValues: langPrefDisplayValues,
      ),
      PreferenceTitle('Events'),
      CheckboxPreference('Hide closed events', 'events_hide_closed'),
      CheckboxPreference('Show red starter', 'events_show_red'),
      CheckboxPreference('Show blue starter', 'events_show_blue'),
      CheckboxPreference('Show green starter', 'events_show_green'),
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
