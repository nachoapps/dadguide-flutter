import 'package:dadguide2/components/auth/src/user.dart';
import 'package:dadguide2/components/auth/ui.dart';
import 'package:dadguide2/components/auth/user.dart';
import 'package:dadguide2/components/config/service_locator.dart';
import 'package:dadguide2/components/config/settings_manager.dart';
import 'package:dadguide2/components/firebase/src/ads.dart';
import 'package:dadguide2/components/notifications/notifications.dart';
import 'package:dadguide2/components/utils/app_reloader.dart';
import 'package:dadguide2/components/utils/email.dart';
import 'package:dadguide2/components/utils/streams.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:dadguide2/screens/settings/async_switch_preference.dart';
import 'package:dadguide2/screens/settings/preference_title_subtitle.dart';
import 'package:dadguide2/services/api.dart';
import 'package:dadguide2/theme/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fimber/flutter_fimber.dart';
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
      child: ListView(children: [
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
          onChange: (v) => Provider.of<ReloadAppChangeNotifier>(context, listen: false).notify(),
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
          onChange: () => getIt<NotificationManager>().ensureEventsScheduled(),
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
          onChange: () => Provider.of<ReloadAppChangeNotifier>(context, listen: false).notify(),
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
        PreferenceTitle(loc.settingsNotificationsSection),
        PreferenceTitleSubtitle(loc.settingsNotificationsDesc),
        CheckboxPreference(
          loc.settingsNotificationsEnabled,
          PrefKeys.notificationsAlertsEnabled,
          onChange: () => getIt<NotificationManager>().ensureEventsScheduled(),
        ),
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
        PreferenceTitle('Sign In'),
        SimpleRxStreamBuilder<DgUser>(
          stream: UserManager.instance.stream,
          builder: (context, user) {
            return AsyncSwitchPreference(
              'Ads enabled',
              PrefKeys.adsEnabled,
              onEnable: () async {
                AdStatusManager.instance.enableAds();
                // Give the enable a second to propagate to prevent orphaned banners.
                await Future.delayed(Duration(seconds: 1));
              },
              onDisable: () async {
                var scaffold = Scaffold.of(context);
                var key = Key('ads_switch');
                try {
                  var isDonor =
                      await getIt<ApiClient>().isDonor(user.email).timeout(Duration(seconds: 5));
                  scaffold.hideCurrentSnackBar();
                  if (isDonor) {
                    AdStatusManager.instance.disableAds();
                  } else {
                    scaffold.showSnackBar(SnackBar(key: key, content: Text('Not a donor')));
                  }
                } catch (ex, st) {
                  scaffold.hideCurrentSnackBar();
                  Fimber.e('Failed to contact server', ex: ex, stacktrace: st);
                  throw StateError('Failed to contact server');
                }
              },
              disabled: !user.loggedIn,
            );
          },
        ),
        PreferenceTitleSubtitle(
            'If you have donated and are signed in with the same email, ads will be removed from the app. Thanks for your support!'),
        SimpleRxStreamBuilder<DgUser>(
          stream: UserManager.instance.stream,
          builder: (context, user) {
            if (!user.loggedIn) return Container();
            return ListTile(
              trailing: Text(user.email),
              leading: Text('Logged in as'),
            );
          },
        ),
        Center(child: SignInAndOutButton()),
      ]),
    );
  }
}

var _codeContributors = <String>[
  'tactical_retreat',
  'droon',
  'Ardeaf',
  'davenger',
  'ケート (cate)',
  'chu',
  'Watonii',
  'jbills',
  'PGGB',
  'ChalupaPapa',
  'Raijinili',
];

var _dataContributors = <String>[
  'unmoogical',
  'fether',
  'LucinaFanBoy',
  '코카트리스',
  'Digity',
  'Estina',
  'fluff',
  'kevynn',
  'SenseiRock',
];

var _artContributors = <String>[
  'Violebot',
];
