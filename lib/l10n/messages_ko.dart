// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ko locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'ko';

  static m0(floor) => "층 ${floor}";

  static m1(floors) => "배틀 : ${floors}";

  static m2(coinPerStam) => "코인 효율: ${coinPerStam}";

  static m3(expPerStam) => "경험치 효율 : ${expPerStam}";

  static m4(stamina) => "스태미너 : ${stamina}";

  static m5(days) => "${days} 일";

  static m6(number) => "비용 ${number}";

  static m7(number) => "공격력 ${number}";

  static m8(number) => "HP ${number}";

  static m9(number) => "회복 ${number}";

  static m10(date) => "[ ${date} ] 추가";

  static m11(number) => "No. ${number}";

  static m12(seriesName) => "시리즈- ${seriesName}";

  static m13(max) => "Lv.MAX 턴 : ${max}";

  static m14(max, min, levels) => "Lv.1 회전 : ${max} (Lv. ${levels} 회전 : ${min} )";

  static m15(number) => "공격 ${number}";

  static m16(number) => "HP ${number}";

  static m17(number) => "Lv. ${number}";

  static m18(number) => "한도 휴식 : ${number} %";

  static m19(number) => "몬스터 포인트 ${number}";

  static m20(number) => "No. ${number}";

  static m21(number) => "회복 ${number}";

  static m22(number) => "무게 ${number}";

  static m23(mp, mpPerStam) => "${mp} ( ${mpPerStam} / 체력)";

  static m24(index, taskCount) => "실행 작업 ( ${index} / ${taskCount} )";

  static m25(index, taskCount) => "${taskCount} 의 작업 ${index} 에 실패했습니다";

  static m26(percent) => "${percent} %";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "avg" : MessageLookupByLibrary.simpleMessage("평균"),
    "avgPerStam" : MessageLookupByLibrary.simpleMessage("평균 / 스탬"),
    "battleCommon" : MessageLookupByLibrary.simpleMessage("일반적인 몬스터"),
    "battleDrop" : MessageLookupByLibrary.simpleMessage("드랍"),
    "battleFloor" : m0,
    "battleInvades" : MessageLookupByLibrary.simpleMessage("난입"),
    "close" : MessageLookupByLibrary.simpleMessage("닫기"),
    "coin" : MessageLookupByLibrary.simpleMessage("코인"),
    "dataSync" : MessageLookupByLibrary.simpleMessage("데이터 동기화"),
    "dungeonFloors" : m1,
    "dungeonListCoinPerStam" : m2,
    "dungeonListExpPerStam" : m3,
    "dungeonSearchHint" : MessageLookupByLibrary.simpleMessage("검색 : 던전 이름"),
    "dungeonStamina" : m4,
    "dungeonTabMultiRank" : MessageLookupByLibrary.simpleMessage("협력/랭킹"),
    "dungeonTabNormal" : MessageLookupByLibrary.simpleMessage("노멀"),
    "dungeonTabSpecial" : MessageLookupByLibrary.simpleMessage("스페셜"),
    "dungeonTabTechnical" : MessageLookupByLibrary.simpleMessage("테크니컬"),
    "eventClosed" : MessageLookupByLibrary.simpleMessage("닫은"),
    "eventDays" : m5,
    "eventTabAll" : MessageLookupByLibrary.simpleMessage("모든"),
    "eventTabGuerrilla" : MessageLookupByLibrary.simpleMessage("게릴라"),
    "eventTabNews" : MessageLookupByLibrary.simpleMessage("뉴스"),
    "eventTabSpecial" : MessageLookupByLibrary.simpleMessage("스페셜"),
    "exampleYtVideos" : MessageLookupByLibrary.simpleMessage("팀과 던전 명확한 예"),
    "exp" : MessageLookupByLibrary.simpleMessage("경험치"),
    "languageEn" : MessageLookupByLibrary.simpleMessage("영어"),
    "languageJa" : MessageLookupByLibrary.simpleMessage("일본어"),
    "languageKo" : MessageLookupByLibrary.simpleMessage("한국어"),
    "max" : MessageLookupByLibrary.simpleMessage("최대"),
    "min" : MessageLookupByLibrary.simpleMessage("최소"),
    "monsterFilterModalAwokens" : MessageLookupByLibrary.simpleMessage("각성스킬"),
    "monsterFilterModalClose" : MessageLookupByLibrary.simpleMessage("닫기"),
    "monsterFilterModalCost" : MessageLookupByLibrary.simpleMessage("코스트"),
    "monsterFilterModalMainAttr" : MessageLookupByLibrary.simpleMessage("주속성"),
    "monsterFilterModalRarity" : MessageLookupByLibrary.simpleMessage("레어도"),
    "monsterFilterModalReset" : MessageLookupByLibrary.simpleMessage("초기화"),
    "monsterFilterModalSubAttr" : MessageLookupByLibrary.simpleMessage("부속성"),
    "monsterFilterModalTitle" : MessageLookupByLibrary.simpleMessage("Advanced Search"),
    "monsterFilterModalType" : MessageLookupByLibrary.simpleMessage("타입"),
    "monsterInfo297Awoken" : MessageLookupByLibrary.simpleMessage("+297 및 완전히 깨어남"),
    "monsterInfoActiveSkillTitle" : MessageLookupByLibrary.simpleMessage("기술:"),
    "monsterInfoAtk" : MessageLookupByLibrary.simpleMessage("공격"),
    "monsterInfoAvailableKillers" : MessageLookupByLibrary.simpleMessage("사용 가능한 킬러"),
    "monsterInfoAwokenSkillSection" : MessageLookupByLibrary.simpleMessage("각성스킬"),
    "monsterInfoCost" : m6,
    "monsterInfoDropsTitle" : MessageLookupByLibrary.simpleMessage("드롭 던전"),
    "monsterInfoDropsTitleNone" : MessageLookupByLibrary.simpleMessage("드롭 던전 : 없음"),
    "monsterInfoEvoDiffAtk" : m7,
    "monsterInfoEvoDiffHp" : m8,
    "monsterInfoEvoDiffRcv" : m9,
    "monsterInfoEvolution" : MessageLookupByLibrary.simpleMessage("진화"),
    "monsterInfoExp" : MessageLookupByLibrary.simpleMessage("경험치"),
    "monsterInfoHistoryAdded" : m10,
    "monsterInfoHistoryTitle" : MessageLookupByLibrary.simpleMessage("역사"),
    "monsterInfoHp" : MessageLookupByLibrary.simpleMessage("HP"),
    "monsterInfoLeaderSkillTitle" : MessageLookupByLibrary.simpleMessage("리더 스킬 :"),
    "monsterInfoLevel" : MessageLookupByLibrary.simpleMessage("Lv."),
    "monsterInfoNo" : m11,
    "monsterInfoNonReversableEvolution" : MessageLookupByLibrary.simpleMessage("돌이킬 수없는 진화"),
    "monsterInfoRcv" : MessageLookupByLibrary.simpleMessage("회복"),
    "monsterInfoReversableEvolution" : MessageLookupByLibrary.simpleMessage("가역적 진화"),
    "monsterInfoSeriesHeader" : m12,
    "monsterInfoShield" : MessageLookupByLibrary.simpleMessage("Dmg을 줄이십시오."),
    "monsterInfoSkillMaxed" : m13,
    "monsterInfoSkillTurns" : m14,
    "monsterInfoSkillupDungeonsTitle" : MessageLookupByLibrary.simpleMessage("스킬 업-던전"),
    "monsterInfoSkillupTitle" : MessageLookupByLibrary.simpleMessage("스킬 업-몬스터"),
    "monsterInfoStatBonus" : MessageLookupByLibrary.simpleMessage("보조 할 때의 스탯 보너스 (+297)"),
    "monsterInfoSuperAwokenSkillSection" : MessageLookupByLibrary.simpleMessage("초각성스킬"),
    "monsterInfoTableBuyMp" : MessageLookupByLibrary.simpleMessage("MP 구매"),
    "monsterInfoTableFeedXp" : MessageLookupByLibrary.simpleMessage("먹이경험치 (타속성)"),
    "monsterInfoTableFeedXpOnColor" : MessageLookupByLibrary.simpleMessage("먹이경험치 (동속성)"),
    "monsterInfoTableInfoMaxLevel" : MessageLookupByLibrary.simpleMessage("최대 수준에서"),
    "monsterInfoTableSellGold" : MessageLookupByLibrary.simpleMessage("금 판매"),
    "monsterInfoTableSellMp" : MessageLookupByLibrary.simpleMessage("MP 판매"),
    "monsterInfoWeighted" : MessageLookupByLibrary.simpleMessage("가중"),
    "monsterListAtk" : m15,
    "monsterListHp" : m16,
    "monsterListLevel" : m17,
    "monsterListLimitBreak" : m18,
    "monsterListMp" : m19,
    "monsterListNo" : m20,
    "monsterListRcv" : m21,
    "monsterListWeighted" : m22,
    "monsterSortAsc" : MessageLookupByLibrary.simpleMessage("Ascending ▲"),
    "monsterSortDesc" : MessageLookupByLibrary.simpleMessage("Descending ▼"),
    "monsterSortModalTitle" : MessageLookupByLibrary.simpleMessage("Change Sort Order"),
    "monsterSortTypeAtk" : MessageLookupByLibrary.simpleMessage("공격"),
    "monsterSortTypeAttr" : MessageLookupByLibrary.simpleMessage("주속성"),
    "monsterSortTypeCost" : MessageLookupByLibrary.simpleMessage("코스트"),
    "monsterSortTypeHp" : MessageLookupByLibrary.simpleMessage("HP"),
    "monsterSortTypeMp" : MessageLookupByLibrary.simpleMessage("MP"),
    "monsterSortTypeNumber" : MessageLookupByLibrary.simpleMessage("No."),
    "monsterSortTypeRarity" : MessageLookupByLibrary.simpleMessage("레어도"),
    "monsterSortTypeRcv" : MessageLookupByLibrary.simpleMessage("회복"),
    "monsterSortTypeSkillTurn" : MessageLookupByLibrary.simpleMessage("Skill Turn"),
    "monsterSortTypeSubAttr" : MessageLookupByLibrary.simpleMessage("부속성"),
    "monsterSortTypeType" : MessageLookupByLibrary.simpleMessage("타입"),
    "monsterSortTypeWeighted" : MessageLookupByLibrary.simpleMessage("환산치"),
    "mpAndMpPerStam" : m23,
    "noData" : MessageLookupByLibrary.simpleMessage("데이터 없음"),
    "onboardingDisplayLanguage" : MessageLookupByLibrary.simpleMessage("표시 언어"),
    "onboardingDisplayLanguageDesc" : MessageLookupByLibrary.simpleMessage("UI 요소 및 PAD 데이터에 적용"),
    "onboardingDownloadDb" : MessageLookupByLibrary.simpleMessage("초기 데이터 다운로드"),
    "onboardingDownloadImages" : MessageLookupByLibrary.simpleMessage("아이콘 세트 다운로드"),
    "onboardingGameCountry" : MessageLookupByLibrary.simpleMessage("게임 국가"),
    "onboardingGameCountryDesc" : MessageLookupByLibrary.simpleMessage("기본 이벤트, 뉴스 및 데이터 알림을 설정합니다"),
    "onboardingTitle" : MessageLookupByLibrary.simpleMessage("최초 실행 설정"),
    "onboardingUnpackDb" : MessageLookupByLibrary.simpleMessage("초기 데이터 포장 풀기"),
    "onboardingUnpackImages" : MessageLookupByLibrary.simpleMessage("포장 풀기 아이콘 세트"),
    "onboardingWaitingSubTitle" : MessageLookupByLibrary.simpleMessage("나중에 설정 탭에서이 값을 변경할 수 있습니다"),
    "onboardingWaitingTitle" : MessageLookupByLibrary.simpleMessage("기다리는 동안 ..."),
    "reportBadInfo" : MessageLookupByLibrary.simpleMessage("잘못된 정보 신고해주새요"),
    "serverModalTitle" : MessageLookupByLibrary.simpleMessage("서버"),
    "settingsAbout" : MessageLookupByLibrary.simpleMessage("약"),
    "settingsContactUs" : MessageLookupByLibrary.simpleMessage("연락주세요"),
    "settingsCopyright" : MessageLookupByLibrary.simpleMessage("저작권"),
    "settingsEventCountry" : MessageLookupByLibrary.simpleMessage("이벤트 국가"),
    "settingsEventCountryDesc" : MessageLookupByLibrary.simpleMessage("Server to display guerrilla events for"),
    "settingsEventsHideClosed" : MessageLookupByLibrary.simpleMessage("비공개 이벤트 숨기기"),
    "settingsEventsSection" : MessageLookupByLibrary.simpleMessage("행사"),
    "settingsEventsStarterBlue" : MessageLookupByLibrary.simpleMessage("파란색 스타터 표시"),
    "settingsEventsStarterGreen" : MessageLookupByLibrary.simpleMessage("녹색 스타터 표시"),
    "settingsEventsStarterRed" : MessageLookupByLibrary.simpleMessage("빨간색 스타터 표시"),
    "settingsGameCountry" : MessageLookupByLibrary.simpleMessage("게임 국가"),
    "settingsGameCountryDesc" : MessageLookupByLibrary.simpleMessage("Controls some other region-specific settings"),
    "settingsGeneralSection" : MessageLookupByLibrary.simpleMessage("일반"),
    "settingsInfoLanguage" : MessageLookupByLibrary.simpleMessage("정보 언어"),
    "settingsInfoLanguageDesc" : MessageLookupByLibrary.simpleMessage("Used for monster/dungeon names, skill text, etc"),
    "settingsInfoSection" : MessageLookupByLibrary.simpleMessage("정보"),
    "settingsTitle" : MessageLookupByLibrary.simpleMessage("설정"),
    "settingsUiLanguage" : MessageLookupByLibrary.simpleMessage("언어 설정"),
    "settingsUiLanguageDesc" : MessageLookupByLibrary.simpleMessage("Overwrites your device locale"),
    "subDungeonSelectionTitle" : MessageLookupByLibrary.simpleMessage("난이도 선택"),
    "tabDungeon" : MessageLookupByLibrary.simpleMessage("던전"),
    "tabEvent" : MessageLookupByLibrary.simpleMessage("이배트"),
    "tabMonster" : MessageLookupByLibrary.simpleMessage("몬스터"),
    "tabSetting" : MessageLookupByLibrary.simpleMessage("설정"),
    "taskExecuting" : MessageLookupByLibrary.simpleMessage("실행 작업"),
    "taskExecutingWithCount" : m24,
    "taskFailedWithCount" : m25,
    "taskFatalError" : MessageLookupByLibrary.simpleMessage("치명적인 오류가 발생했습니다. 앱을 다시 시작해보십시오"),
    "taskFinished" : MessageLookupByLibrary.simpleMessage("모든 작업 완료"),
    "taskProgress" : m26,
    "taskRestarting" : MessageLookupByLibrary.simpleMessage("인터넷 연결을 확인하십시오. 자동 재시작"),
    "taskWaiting" : MessageLookupByLibrary.simpleMessage("작업 시작을 기다리는 중"),
    "title" : MessageLookupByLibrary.simpleMessage("DadGuide"),
    "updateComplete" : MessageLookupByLibrary.simpleMessage("업데이트 완료"),
    "updateFailed" : MessageLookupByLibrary.simpleMessage("업데이트가 실패"),
    "updateModalTitle" : MessageLookupByLibrary.simpleMessage("DadGuide 데이터 업데이트"),
    "ytLaunchError" : MessageLookupByLibrary.simpleMessage("YouTube를 시작하지 못했습니다")
  };
}
