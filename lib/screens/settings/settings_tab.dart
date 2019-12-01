import 'package:dadguide2/components/email.dart';
import 'package:dadguide2/components/settings_manager.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:dadguide2/theme/style.dart';
import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';
import 'package:provider/provider.dart';

/// Displays user-configurable settings, and some misc items like copyright/contact etc.
class SettingsScreen extends StatelessWidget {
  SettingsScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);
    var theme = Theme.of(context).copyWith(
      accentColor: grey(context, 1000),
      unselectedWidgetColor: grey(context, 1000),
      toggleableActiveColor: Colors.lightBlueAccent,
    );

    return Theme(
      data: theme,
      child: PreferencePage([
        Container(
          color: Colors.blue,
          height: 36,
          child: Center(child: Text(loc.settingsTitle)),
        ),
        PreferenceTitle(loc.settingsGeneralSection),
        DropdownPreference(
          loc.settingsUiLanguage,
          PrefKeys.uiLanguage,
          desc: loc.settingsUiLanguageDesc,
          defaultVal: Prefs.defaultUiLanguageValue,
          values: Prefs.languageValues,
          displayValues: Prefs.languageDisplayValues,
          onChange: (v) => Provider.of<LocaleChangedNotifier>(context).notify(),
        ),
        DropdownPreference(
          loc.settingsInfoLanguage,
          PrefKeys.infoLanguage,
          desc: loc.settingsInfoLanguageDesc,
          defaultVal: Prefs.defaultInfoLanguageValue,
          values: Prefs.languageValues,
          displayValues: Prefs.languageDisplayValues,
        ),
        DropdownPreference(
          loc.settingsGameCountry,
          PrefKeys.gameCountry,
          desc: loc.settingsGameCountryDesc,
          defaultVal: Prefs.defaultGameCountryValue,
          values: Prefs.countryValues,
          displayValues: Prefs.countryDisplayValues,
        ),
        CheckboxPreference(
          loc.settingsHideUnreleasedMonsters,
          PrefKeys.hideUnreleasedMonsters,
          desc: loc.settingsHideUnreleasedMonstersDesc,
        ),
        CheckboxPreference(
          loc.settingsDarkMode,
          PrefKeys.uiDarkMode,
          // This is a hack to refresh the app when dark mode changes.
          onChange: () => Provider.of<LocaleChangedNotifier>(context).notify(),
        ),
        PreferenceTitle(loc.settingsEventsSection),
        DropdownPreference(
          loc.settingsEventCountry,
          PrefKeys.eventCountry,
          desc: loc.settingsEventCountryDesc,
          defaultVal: Prefs.defaultEventCountryValue,
          values: Prefs.countryValues,
          displayValues: Prefs.countryDisplayValues,
        ),
        CheckboxPreference(loc.settingsEventsHideClosed, PrefKeys.eventsHideClosed),
        CheckboxPreference(loc.settingsEventsStarterRed, PrefKeys.eventsShowRed),
        CheckboxPreference(loc.settingsEventsStarterBlue, PrefKeys.eventsShowBlue),
        CheckboxPreference(loc.settingsEventsStarterGreen, PrefKeys.eventsShowGreen),
        CheckboxPreference(loc.settingsEventsNotifyNA, PrefKeys.eventsNotifyNA),
        CheckboxPreference(loc.settingsEventsNotifyJP, PrefKeys.eventsNotifyJP),
        CheckboxPreference(loc.settingsEventsNotifyKR, PrefKeys.eventsNotifyKR),
        PreferenceTitle(loc.settingsInfoSection),
        ListTile(
          title: Text(loc.settingsContactUs),
          trailing: Icon(Icons.keyboard_arrow_right),
          onTap: () {
            sendFeedback();
          },
        ),
        PreferencePageLink(
          loc.settingsAbout,
          trailing: Icon(Icons.keyboard_arrow_right),
          page: PreferencePage([
            PreferenceTitle('Code Contributors'),
            PreferenceText(_codeContributors.join('\n')),
            PreferenceTitle('Data and Translations'),
            PreferenceText(_dataContributors.join('\n')),
            PreferenceTitle('Artwork'),
            PreferenceText(_artContributors.join('\n')),
            Divider(),
            PreferenceText(
                'This app is open source and free;\nif you paid for it, you got scammed.'),
            PreferenceText('Copyright © 2019 Miru Apps LLC.\nAll rights reserved'),
          ]),
        ),
      ]),
    );
  }
}

var _codeContributors = <String>[
  'tactical_retreat',
  'Ardeaf',
  'ケート (cate)',
  'chu',
  'Watonii',
  'jbills',
  'PGGB',
  'ChalupaPapa',
  'davenger',
  'Raijinili',
];

var _dataContributors = <String>[
  'unmoogical',
  'fether',
  'LucinaFanBoy',
  '코카트리스',
];

var _artContributors = <String>[
  'Violebot',
];
