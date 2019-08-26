import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'messages_all.dart';

/// This is the current globally loaded localization. This is a terrible hack and not the right way
/// to handle this, but it's iritatingly difficult to get ahold of a BuildContext everywhere you
/// need it. This starts off null and is reloaded whenever the app localization is.
DadGuideLocalizations localized;

class DadGuideLocalizations {
  // ---- Strings used by DadGuide ----
  String get title => Intl.message('DadGuide', name: 'title', desc: 'The application title');

  // ---- Strings used by update process ----
  String get updateComplete => Intl.message('Update complete',
      name: 'updateComplete', desc: 'Snackbar displayed when data update finishes');

  String get updateFailed => Intl.message('Update failed',
      name: 'updateFailed', desc: 'Snackbar displayed when data update fails');

  // ---- Strings used by task execution widget ----
  String taskExecutingWithCount(int index, int taskCount) => Intl.message(
        'Executing task ($index/$taskCount',
        name: 'taskExecutingWithCount',
        args: [index, taskCount],
        desc: 'Indicates task progress',
      );

  String get taskExecuting =>
      Intl.message('Executing task', name: 'taskExecuting', desc: 'Indicates task is running');

  String taskProgress(int percent) => Intl.message('${percent}%',
      name: 'taskProgress', args: [percent], desc: 'Indicates task progress as a percentage');

  String taskFailedWithCount(int index, int taskCount) => Intl.message(
        'Task $index of $taskCount failed',
        name: 'taskFailedWithCount',
        args: [index, taskCount],
        desc: 'Indicates the latest task failed',
      );

  String get taskRestarting =>
      Intl.message('Check your internet connection.\nAutomatically restarting',
          name: 'taskRestarting', desc: 'Indicates task failed and will auto restart');

  String get taskWaiting => Intl.message('Waiting to start tasks',
      name: 'taskWaiting', desc: 'Indicates task is preparing to start');

  String get taskFatalError => Intl.message('Fatal error occurred; try restarting the app',
      name: 'taskFatalError', desc: 'Indicates task failed and will not attempt to restart');

  String get taskFinished => Intl.message('All tasks complete',
      name: 'taskFinished', desc: 'Indicates all tasks are complete');

  // ---- Strings used by onboarding process ----
  String get onboardingDownloadDb => Intl.message('Downloading initial data',
      name: 'onboardingDownloadDb', desc: 'Displayed while the database is downloading');

  String get onboardingUnpackDb => Intl.message('Unpacking initial data',
      name: 'onboardingUnpackDb', desc: 'Displayed while the database is unzipping');

  String get onboardingDownloadImages => Intl.message('Downloading icon set',
      name: 'onboardingDownloadImages', desc: 'Displayed while the icon set is downloading');

  String get onboardingUnpackImages => Intl.message('Unpacking icon set',
      name: 'onboardingUnpackImages', desc: 'Displayed while the icon set is unzipping');

  // ---- Dungeon info strings ----
  String mpPerStam(int mp, double mpPerStam) => Intl.message(
        '$mp (${mpPerStam.toStringAsFixed(1)} / Stamina)',
        name: 'mpPerStam',
        args: [mp, mpPerStam],
        desc: 'Lists the MP and MP/Stam for a dungeon',
      );

  String dungeonStamina(int stamina) => Intl.message(
        'Stamina: $stamina',
        name: 'dungeonStamina',
        args: [stamina],
        desc: 'Lists stamina cost of a dungeon',
      );

  String dungeonFloors(int floors) => Intl.message(
        'Floors: $floors',
        name: 'dungeonFloors',
        args: [floors],
        desc: 'Lists number of floors in a dungeon',
      );

  String get min => Intl.message('Min', name: 'min', desc: 'Table header');
  String get max => Intl.message('Max', name: 'max', desc: 'Table header');
  String get avg => Intl.message('Avg', name: 'avg', desc: 'Table header');
  String get avgPerStam => Intl.message('Avg/Stam', name: 'avgPerStam', desc: 'Table header');
  String get exp => Intl.message('Exp', name: 'exp', desc: 'Table header');
  String get coin => Intl.message('Coin', name: 'coin', desc: 'Table header');

  String get battleDrop =>
      Intl.message('Drop', name: 'battleDrop', desc: 'Label in encounter section');

  String get battleCommon =>
      Intl.message('Common Monsters', name: 'battleCommon', desc: 'Header for encounter section');

  String get battleInvades =>
      Intl.message('Invades', name: 'battleInvades', desc: 'Header for encounter section');

  String battleFloor(int floor) => Intl.message(
        'Floor ${floor}',
        name: 'battleFloor',
        args: [floor],
        desc: 'Header for encounter section',
      );

  // ---- General strings ----
  String get ytLaunchError => Intl.message('Failed to launch YouTube',
      name: 'ytLaunchError', desc: 'Snackbar displayed when launching YT fails');

  String get reportBadInfo => Intl.message('Report incorrect information',
      name: 'reportBadInfo', desc: 'Displayed at the bottom of monster/dungeon info');

  String get noData =>
      Intl.message('No Data', name: 'noData', desc: 'Displayed when a search finds no results');

  String get close => Intl.message('Close', name: 'close', desc: 'Close button text for subviews');

  // ---- Dungeon list strings ----
  String get dungeonSearchHint => Intl.message('Search: Dungeon name',
      name: 'dungeonSearchHint', desc: 'Grey hint text in dungeon search field');

  String get dungeonTabSpecial => Intl.message('Special',
      name: 'dungeonTabSpecial', desc: 'Subtab text at bottom of dungeon tab');
  String get dungeonTabNormal => Intl.message('Normal',
      name: 'dungeonTabNormal', desc: 'Subtab text at bottom of dungeon tab');
  String get dungeonTabTechnical => Intl.message('Technical',
      name: 'dungeonTabTechnical', desc: 'Subtab text at bottom of dungeon tab');
  String get dungeonTabMultiRank => Intl.message('Multi/Rank',
      name: 'dungeonTabMultiRank', desc: 'Subtab text at bottom of dungeon tab');

  // ---- SubDungeon selection strings ----
  String get subDungeonSelectionTitle => Intl.message('Select Difficulty',
      name: 'subDungeonSelectionTitle', desc: 'Title for subdungeon selection view');

  String dungeonListExpPerStam(int expPerStam) => Intl.message(
        'Exp/Stam:$expPerStam',
        name: 'dungeonListExpPerStam',
        args: [expPerStam],
        desc: 'SubDungeon selection info',
      );

  String dungeonListCoinPerStam(int coinPerStam) => Intl.message(
        'Coin/Stam:$coinPerStam',
        name: 'dungeonListCoinPerStam',
        args: [coinPerStam],
        desc: 'SubDungeon selection info',
      );

  //  String get title => Intl.message('DadGuide', name: 'title', desc: 'The application title');

  // ---- Everything below here is boilerplate that doesn't matter to a translator ----

  static Future<DadGuideLocalizations> load(Locale locale) {
    final String name = locale.countryCode == null ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((bool _) {
      Intl.defaultLocale = localeName;
      localized = DadGuideLocalizations();
      return localized;
    });
  }

  static DadGuideLocalizations of(BuildContext context) {
    return Localizations.of<DadGuideLocalizations>(context, DadGuideLocalizations);
  }
}

class DadGuideLocalizationsDelegate extends LocalizationsDelegate<DadGuideLocalizations> {
  const DadGuideLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'jp', 'kr'].contains(locale.languageCode);
  }

  @override
  Future<DadGuideLocalizations> load(Locale locale) {
    return DadGuideLocalizations.load(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<DadGuideLocalizations> old) => false;
}
