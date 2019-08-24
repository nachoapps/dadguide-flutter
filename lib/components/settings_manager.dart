import 'dart:ui' as ui;

import 'package:dadguide2/components/enums.dart';
import 'package:flutter_fimber/flutter_fimber.dart';
import 'package:preferences/preferences.dart';
import 'package:tuple/tuple.dart';

/// List of keys for preferences.
class PrefKeys {
  static const currentDbVersion = 'current_db_version';
  static const iconsDownloaded = 'icons_downloaded';
  static const lastUpdateExecution = 'last_update_execution';

  static const uiLanguage = 'ui_language';
  static const infoLanguage = 'info_language';
  static const gameCountry = 'game_country';
  static const eventCountry = 'event_country';

  static const eventsHideClosed = 'events_hide_closed';
  static const eventsShowRed = 'events_show_red';
  static const eventsShowBlue = 'events_show_blue';
  static const eventsShowGreen = 'events_show_green';
}

/// Wrapper for reading and writing preferences.
class Prefs {
  /// The currently selected event country.
  static Country get eventCountry => Country.byId(PrefService.getInt(PrefKeys.eventCountry));
  static set eventCountry(Country country) => PrefService.setInt(PrefKeys.eventCountry, country.id);

  /// A list of the event starters and their selected status.
  static List<StarterDragon> get eventStarters {
    return [
      if (PrefService.getBool(PrefKeys.eventsShowRed)) StarterDragon.red,
      if (PrefService.getBool(PrefKeys.eventsShowBlue)) StarterDragon.blue,
      if (PrefService.getBool(PrefKeys.eventsShowGreen)) StarterDragon.green,
    ];
  }

  /// Should we display events that are closed.
  static bool get eventHideClosed => PrefService.getBool(PrefKeys.eventsHideClosed);

  /// Initialize the pref repo and make sure every preference has a sane default at first launch.
  static Future<void> init() async {
    await PrefService.init();
    PrefService.setDefaultValues({
      PrefKeys.currentDbVersion: 0,
      PrefKeys.iconsDownloaded: false,
      PrefKeys.lastUpdateExecution: 0,
      PrefKeys.uiLanguage: defaultUiLanguageValue,
      PrefKeys.infoLanguage: defaultInfoLanguageValue,
      PrefKeys.gameCountry: defaultGameCountryValue,
      PrefKeys.eventCountry: defaultEventCountryValue,
      PrefKeys.eventsHideClosed: true,
      PrefKeys.eventsShowRed: true,
      PrefKeys.eventsShowBlue: true,
      PrefKeys.eventsShowGreen: true,
    });
  }

  /// Try to determine which country/language to use for the current locale.
  static Tuple2<Language, Country> get _defaultLanguageCountry {
    var locale = ui.window.locale;
    if (locale == null) {
      Fimber.e('Locale was null, defaulting to english/na');
      return Tuple2(Language.en, Country.na);
    } else if (['ja', 'jpx'].contains(locale.languageCode)) {
      return Tuple2(Language.ja, Country.jp);
    } else if (locale.languageCode.startsWith('zh')) {
      return Tuple2(Language.ja, Country.jp);
    } else if (['ko'].contains(locale.languageCode)) {
      return Tuple2(Language.ko, Country.kr);
    } else {
      return Tuple2(Language.en, Country.na);
    }
  }

  static int get defaultUiLanguageValue => _defaultLanguageCountry.item1.id;
  static int get defaultInfoLanguageValue => _defaultLanguageCountry.item1.id;
  static int get defaultGameCountryValue => _defaultLanguageCountry.item2.id;
  static int get defaultEventCountryValue => _defaultLanguageCountry.item2.id;

  static List<int> get languageValues => Language.all.map((l) => l.id).toList();
  static List<String> get languageDisplayValues => Language.all.map((l) => l.languageName).toList();

  static List<int> get countryValues => Country.all.map((l) => l.id).toList();
  static List<String> get countryDisplayValues => Country.all.map((l) => l.countryName).toList();

  static void setCurrentDbVersion(int val) {
    PrefService.setInt(PrefKeys.currentDbVersion, val);
  }

  static void setIconsDownloaded(bool val) {
    PrefService.setBool(PrefKeys.iconsDownloaded, val);
  }

  static void setAllLanguage(int val) {
    PrefService.setInt(PrefKeys.infoLanguage, val);
    PrefService.setInt(PrefKeys.uiLanguage, val);
  }

  static void setAllCountry(int val) {
    PrefService.setInt(PrefKeys.eventCountry, val);
    PrefService.setInt(PrefKeys.gameCountry, val);
  }

  /// Store the current time as the last update time.
  static void updateRan() {
    PrefService.setInt(PrefKeys.lastUpdateExecution, DateTime.now().millisecondsSinceEpoch);
  }

  /// Determine if the update needs to run by comparing the current time against the last run time.
  static bool updateRequired() {
    DateTime lastUpdate =
        DateTime.fromMillisecondsSinceEpoch(PrefService.getInt(PrefKeys.lastUpdateExecution));
    return DateTime.now().difference(lastUpdate).inMinutes > 10;
  }
}
