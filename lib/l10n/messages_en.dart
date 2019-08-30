// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// ignore_for_file: unnecessary_brace_in_string_interps

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

// ignore: unnecessary_new
final messages = new MessageLookup();

// ignore: unused_element
final _keepAnalysisHappy = Intl.defaultLocale;

// ignore: non_constant_identifier_names
typedef MessageIfAbsent(String message_str, List args);

class MessageLookup extends MessageLookupByLibrary {
  get localeName => 'en';

  static m0(floor) => "Floor ${floor}";

  static m1(floors) => "Floors: ${floors}";

  static m2(coinPerStam) => "Coin/Stam:${coinPerStam}";

  static m3(expPerStam) => "Exp/Stam:${expPerStam}";

  static m4(stamina) => "Stamina: ${stamina}";

  static m5(days) => "${days} Days";

  static m6(number) => "Cost ${number}";

  static m7(number) => "ATK ${number}";

  static m8(number) => "HP ${number}";

  static m9(number) => "RCV ${number}";

  static m10(date) => "[${date}] Added";

  static m11(number) => "No. ${number}";

  static m12(seriesName) => "Series - ${seriesName}";

  static m13(max) => "Lv.MAX Turn : ${max}";

  static m14(max, min, levels) => "Lv.1 Turn : ${max} (Lv.${levels} Turn: ${min})";

  static m15(number) => "ATK ${number}";

  static m16(number) => "HP ${number}";

  static m17(number) => "Lv. ${number}";

  static m18(number) => "Limit Break: ${number}%";

  static m19(number) => "MP ${number}";

  static m20(number) => "No. ${number}";

  static m21(number) => "RCV ${number}";

  static m22(number) => "WT ${number}";

  static m23(mp, mpPerStam) => "${mp} (${mpPerStam} / Stamina)";

  static m24(index, taskCount) => "Executing task (${index}/${taskCount}";

  static m25(index, taskCount) => "Task ${index} of ${taskCount} failed";

  static m26(percent) => "${percent}%";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "avg" : MessageLookupByLibrary.simpleMessage("Avg"),
    "avgPerStam" : MessageLookupByLibrary.simpleMessage("Avg/Stam"),
    "battleCommon" : MessageLookupByLibrary.simpleMessage("Common Monsters"),
    "battleDrop" : MessageLookupByLibrary.simpleMessage("Drop"),
    "battleFloor" : m0,
    "battleInvades" : MessageLookupByLibrary.simpleMessage("Invades"),
    "close" : MessageLookupByLibrary.simpleMessage("Close"),
    "coin" : MessageLookupByLibrary.simpleMessage("Coin"),
    "dataSync" : MessageLookupByLibrary.simpleMessage("Data Sync"),
    "dungeonFloors" : m1,
    "dungeonListCoinPerStam" : m2,
    "dungeonListExpPerStam" : m3,
    "dungeonSearchHint" : MessageLookupByLibrary.simpleMessage("Search: Dungeon name"),
    "dungeonStamina" : m4,
    "dungeonTabMultiRank" : MessageLookupByLibrary.simpleMessage("Multi/Rank"),
    "dungeonTabNormal" : MessageLookupByLibrary.simpleMessage("Normal"),
    "dungeonTabSpecial" : MessageLookupByLibrary.simpleMessage("Special"),
    "dungeonTabTechnical" : MessageLookupByLibrary.simpleMessage("Technical"),
    "eventClosed" : MessageLookupByLibrary.simpleMessage("Closed"),
    "eventDays" : m5,
    "eventTabAll" : MessageLookupByLibrary.simpleMessage("All"),
    "eventTabGuerrilla" : MessageLookupByLibrary.simpleMessage("Guerrilla"),
    "eventTabNews" : MessageLookupByLibrary.simpleMessage("News"),
    "eventTabSpecial" : MessageLookupByLibrary.simpleMessage("Special"),
    "exampleYtVideos" : MessageLookupByLibrary.simpleMessage("Example team compositions and dungeon clears"),
    "exp" : MessageLookupByLibrary.simpleMessage("Exp"),
    "max" : MessageLookupByLibrary.simpleMessage("Max"),
    "min" : MessageLookupByLibrary.simpleMessage("Min"),
    "monsterInfo297Awoken" : MessageLookupByLibrary.simpleMessage("+297 & fully awoken"),
    "monsterInfoActiveSkillTitle" : MessageLookupByLibrary.simpleMessage("Skill:"),
    "monsterInfoAtk" : MessageLookupByLibrary.simpleMessage("ATK"),
    "monsterInfoAvailableKillers" : MessageLookupByLibrary.simpleMessage("Available Killer Awoken"),
    "monsterInfoAwokenSkillSection" : MessageLookupByLibrary.simpleMessage("Awoken Skills"),
    "monsterInfoCost" : m6,
    "monsterInfoDropsTitle" : MessageLookupByLibrary.simpleMessage("Drop Dungeons"),
    "monsterInfoDropsTitleNone" : MessageLookupByLibrary.simpleMessage("Drop Dungeons: None"),
    "monsterInfoEvoDiffAtk" : m7,
    "monsterInfoEvoDiffHp" : m8,
    "monsterInfoEvoDiffRcv" : m9,
    "monsterInfoEvolution" : MessageLookupByLibrary.simpleMessage("Evolution"),
    "monsterInfoExp" : MessageLookupByLibrary.simpleMessage("EXP"),
    "monsterInfoHistoryAdded" : m10,
    "monsterInfoHistoryTitle" : MessageLookupByLibrary.simpleMessage("History"),
    "monsterInfoHp" : MessageLookupByLibrary.simpleMessage("HP"),
    "monsterInfoLeaderSkillTitle" : MessageLookupByLibrary.simpleMessage("Leader skill:"),
    "monsterInfoLevel" : MessageLookupByLibrary.simpleMessage("Lv."),
    "monsterInfoNo" : m11,
    "monsterInfoNonReversableEvolution" : MessageLookupByLibrary.simpleMessage("Non-Reversable Evolution"),
    "monsterInfoRcv" : MessageLookupByLibrary.simpleMessage("RCV"),
    "monsterInfoReversableEvolution" : MessageLookupByLibrary.simpleMessage("Reversable Evolution"),
    "monsterInfoSeriesHeader" : m12,
    "monsterInfoShield" : MessageLookupByLibrary.simpleMessage("Reduce Dmg."),
    "monsterInfoSkillMaxed" : m13,
    "monsterInfoSkillTurns" : m14,
    "monsterInfoSkillupDungeonsTitle" : MessageLookupByLibrary.simpleMessage("Skill Up - Dungeon"),
    "monsterInfoSkillupTitle" : MessageLookupByLibrary.simpleMessage("Skill Up - Monster"),
    "monsterInfoStatBonus" : MessageLookupByLibrary.simpleMessage("Stat bonus when assisting"),
    "monsterInfoSuperAwokenSkillSection" : MessageLookupByLibrary.simpleMessage("Super Awoken Skills"),
    "monsterInfoTableBuyMp" : MessageLookupByLibrary.simpleMessage("Buy MP"),
    "monsterInfoTableFeedXp" : MessageLookupByLibrary.simpleMessage("Feed XP"),
    "monsterInfoTableFeedXpOnColor" : MessageLookupByLibrary.simpleMessage("Feed XP\n(on color)"),
    "monsterInfoTableInfoMaxLevel" : MessageLookupByLibrary.simpleMessage("At max level"),
    "monsterInfoTableSellGold" : MessageLookupByLibrary.simpleMessage("Sell Gold"),
    "monsterInfoTableSellMp" : MessageLookupByLibrary.simpleMessage("Sell MP"),
    "monsterInfoWeighted" : MessageLookupByLibrary.simpleMessage("Weighted"),
    "monsterListAtk" : m15,
    "monsterListHp" : m16,
    "monsterListLevel" : m17,
    "monsterListLimitBreak" : m18,
    "monsterListMp" : m19,
    "monsterListNo" : m20,
    "monsterListRcv" : m21,
    "monsterListWeighted" : m22,
    "mpAndMpPerStam" : m23,
    "noData" : MessageLookupByLibrary.simpleMessage("No Data"),
    "onboardingDisplayLanguage" : MessageLookupByLibrary.simpleMessage("Display Language"),
    "onboardingDisplayLanguageDesc" : MessageLookupByLibrary.simpleMessage("Applies to UI elements and PAD data"),
    "onboardingDownloadDb" : MessageLookupByLibrary.simpleMessage("Downloading initial data"),
    "onboardingDownloadImages" : MessageLookupByLibrary.simpleMessage("Downloading icon set"),
    "onboardingGameCountry" : MessageLookupByLibrary.simpleMessage("Game Country"),
    "onboardingGameCountryDesc" : MessageLookupByLibrary.simpleMessage("Sets your default events, news, and data alerts"),
    "onboardingTitle" : MessageLookupByLibrary.simpleMessage("First-launch setup"),
    "onboardingUnpackDb" : MessageLookupByLibrary.simpleMessage("Unpacking initial data"),
    "onboardingUnpackImages" : MessageLookupByLibrary.simpleMessage("Unpacking icon set"),
    "onboardingWaitingSubTitle" : MessageLookupByLibrary.simpleMessage("You can change these value later in the settings tab"),
    "onboardingWaitingTitle" : MessageLookupByLibrary.simpleMessage("While you\'re waiting..."),
    "reportBadInfo" : MessageLookupByLibrary.simpleMessage("Report incorrect information"),
    "serverModalTitle" : MessageLookupByLibrary.simpleMessage("Server"),
    "settingsAbout" : MessageLookupByLibrary.simpleMessage("About"),
    "settingsContactUs" : MessageLookupByLibrary.simpleMessage("Contact us"),
    "settingsCopyright" : MessageLookupByLibrary.simpleMessage("Copyright"),
    "settingsEventCountry" : MessageLookupByLibrary.simpleMessage("Event Country"),
    "settingsEventsHideClosed" : MessageLookupByLibrary.simpleMessage("Hide closed events"),
    "settingsEventsSection" : MessageLookupByLibrary.simpleMessage("Events"),
    "settingsEventsStarterBlue" : MessageLookupByLibrary.simpleMessage("Show blue starter"),
    "settingsEventsStarterGreen" : MessageLookupByLibrary.simpleMessage("Show green starter"),
    "settingsEventsStarterRed" : MessageLookupByLibrary.simpleMessage("Show red starter"),
    "settingsGameCountry" : MessageLookupByLibrary.simpleMessage("Game Country"),
    "settingsGeneralSection" : MessageLookupByLibrary.simpleMessage("General"),
    "settingsInfoLanguage" : MessageLookupByLibrary.simpleMessage("Info Language"),
    "settingsInfoSection" : MessageLookupByLibrary.simpleMessage("Info"),
    "settingsTitle" : MessageLookupByLibrary.simpleMessage("Settings"),
    "settingsUiLanguage" : MessageLookupByLibrary.simpleMessage("UI Langauge"),
    "subDungeonSelectionTitle" : MessageLookupByLibrary.simpleMessage("Select Difficulty"),
    "taskExecuting" : MessageLookupByLibrary.simpleMessage("Executing task"),
    "taskExecutingWithCount" : m24,
    "taskFailedWithCount" : m25,
    "taskFatalError" : MessageLookupByLibrary.simpleMessage("Fatal error occurred; try restarting the app"),
    "taskFinished" : MessageLookupByLibrary.simpleMessage("All tasks complete"),
    "taskProgress" : m26,
    "taskRestarting" : MessageLookupByLibrary.simpleMessage("Check your internet connection.\nAutomatically restarting"),
    "taskWaiting" : MessageLookupByLibrary.simpleMessage("Waiting to start tasks"),
    "title" : MessageLookupByLibrary.simpleMessage("DadGuide"),
    "updateComplete" : MessageLookupByLibrary.simpleMessage("Update complete"),
    "updateFailed" : MessageLookupByLibrary.simpleMessage("Update failed"),
    "updateModalTitle" : MessageLookupByLibrary.simpleMessage("Updating DadGuide data"),
    "ytLaunchError" : MessageLookupByLibrary.simpleMessage("Failed to launch YouTube")
  };
}
