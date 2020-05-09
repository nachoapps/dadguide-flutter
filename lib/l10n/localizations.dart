import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'messages_all.dart';

/// This is the current globally loaded localization. This is a terrible hack and not the right way
/// to handle this, but it's irritatingly difficult to get ahold of a BuildContext everywhere you
/// need it. This starts off null and is reloaded whenever the app localization is.
DadGuideLocalizations localized;

class DadGuideLocalizations {
  // ---- Strings used by DadGuide ----
  String get title => Intl.message('DadGuide', name: 'title', desc: 'The application title');

  String get tabEvent =>
      Intl.message('Events', name: 'tabEvent', desc: 'Bottom tab title for events');

  String get tabMonster =>
      Intl.message('Monsters', name: 'tabMonster', desc: 'Bottom tab title for monster list');

  String get tabDungeon =>
      Intl.message('Dungeons', name: 'tabDungeon', desc: 'Bottom tab title for dungeon list');

  String get tabSetting =>
      Intl.message('Settings', name: 'tabSetting', desc: 'Bottom tab title for settings');

  String get languageEn =>
      Intl.message('English', name: 'languageEn', desc: 'Used in language selector');

  String get languageJa =>
      Intl.message('Japanese', name: 'languageJa', desc: 'Used in language selector');

  String get languageKo =>
      Intl.message('Korean', name: 'languageKo', desc: 'Used in language selector');

  String get countryNa =>
      Intl.message('North America', name: 'countryNa', desc: 'Used in server selector');

  String get countryJp => Intl.message('Japan', name: 'countryJp', desc: 'Used in server selector');

  String get countryKr => Intl.message('Korea', name: 'countryKr', desc: 'Used in server selector');

  // ---- Strings used by update process ----
  String get updateComplete => Intl.message('Update complete',
      name: 'updateComplete', desc: 'Snackbar displayed when data update finishes');

  String get updateFailed => Intl.message('Update failed',
      name: 'updateFailed', desc: 'Snackbar displayed when data update fails');

  String get updateFailedTooOld => Intl.message('DadGuide needs to update',
      name: 'updateFailedTooOld', desc: 'Snackbar displayed when the app is out of date');

  // ---- Strings used by task execution widget ----
  String taskExecutingWithCount(int index, int taskCount) => Intl.message(
        'Executing task ($index/$taskCount)',
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
  String get coin => Intl.message('Coins', name: 'coin', desc: 'Table header');

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

  String get warning => Intl.message('Warning', name: 'warning', desc: 'Title for alert dialogs');

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
  String get monsterListSearchText => Intl.message('Search: Monster Name/No.',
      name: 'monsterListSearchText', desc: 'Hint text inside search box');

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

  // ---- Monster filter modal strings ----
  String get monsterFilterModalTitle => Intl.message('Advanced Search',
      name: 'monsterFilterModalTitle', desc: 'Title for monster filter modal');

  String get monsterFilterModalMainAttr =>
      Intl.message('Main Attr', name: 'monsterFilterModalMainAttr', desc: 'Section header');

  String get monsterFilterModalSubAttr =>
      Intl.message('Sub Attr', name: 'monsterFilterModalSubAttr', desc: 'Section header');

  String get monsterFilterModalRarity =>
      Intl.message('Rarity', name: 'monsterFilterModalRarity', desc: 'Section header');

  String get monsterFilterModalCost =>
      Intl.message('Cost', name: 'monsterFilterModalCost', desc: 'Section header');

  String get monsterFilterModalType =>
      Intl.message('Type', name: 'monsterFilterModalType', desc: 'Section header');

  String get monsterFilterModalSeries =>
      Intl.message('Series', name: 'monsterFilterModalSeries', desc: 'Section header');

  String get monsterFilterModalActiveSkills =>
      Intl.message('Active Skills', name: 'monsterFilterModalActiveSkills', desc: 'Section header');

  String get monsterFilterModalLeaderSkills =>
      Intl.message('Leader Skills', name: 'monsterFilterModalLeaderSkills', desc: 'Section header');

  String get monsterFilterModalAwokens =>
      Intl.message('Awoken Skills', name: 'monsterFilterModalAwokens', desc: 'Section header');

  String get monsterFilterModalClose =>
      Intl.message('Close', name: 'monsterFilterModalClose', desc: 'Bottom button');

  String get monsterFilterModalReset =>
      Intl.message('Reset', name: 'monsterFilterModalReset', desc: 'Bottom button');

  // ---- Monster sort modal strings ----
  String get monsterSortModalTitle => Intl.message('Change Sort Order',
      name: 'monsterSortModalTitle', desc: 'Title for monster sort modal');

  String get monsterSortDesc =>
      Intl.message('Descending ▼', name: 'monsterSortDesc', desc: 'Top button');

  String get monsterSortAsc =>
      Intl.message('Ascending ▲', name: 'monsterSortAsc', desc: 'Top button');

  String monsterSortTypeNumber() =>
      Intl.message('No.', name: 'monsterSortTypeNumber', desc: 'Grid button');

  String monsterSortTypeAtk() =>
      Intl.message('ATK', name: 'monsterSortTypeAtk', desc: 'Grid button');

  String monsterSortTypeHp() => Intl.message('HP', name: 'monsterSortTypeHp', desc: 'Grid button');

  String monsterSortTypeRcv() =>
      Intl.message('RCV', name: 'monsterSortTypeRcv', desc: 'Grid button');

  String monsterSortTypeWeighted() =>
      Intl.message('Total', name: 'monsterSortTypeWeighted', desc: 'Grid button');

  String monsterSortTypeLimitBrokenWeighted() =>
      Intl.message('LB Total', name: 'monsterSortTypeLimitBrokenWeighted', desc: 'Grid button');

  String monsterSortTypeAttr() =>
      Intl.message('Attribute', name: 'monsterSortTypeAttr', desc: 'Grid button');

  String monsterSortTypeSubAttr() =>
      Intl.message('Sub Att.', name: 'monsterSortTypeSubAttr', desc: 'Grid button');

  String monsterSortTypeType() =>
      Intl.message('Type', name: 'monsterSortTypeType', desc: 'Grid button');

  String monsterSortTypeRarity() =>
      Intl.message('Rarity', name: 'monsterSortTypeRarity', desc: 'Grid button');

  String monsterSortTypeCost() =>
      Intl.message('Cost', name: 'monsterSortTypeCost', desc: 'Grid button');

  String monsterSortTypeMp() => Intl.message('MP', name: 'monsterSortTypeMp', desc: 'Grid button');

  String monsterSortTypeSkillTurn() =>
      Intl.message('Skill Turn', name: 'monsterSortTypeSkillTurn', desc: 'Grid button');

  String monsterSortTypeLeaderSkillHp() =>
      Intl.message('LS Hp', name: 'monsterSortTypeLeaderSkillHp', desc: 'Grid button');

  String monsterSortTypeLeaderSkillAttack() =>
      Intl.message('LS Atk', name: 'monsterSortTypeLeaderSkillAttack', desc: 'Grid button');

  String monsterSortTypeLeaderSkillRcv() =>
      Intl.message('LS Rcv', name: 'monsterSortTypeLeaderSkillRcv', desc: 'Grid button');

  String monsterSortTypeLeaderSkillShield() =>
      Intl.message('LS Shield', name: 'monsterSortTypeLeaderSkillShield', desc: 'Grid button');

  // ---- Monster info strings ----
  String monsterInfoNo(int number) => Intl.message(
        'No. $number',
        name: 'monsterInfoNo',
        args: [number],
        desc: 'Monster info number text',
      );

  String get monsterInfo297Awoken => Intl.message('+297 & fully awoken',
      name: 'monsterInfo297Awoken', desc: 'Text above the 297+awoken table');

  String get monsterInfoStatBonus => Intl.message('Stat bonus when assisting (+297)',
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

  String get monsterInfoSkillupDungeonTitleNone => Intl.message('Skill Up - Dungeon: None',
      name: 'monsterInfoSkillupDungeonTitleNone',
      desc: 'Header for skill up dungeon section when there are no drops');

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

  String get monsterInfoMaterialForHeader => Intl.message('Material for',
      name: 'monsterInfoMaterialForHeader', desc: 'Material for icons section header');

  String get monsterInfoEvolution =>
      Intl.message('Evolution', name: 'monsterInfoEvolution', desc: 'Evo section header');

  String get monsterInfoReversableEvolution => Intl.message('Reversable Evolution',
      name: 'monsterInfoReversableEvolution', desc: 'Evo section header');

  String get monsterInfoNonReversableEvolution => Intl.message('Non-Reversable Evolution',
      name: 'monsterInfoNonReversableEvolution', desc: 'Evo section header');

  String get monsterInfoTransformationEvolution => Intl.message('Transformations',
      name: 'monsterInfoTransformationEvolution', desc: 'Evo section header');

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

  String get monsterMediaWarningBody => Intl.message(
      'Animations are large (> 5MB). Viewing 10 animations takes'
      ' more data than the rest of the app combined. If you are concerned about'
      ' data usage, make sure you are on WiFi.',
      name: 'monsterMediaWarningBody',
      desc: 'Body text for the warning popup about data usage');

  String get monsterMediaImage => Intl.message('Image',
      name: 'monsterMediaImage', desc: 'Toggle text below monster image for media selection');

  String get monsterMediaVideo => Intl.message('Video',
      name: 'monsterMediaVideo', desc: 'Toggle text below monster image for media selection');

  String get monsterMediaOrbs => Intl.message('Orbs',
      name: 'monsterMediaOrbs', desc: 'Toggle text below monster image for media selection');

  String get monsterMediaJPVoice => Intl.message('JP Voice',
      name: 'monsterMediaJPVoice', desc: 'Toggle text below monster image for media selection');

  String get monsterMediaNAVoice => Intl.message('NA Voice',
      name: 'monsterMediaNAVoice', desc: 'Toggle text below monster image for media selection');

  // ---- Onboarding strings ----
  String get onboardingTitle => Intl.message('First-launch setup',
      name: 'onboardingTitle', desc: 'Header for onboarding page');

  String get onboardingWaitingTitle => Intl.message('While you\'re waiting...',
      name: 'onboardingWaitingTitle', desc: 'Title above the locale selection stuff');

  String get onboardingWaitingSubTitle =>
      Intl.message('You can change these values later in the settings tab',
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

  // ---- Upgrading database strings ----
  String get upgradingDbTitle => Intl.message('Database upgrade',
      name: 'upgradingDbTitle', desc: 'Header for post-update database upgrade');

  String get upgradingInfoTitle => Intl.message('Downloading and installing a database update',
      name: 'upgradingInfoTitle', desc: 'Title above the upgrade explanation');

  String get upgradingInfoText => Intl.message(
      'Some updates introduce incompatible database changes.'
      ' When this occurs, you need to download a replacement with the new data.'
      ' This contains about 20MB of data; sorry for the inconvenience.',
      name: 'upgradingInfoText',
      desc: 'Body text of the upgrade screen');

  // ---- Settings strings ----
  String get settingsTitle =>
      Intl.message('Settings', name: 'settingsTitle', desc: 'Title of settings page');

  String get settingsGeneralSection =>
      Intl.message('General', name: 'settingsGeneralSection', desc: 'Section header');

  String get settingsUiLanguage =>
      Intl.message('UI Langauge', name: 'settingsUiLanguage', desc: 'Dropdown option title');

  String get settingsUiLanguageDesc => Intl.message('Overwrites your device locale',
      name: 'settingsUiLanguageDesc', desc: 'Setting description');

  String get settingsInfoLanguage =>
      Intl.message('Info Language', name: 'settingsInfoLanguage', desc: 'Dropdown option title');

  String get settingsInfoLanguageDesc =>
      Intl.message('Used for monster/dungeon names, skill text, etc',
          name: 'settingsInfoLanguageDesc', desc: 'Setting description');

  String get settingsGameCountry =>
      Intl.message('Game Country', name: 'settingsGameCountry', desc: 'Dropdown option title');

  String get settingsGameCountryDesc => Intl.message('Controls some other region-specific settings',
      name: 'settingsGameCountryDesc', desc: 'Setting description');

  String get settingsEventsSection =>
      Intl.message('Events', name: 'settingsEventsSection', desc: 'Section header');

  String get settingsEventCountry =>
      Intl.message('Event Country', name: 'settingsEventCountry', desc: 'Dropdown option title');

  String get settingsEventCountryDesc => Intl.message('Server to display guerrilla events for',
      name: 'settingsEventCountryDesc', desc: 'Setting description');

  String get settingsDarkMode =>
      Intl.message('Dark Mode', name: 'settingsDarkMode', desc: 'Checkbox title');

  String get settingsHideUnreleasedMonsters => Intl.message('Hide unreleased monsters',
      name: 'settingsHideUnreleasedMonsters', desc: 'Checkbox title');

  String get settingsHideUnreleasedMonstersDesc =>
      Intl.message('Hides monsters that are not released for the selected Game Country',
          name: 'settingsHideUnreleasedMonstersDesc', desc: 'Setting description');

  String get settingsEventsHideClosed =>
      Intl.message('Hide closed events', name: 'settingsEventsHideClosed', desc: 'Checkbox title');

  String get settingsEventsStarterRed =>
      Intl.message('Show red starter', name: 'settingsEventsStarterRed', desc: 'Checkbox title');

  String get settingsEventsStarterBlue =>
      Intl.message('Show blue starter', name: 'settingsEventsStarterBlue', desc: 'Checkbox title');

  String get settingsEventsStarterGreen => Intl.message('Show green starter',
      name: 'settingsEventsStarterGreen', desc: 'Checkbox title');

  String get settingsNotificationsSection =>
      Intl.message('Notifications', name: 'settingsNotificationsSection', desc: 'Section title');

  String get settingsNotificationsDesc => Intl.message(
      'Alert when a dungeon opens. Long-press on an event or dungeon to toggle tracking.',
      name: 'settingsNotificationsDesc',
      desc: 'Section description');

  String get settingsNotificationsEnabled =>
      Intl.message('Enable alerts', name: 'settingsNotificationsEnabled', desc: 'Checkbox title');

  String get settingsInfoSection =>
      Intl.message('Info', name: 'settingsInfoSection', desc: 'Section header');

  String get settingsContactUs =>
      Intl.message('Contact us', name: 'settingsContactUs', desc: 'Row label');

  String get settingsAbout => Intl.message('About', name: 'settingsAbout', desc: 'Row label');

  String get settingsCopyright =>
      Intl.message('Copyright', name: 'settingsCopyright', desc: 'Row label');

  // ---- Monster type strings ----
  String get typeEvoMat => Intl.message('Evo Material', name: 'typeEvoMat', desc: 'Monster type');
  String get typeBalanced => Intl.message('Balanced', name: 'typeBalanced', desc: 'Monster type');
  String get typePhysical => Intl.message('Physical', name: 'typePhysical', desc: 'Monster type');
  String get typeHealer => Intl.message('Healer', name: 'typeHealer', desc: 'Monster type');
  String get typeDragon => Intl.message('Dragon', name: 'typeDragon', desc: 'Monster type');
  String get typeGod => Intl.message('God', name: 'typeGod', desc: 'Monster type');
  String get typeAttacker => Intl.message('Attacker', name: 'typeAttacker', desc: 'Monster type');
  String get typeDevil => Intl.message('Devil', name: 'typeDevil', desc: 'Monster type');
  String get typeMachine => Intl.message('Machine', name: 'typeMachine', desc: 'Monster type');
  String get typeEnhance => Intl.message('Enhance', name: 'typeEnhance', desc: 'Monster type');
  String get typeAwoken => Intl.message('Awoken', name: 'typeAwoken', desc: 'Monster type');
  String get typeVendor => Intl.message('Vendor', name: 'typeVendor', desc: 'Monster type');

  // ---- Enemy behavior ----

  // ---- Group types ----
  String get esGroupOnDeath =>
      Intl.message('On death', name: 'esGroupOnDeath', desc: 'Enemy behavior group title');
  String get esGroupPlayerBuff => Intl.message('When player has buff',
      name: 'esGroupPlayerBuff', desc: 'Enemy behavior group title');
  String get esGroupEnemyDebuff => Intl.message('When monster delayed/poisoned',
      name: 'esGroupEnemyDebuff', desc: 'Enemy behavior group title');
  String get esGroupAbilities =>
      Intl.message('Abilities', name: 'esGroupAbilities', desc: 'Enemy behavior group title');
  String get esGroupPreemptive =>
      Intl.message('Preemptive', name: 'esGroupPreemptive', desc: 'Enemy behavior group title');
  String get esGroupStandard =>
      Intl.message('Standard', name: 'esGroupStandard', desc: 'Enemy behavior group title');
  String get esGroupUnknownUse =>
      Intl.message('Unknown usage', name: 'esGroupUnknownUse', desc: 'Enemy behavior group title');
  String get esGroupUnknown =>
      Intl.message('Unknown', name: 'esGroupUnknown', desc: 'Enemy behavior group title');
  String get esGroupError =>
      Intl.message('<error>', name: 'esGroupError', desc: 'Enemy behavior group title');

  // ---- Conditions ----
  String esCondUseChance(int number) => Intl.message(
        '$number% chance',
        name: 'esCondUseChance',
        args: [number],
        desc: 'Condition text (group or behavior)',
      );

  String esCondLimitedExecution(int number) => Intl.message(
        'At most $number times',
        name: 'esCondLimitedExecution',
        args: [number],
        desc: 'Condition text (group or behavior)',
      );

  String get esCondOneTimeOnly => Intl.message('One time only',
      name: 'esCondOneTimeOnly', desc: 'Condition text (group or behavior)');

  String get esCondOneEnemiesRemaining => Intl.message('When alone',
      name: 'esCondOneEnemiesRemaining', desc: 'Condition text (group or behavior)');

  String esCondMultipleEnemiesRemaining(int number) => Intl.message(
        'When <=$number enemies',
        name: 'esCondMultipleEnemiesRemaining',
        args: [number],
        desc: 'Condition text (group or behavior)',
      );

  String get esCondDefeated => Intl.message('When defeated',
      name: 'esCondDefeated', desc: 'Condition text (group or behavior)');

  String get esCondAttributesAvailable => Intl.message('Requires specific attributes',
      name: 'esCondAttributesAvailable', desc: 'Condition text (group or behavior)');

  String esCondTriggerMonsters(String monsters) => Intl.message(
        'When [$monsters] on team',
        name: 'esCondTriggerMonsters',
        args: [monsters],
        examples: const {'monsters': '245, 1113'},
        desc: 'Condition text (group or behavior)',
      );

  String esCondTriggerCombos(int number) => Intl.message(
        'When $number combos last turn',
        name: 'esCondTriggerCombos',
        args: [number],
        desc: 'Condition text (group or behavior)',
      );

  String get esCondNothingMatched => Intl.message('If no other skills matched',
      name: 'esCondNothingMatched', desc: 'Condition text (group or behavior)');

  String esCondTriggerAfter(String skillName) => Intl.message(
        'Always use after $skillName',
        name: 'esCondTriggerAfter',
        args: [skillName],
        examples: const {'skillName': 'Some Monster Skill'},
        desc: 'Condition text (group or behavior)',
      );

  String esCondRepeating3(int start, int end, int total) => Intl.message(
        'Repeating, turns $start-$end of $total',
        name: 'esCondRepeating3',
        args: [start, end, total],
        desc: 'Condition text (group or behavior)',
      );

  String esCondRepeating2(int start, int total) => Intl.message(
        'Repeating, turns $start of $total',
        name: 'esCondRepeating2',
        args: [start, total],
        desc: 'Condition text (group or behavior)',
      );

  String esCondRepeating1(int total) => Intl.message(
        'Repeats every $total turns',
        name: 'esCondRepeating1',
        args: [total],
        desc: 'Condition text (group or behavior)',
      );

  String esCondTurnsRange(int start, int end) => Intl.message(
        'turns $start-$end',
        name: 'esCondTurnsRange',
        args: [start, end],
        desc: 'Condition text (group or behavior)',
      );

  String esCondTurnsExact(int start) => Intl.message(
        'turn $start',
        name: 'esCondTurnsExact',
        args: [start],
        desc: 'Condition text (group or behavior)',
      );

  String esCondAlwaysOnTurn(String turnText) => Intl.message(
        'always on $turnText',
        name: 'esCondAlwaysOnTurn',
        args: [turnText],
        desc: 'Condition text (group or behavior)',
      );

  String esCondWhileAboveHp(String turnText, int alwaysTriggerAbove) => Intl.message(
        '$turnText while above $alwaysTriggerAbove HP',
        name: 'esCondWhileAboveHp',
        args: [turnText, alwaysTriggerAbove],
        desc: 'Condition text (group or behavior)',
      );

  String get esCondHpFull => Intl.message('When HP is full',
      name: 'esCondHpFull', desc: 'Condition text (group or behavior)');

  String esCondHpLt(int threshold) => Intl.message(
        'HP < $threshold',
        name: 'esCondHpLt',
        args: [threshold],
        desc: 'Condition text (group or behavior)',
      );

  String esCondHpLtEq(int threshold) => Intl.message(
        'HP <= $threshold',
        name: 'esCondHpLtEq',
        args: [threshold],
        desc: 'Condition text (group or behavior)',
      );

  String get esCondPartJoin =>
      Intl.message(', ', name: 'esCondPartJoin', desc: 'Token used to join condition text');

  // ---- Other ----
  String get esNotReviewedWarning =>
      Intl.message("This monster's behavior not yet reviewed. Rely on it at your own risk.",
          name: 'esNotReviewedWarning', desc: 'Error text');

  String esAttackText(String hits, String damage) => Intl.message(
        'Attack $hits times for $damage damage',
        name: 'esAttackText',
        args: [hits, damage],
        examples: const {'hits': '1-5', 'damage': '200-5,100'},
        desc: 'Text below a skill that describes the attack',
      );

  // ---- Exchange view ----
  String exchangeNumberOf(int requiredCount) => Intl.message(
        '$requiredCount of',
        name: 'exchangeNumberOf',
        args: [requiredCount],
        desc: 'Exchange view, required for trade text',
      );

  String exchangeRequires(int requiredCount) => Intl.message(
        'Requires $requiredCount for trade',
        name: 'exchangeRequires',
        args: [requiredCount],
        desc: 'Exchange view popup title',
      );

  // ---- Egg machine view ----
  String get eggMachineNoInfo =>
      Intl.message('Rates and monsters only available after the machine opens',
          name: 'eggMachineNoInfo',
          desc: 'Displayed in place of the rates/contents before a machine opens');

  // ---- Tracking widgets ----
  String get trackingTrackedItemText => Intl.message('Tracking',
      name: 'trackingTrackedItemText',
      desc: 'Text used to identify dungeons that are being tracked for notifications');

  String get trackingPopupStartTrackingText => Intl.message('Alert when dungeon is available.',
      name: 'trackingPopupStartTrackingText',
      desc: 'Popup text when long-pressing a dungeon that can be tracked');

  String get trackingPopupStopTrackingText => Intl.message('Stop tracking this dungeon',
      name: 'trackingPopupStopTrackingText',
      desc: 'Popup text when long-pressing a dungeon that is already tracked');

  // ---- Monster compare ----
  String get monsterCompareTitle => Intl.message('Compare Monster',
      name: 'monsterCompareTitle', desc: 'Text in the compare screen title bar');

  String monsterCompareStatsSectionTitle(int compareRarity) => Intl.message(
        'Stats (vs > $compareRarity⭐)',
        name: 'monsterCompareStatsSectionTitle',
        args: [compareRarity],
        desc: 'Exchange view popup title',
      );
  String get monsterCompareAwokenSectionTitle => Intl.message('Awoken Skills',
      name: 'monsterCompareAwokenSectionTitle', desc: 'Grey bar section text in compare screen');
  String get monsterCompareActiveSectionTitle => Intl.message('Active Skill',
      name: 'monsterCompareActiveSectionTitle', desc: 'Grey bar section text in compare screen');
  String get monsterCompareLeaderSectionTitle => Intl.message('Leader Skill',
      name: 'monsterCompareLeaderSectionTitle', desc: 'Grey bar section text in compare screen');

  String get monsterCompareSelectLeft => Intl.message('Select left',
      name: 'monsterCompareSelectLeft', desc: 'Button text at bottom of compare screen');
  String get monsterCompareSelectRight => Intl.message('Select right',
      name: 'monsterCompareSelectRight', desc: 'Button text at bottom of compare screen');

  // ---- Changelog ----
  String get changelogButton => Intl.message('Continue',
      name: 'changelogButton', desc: 'Button text at bottom of changelog that dismisses');

  String get changelogTitle =>
      Intl.message("What's New", name: 'changelogTitle', desc: 'Text at top of changelog');

  // ---- Screenshots ----
  String get screenshotFinished => Intl.message('Screenshot saved to gallery',
      name: 'screenshotFinished', desc: 'Snackbar after screenshot taken');

  String get screenshotFailed => Intl.message('Failed to save (access denied?)',
      name: 'screenshotFailed', desc: 'Snackbar after screenshot taken');

  // ---- IAP ----
  String get iapTitle =>
      Intl.message('Purchases', name: 'iapTitle', desc: 'Settings page iap section title');
  String get iapSubtitle => Intl.message('Click below to purchase permanent ad removal',
      name: 'iapSubtitle', desc: 'Settings page iap section subtitle');

  String get iapRestoreTitle => Intl.message('Restore existing purchase',
      name: 'iapRestoreTitle', desc: 'Settings page iap section title');
  String get iapRestoreSubtitle => Intl.message(
      'If you have purchased ad removal on a different device, click here to restore it',
      name: 'iapRestoreSubtitle',
      desc: 'Settings page iap section subtitle');
  String get iapRestoreError => Intl.message('No purchase found',
      name: 'iapRestoreError', desc: 'Snackbar on restore failure');

  String get iapAdsRemoved =>
      Intl.message('Ads removed', name: 'iapAdsRemoved', desc: 'IAP after purchase text');

  String get iapAdsRemovedSubtitle => Intl.message('Thanks for supporting DadGuide!',
      name: 'iapAdsRemovedSubtitle', desc: 'IAP after purchase text');

  String get iapLaunchFailed =>
      Intl.message('Failed to start purchase', name: 'iapLaunchFailed', desc: 'Error snackbar');

  // ---- Everything below here is boilerplate that doesn't matter to a translator ----

  static Future<DadGuideLocalizations> load(Locale locale) {
    final String languageCode = locale?.languageCode ?? 'xx';
    final String name = locale.countryCode == null ? languageCode : locale.toString();
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
    var languageCode = locale?.languageCode ?? 'xx';
    return ['en', 'ja', 'ko'].contains(languageCode);
  }

  @override
  Future<DadGuideLocalizations> load(Locale locale) {
    return DadGuideLocalizations.load(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<DadGuideLocalizations> old) => false;
}
