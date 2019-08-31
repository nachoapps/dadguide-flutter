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

  String taskProgress(int percent) => Intl.message('$percent%',
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
  String mpAndMpPerStam(int mp, String mpPerStam) => Intl.message(
        '$mp ($mpPerStam / Stamina)',
        name: 'mpAndMpPerStam',
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
        'Floor $floor',
        name: 'battleFloor',
        args: [floor],
        desc: 'Header for encounter section',
      );

  // ---- General strings ----
  String get ytLaunchError => Intl.message('Failed to launch YouTube',
      name: 'ytLaunchError', desc: 'Snackbar displayed when launching YT fails');

  String get reportBadInfo => Intl.message('Report incorrect information',
      name: 'reportBadInfo', desc: 'Displayed at the bottom of monster/dungeon info');

  String get exampleYtVideos => Intl.message('Example team compositions and dungeon clears',
      name: 'exampleYtVideos', desc: 'Displayed at the bottom of monster/dungeon info');

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

  // ---- Event list strings ----
  String get eventClosed =>
      Intl.message('Closed', name: 'eventClosed', desc: 'Displayed below closed event info');

  String eventDays(int days) => Intl.message(
        '$days Days',
        name: 'eventDays',
        args: [days],
        desc: 'Day count and label in event info',
      );

  String get eventTabAll =>
      Intl.message('All', name: 'eventTabAll', desc: 'Subtab text at top of event tab');

  String get eventTabGuerrilla =>
      Intl.message('Guerrilla', name: 'eventTabGuerrilla', desc: 'Subtab text at top of event tab');

  String get eventTabSpecial =>
      Intl.message('Special', name: 'eventTabSpecial', desc: 'Subtab text at top of event tab');

  String get eventTabNews =>
      Intl.message('News', name: 'eventTabNews', desc: 'Subtab text at top of event tab');

  // ---- Event action modal strings ----
  String get serverModalTitle => Intl.message('Server',
      name: 'serverModalTitle', desc: 'Title for select server action modal');

  String get dataSync =>
      Intl.message('Data Sync', name: 'dataSync', desc: 'Button that triggers data syncing');

  // ---- Update action modal strings ----
  String get updateModalTitle => Intl.message('Updating DadGuide data',
      name: 'updateModalTitle', desc: 'Title for update data action modal');

  // ---- Monster list strings ----
  String monsterListNo(int number) => Intl.message(
        'No. $number',
        name: 'monsterListNo',
        args: [number],
        desc: 'Monster list number text',
      );

  String monsterListLevel(int number) => Intl.message(
        'Lv. $number',
        name: 'monsterListLevel',
        args: [number],
        desc: 'Monster list max level text',
      );

  String monsterListHp(int number) => Intl.message(
        'HP $number',
        name: 'monsterListHp',
        args: [number],
        desc: 'Monster list HP text',
      );

  String monsterListAtk(int number) => Intl.message(
        'ATK $number',
        name: 'monsterListAtk',
        args: [number],
        desc: 'Monster list ATK text',
      );

  String monsterListRcv(int number) => Intl.message(
        'RCV $number',
        name: 'monsterListRcv',
        args: [number],
        desc: 'Monster list RCV text',
      );

  String monsterListWeighted(int number) => Intl.message(
        'WT $number',
        name: 'monsterListWeighted',
        args: [number],
        desc: 'Monster list weighted stat text',
      );

  String monsterListLimitBreak(int number) => Intl.message(
        'Limit Break: $number%',
        name: 'monsterListLimitBreak',
        args: [number],
        desc: 'Monster list limit break stat text',
      );

  String monsterListMp(int number) => Intl.message(
        'MP $number',
        name: 'monsterListMp',
        args: [number],
        desc: 'Monster list mp value text',
      );

  // ---- Monster info strings ----
  String monsterInfoNo(int number) => Intl.message(
        'No. $number',
        name: 'monsterInfoNo',
        args: [number],
        desc: 'Monster info number text',
      );

  String get monsterInfo297Awoken => Intl.message('+297 & fully awoken',
      name: 'monsterInfo297Awoken', desc: 'Text above the 297+awoken table');

  String get monsterInfoStatBonus => Intl.message('Stat bonus when assisting',
      name: 'monsterInfoStatBonus', desc: 'Text above the assist bonus table');

  String get monsterInfoAvailableKillers => Intl.message('Available Killer Awoken',
      name: 'monsterInfoAvailableKillers', desc: 'Text above the killer icons');

  String monsterInfoCost(int number) => Intl.message(
        'Cost $number',
        name: 'monsterInfoCost',
        args: [number],
        desc: 'Monster info cost text',
      );

  String get monsterInfoLevel =>
      Intl.message('Lv.', name: 'monsterInfoLevel', desc: 'Header in monster info table');

  String get monsterInfoHp =>
      Intl.message('HP', name: 'monsterInfoHp', desc: 'Header in monster info table');

  String get monsterInfoAtk =>
      Intl.message('ATK', name: 'monsterInfoAtk', desc: 'Header in monster info table');

  String get monsterInfoRcv =>
      Intl.message('RCV', name: 'monsterInfoRcv', desc: 'Header in monster info table');

  String get monsterInfoShield =>
      Intl.message('Reduce Dmg.', name: 'monsterInfoShield', desc: 'Header in monster info table');

  String get monsterInfoExp =>
      Intl.message('EXP', name: 'monsterInfoExp', desc: 'Header in monster info table');

  String get monsterInfoWeighted =>
      Intl.message('Weighted', name: 'monsterInfoWeighted', desc: 'Header in monster info table');

  String monsterInfoSkillMaxed(int max) => Intl.message(
        'Lv.MAX Turn : $max',
        name: 'monsterInfoSkillMaxed',
        args: [max],
        desc: 'Monster info skill text with 0 levels',
      );

  String monsterInfoSkillTurns(int max, int min, int levels) => Intl.message(
        'Lv.1 Turn : $max (Lv.$levels Turn: $min)',
        name: 'monsterInfoSkillTurns',
        args: [max, min, levels],
        desc: 'Monster info skill text with levels',
      );

  String get monsterInfoActiveSkillTitle => Intl.message('Skill:',
      name: 'monsterInfoActiveSkillTitle', desc: 'Header for active skill section');

  String get monsterInfoLeaderSkillTitle => Intl.message('Leader skill:',
      name: 'monsterInfoLeaderSkillTitle', desc: 'Header for leader skill section');

  String get monsterInfoHistoryTitle =>
      Intl.message('History', name: 'monsterInfoHistoryTitle', desc: 'Header for history section');

  String monsterInfoHistoryAdded(String date) => Intl.message(
        '[$date] Added',
        name: 'monsterInfoHistoryAdded',
        args: [date],
        desc: 'Monster info date added text',
      );

  String get monsterInfoSkillupTitle => Intl.message('Skill Up - Monster',
      name: 'monsterInfoSkillupTitle', desc: 'Header for skillups section');

  String get monsterInfoDropsTitle => Intl.message('Drop Dungeons',
      name: 'monsterInfoDropsTitle', desc: 'Header for drops section');

  String get monsterInfoDropsTitleNone => Intl.message('Drop Dungeons: None',
      name: 'monsterInfoDropsTitleNone', desc: 'Header for drops section when there are no drops');

  String get monsterInfoSkillupDungeonsTitle => Intl.message('Skill Up - Dungeon',
      name: 'monsterInfoSkillupDungeonsTitle', desc: 'Header for skillup drop dungeons');

  String get monsterInfoTableInfoMaxLevel => Intl.message('At max level',
      name: 'monsterInfoTableInfoMaxLevel', desc: 'Header column with buy/sell/feed data');

  String get monsterInfoTableSellGold => Intl.message('Sell Gold',
      name: 'monsterInfoTableSellGold', desc: 'Row header for buy/sell/feed data');

  String get monsterInfoTableSellMp => Intl.message('Sell MP',
      name: 'monsterInfoTableSellMp', desc: 'Row header for buy/sell/feed data');

  String get monsterInfoTableBuyMp => Intl.message('Buy MP',
      name: 'monsterInfoTableBuyMp', desc: 'Row header for buy/sell/feed data');

  String get monsterInfoTableFeedXp => Intl.message('Feed XP',
      name: 'monsterInfoTableFeedXp', desc: 'Row header for buy/sell/feed data');

  String get monsterInfoTableFeedXpOnColor => Intl.message('Feed XP\n(on color)',
      name: 'monsterInfoTableFeedXpOnColor', desc: 'Row header for buy/sell/feed data');

  String monsterInfoSeriesHeader(String seriesName) => Intl.message(
        'Series - $seriesName',
        name: 'monsterInfoSeriesHeader',
        args: [seriesName],
        desc: 'Header for series section with icons',
      );

  String get monsterInfoEvolution =>
      Intl.message('Evolution', name: 'monsterInfoEvolution', desc: 'Evo section header');

  String get monsterInfoReversableEvolution => Intl.message('Reversable Evolution',
      name: 'monsterInfoReversableEvolution', desc: 'Evo section header');

  String get monsterInfoNonReversableEvolution => Intl.message('Non-Reversable Evolution',
      name: 'monsterInfoNonReversableEvolution', desc: 'Evo section header');

  String monsterInfoEvoDiffHp(String number) => Intl.message(
        'HP $number',
        name: 'monsterInfoEvoDiffHp',
        args: [number],
        desc: 'Evo stat delta text',
      );

  String monsterInfoEvoDiffAtk(String number) => Intl.message(
        'ATK $number',
        name: 'monsterInfoEvoDiffAtk',
        args: [number],
        desc: 'Evo stat delta text',
      );

  String monsterInfoEvoDiffRcv(String number) => Intl.message(
        'RCV $number',
        name: 'monsterInfoEvoDiffRcv',
        args: [number],
        desc: 'Evo stat delta text',
      );

  String get monsterInfoAwokenSkillSection => Intl.message('Awoken Skills',
      name: 'monsterInfoAwokenSkillSection', desc: 'Header for awoken skills');

  String get monsterInfoSuperAwokenSkillSection => Intl.message('Super Awoken Skills',
      name: 'monsterInfoSuperAwokenSkillSection', desc: 'Header for super awoken skills');

  // ---- Onboarding strings ----
  String get onboardingTitle => Intl.message('First-launch setup',
      name: 'onboardingTitle', desc: 'Header for onboarding page');

  String get onboardingWaitingTitle => Intl.message('While you\'re waiting...',
      name: 'onboardingWaitingTitle', desc: 'Title above the locale selection stuff');

  String get onboardingWaitingSubTitle =>
      Intl.message('You can change these value later in the settings tab',
          name: 'onboardingWaitingSubTitle', desc: 'Subtitle above the locale selection stuff');

  String get onboardingDisplayLanguage => Intl.message('Display Language',
      name: 'onboardingDisplayLanguage', desc: 'Dropdown option title');

  String get onboardingDisplayLanguageDesc => Intl.message('Applies to UI elements and PAD data',
      name: 'onboardingDisplayLanguageDesc', desc: 'Dropdown option subtext');

  String get onboardingGameCountry =>
      Intl.message('Game Country', name: 'onboardingGameCountry', desc: 'Dropdown option title');

  String get onboardingGameCountryDesc =>
      Intl.message('Sets your default events, news, and data alerts',
          name: 'onboardingGameCountryDesc', desc: 'Dropdown option subtext');

  // ---- Settings strings ----
  String get settingsTitle =>
      Intl.message('Settings', name: 'settingsTitle', desc: 'Title of settings page');

  String get settingsGeneralSection =>
      Intl.message('General', name: 'settingsGeneralSection', desc: 'Section header');

  String get settingsUiLanguage =>
      Intl.message('UI Langauge', name: 'settingsUiLanguage', desc: 'Dropdown option title');

  String get settingsInfoLanguage =>
      Intl.message('Info Language', name: 'settingsInfoLanguage', desc: 'Dropdown option title');

  String get settingsGameCountry =>
      Intl.message('Game Country', name: 'settingsGameCountry', desc: 'Dropdown option title');

  String get settingsEventsSection =>
      Intl.message('Events', name: 'settingsEventsSection', desc: 'Section header');

  String get settingsEventCountry =>
      Intl.message('Event Country', name: 'settingsEventCountry', desc: 'Dropdown option title');

  String get settingsEventsHideClosed =>
      Intl.message('Hide closed events', name: 'settingsEventsHideClosed', desc: 'Checkbox title');

  String get settingsEventsStarterRed =>
      Intl.message('Show red starter', name: 'settingsEventsStarterRed', desc: 'Checkbox title');

  String get settingsEventsStarterBlue =>
      Intl.message('Show blue starter', name: 'settingsEventsStarterBlue', desc: 'Checkbox title');

  String get settingsEventsStarterGreen => Intl.message('Show green starter',
      name: 'settingsEventsStarterGreen', desc: 'Checkbox title');

  String get settingsInfoSection =>
      Intl.message('Info', name: 'settingsInfoSection', desc: 'Section header');

  String get settingsContactUs =>
      Intl.message('Contact us', name: 'settingsContactUs', desc: 'Row label');

  String get settingsAbout => Intl.message('About', name: 'settingsAbout', desc: 'Row label');

  String get settingsCopyright =>
      Intl.message('Copyright', name: 'settingsCopyright', desc: 'Row label');

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
    return ['en', 'ja', 'ko'].contains(locale.languageCode);
  }

  @override
  Future<DadGuideLocalizations> load(Locale locale) {
    return DadGuideLocalizations.load(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<DadGuideLocalizations> old) => false;
}
