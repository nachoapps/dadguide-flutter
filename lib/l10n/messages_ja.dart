// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ja locale. All the
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
  String get localeName => 'ja';

  static m0(floor) => "フロア${floor}";

  static m1(floors) => "フロア： ${floors}";

  static m2(coinPerStam) => "毎ｽﾀﾐﾅコイン ： ${coinPerStam}";

  static m3(expPerStam) => "毎ｽﾀﾐﾅ経験値： ${expPerStam}";

  static m4(stamina) => "スタミナ： ${stamina}";

  static m5(hits, damage) => "連続攻撃${hits}回、計${damage}ダメージ";

  static m6(turnText) => "${turnText}に必ず使用";

  static m7(threshold) => "HP < ${threshold}";

  static m8(threshold) => "HP <= ${threshold}";

  static m9(number) => "最大 ${number} 回";

  static m10(number) => "残り ${number} 体以下になる";

  static m11(total) => "${total}ターンごとに繰り返す";

  static m12(start, total) => "繰り返し、${total}ターン目の${start}";

  static m13(start, end, total) => "繰り返し、${total}の${start}-${end}番目のターン";

  static m14(skillName) => "${skillName} 使用した後に必ず使用する";

  static m15(number) => "直前が ${number} コンボの場合";

  static m16(monsters) => "[${monsters}] がチームにいると";

  static m17(start) => "${start}ターン目";

  static m18(start, end) => "${start}-${end}ターン目";

  static m19(number) => "${number}%の確率で";

  static m20(turnText, alwaysTriggerAbove) => "HP > ${alwaysTriggerAbove}、${turnText}";

  static m21(days) => "${days}日";

  static m22(requiredCount) => "${requiredCount}の";

  static m23(requiredCount) => "交換には${requiredCount}体が必要";

  static m24(number) => "ｺｽﾄ ${number}";

  static m25(number) => "攻撃力 ${number}";

  static m26(number) => "HP ${number}";

  static m27(number) => "回復力 ${number}";

  static m28(date) => "[ ${date} ]に追加";

  static m29(number) => "No. ${number}";

  static m30(seriesName) => "シリーズ： ${seriesName}";

  static m31(max) => "ｽｷﾙLv. MAX ターン： ${max}";

  static m32(max, min, levels) => "Lv.1ターン：${max} (Lv. ${levels}ターン： ${min})";

  static m33(number) => "攻撃力 ${number}";

  static m34(number) => "HP ${number}";

  static m35(number) => "レベル ${number}";

  static m36(number) => "限界突破： ${number} ％";

  static m37(number) => "ﾓﾝﾎﾟ ${number}";

  static m38(number) => "No. ${number}";

  static m39(number) => "回復力 ${number}";

  static m40(number) => "ﾌﾟﾗｽ ${number}";

  static m41(mp, mpPerStam) => "${mp}(${mpPerStam}／スタミナ)";

  static m42(index, taskCount) => "タスク(${index} / ${taskCount})実行中";

  static m43(index, taskCount) => "タスク ${index} / ${taskCount} が失敗しました";

  static m44(percent) => "${percent} ％";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "avg" : MessageLookupByLibrary.simpleMessage("平均"),
    "avgPerStam" : MessageLookupByLibrary.simpleMessage("毎ｽﾀﾐﾅ"),
    "battleCommon" : MessageLookupByLibrary.simpleMessage("道中のモンスター"),
    "battleDrop" : MessageLookupByLibrary.simpleMessage("ドロップ"),
    "battleFloor" : m0,
    "battleInvades" : MessageLookupByLibrary.simpleMessage("まれに出現"),
    "close" : MessageLookupByLibrary.simpleMessage("閉じる"),
    "coin" : MessageLookupByLibrary.simpleMessage("コイン"),
    "countryJp" : MessageLookupByLibrary.simpleMessage("日本"),
    "countryKr" : MessageLookupByLibrary.simpleMessage("韓国"),
    "countryNa" : MessageLookupByLibrary.simpleMessage("北米"),
    "dataSync" : MessageLookupByLibrary.simpleMessage("データ同期"),
    "dungeonFloors" : m1,
    "dungeonListCoinPerStam" : m2,
    "dungeonListExpPerStam" : m3,
    "dungeonSearchHint" : MessageLookupByLibrary.simpleMessage("検索：ダンジョン名"),
    "dungeonStamina" : m4,
    "dungeonTabMultiRank" : MessageLookupByLibrary.simpleMessage("マルチ/ランク"),
    "dungeonTabNormal" : MessageLookupByLibrary.simpleMessage("普通"),
    "dungeonTabSpecial" : MessageLookupByLibrary.simpleMessage("特殊"),
    "dungeonTabTechnical" : MessageLookupByLibrary.simpleMessage("テクニカル"),
    "eggMachineNoInfo" : MessageLookupByLibrary.simpleMessage("確率とモンスターはイベント開始後にのみ表示可能"),
    "esAttackText" : m5,
    "esCondAlwaysOnTurn" : m6,
    "esCondAttributesAvailable" : MessageLookupByLibrary.simpleMessage("特定の属性が必要"),
    "esCondDefeated" : MessageLookupByLibrary.simpleMessage("死亡のとき"),
    "esCondHpFull" : MessageLookupByLibrary.simpleMessage("HP 100%"),
    "esCondHpLt" : m7,
    "esCondHpLtEq" : m8,
    "esCondLimitedExecution" : m9,
    "esCondMultipleEnemiesRemaining" : m10,
    "esCondNothingMatched" : MessageLookupByLibrary.simpleMessage("条件一致する行動がない場合"),
    "esCondOneEnemiesRemaining" : MessageLookupByLibrary.simpleMessage("1体だけになる"),
    "esCondOneTimeOnly" : MessageLookupByLibrary.simpleMessage("一度だけ"),
    "esCondPartJoin" : MessageLookupByLibrary.simpleMessage("、"),
    "esCondRepeating1" : m11,
    "esCondRepeating2" : m12,
    "esCondRepeating3" : m13,
    "esCondTriggerAfter" : m14,
    "esCondTriggerCombos" : m15,
    "esCondTriggerMonsters" : m16,
    "esCondTurnsExact" : m17,
    "esCondTurnsRange" : m18,
    "esCondUseChance" : m19,
    "esCondWhileAboveHp" : m20,
    "esGroupAbilities" : MessageLookupByLibrary.simpleMessage("アビリティ"),
    "esGroupEnemyDebuff" : MessageLookupByLibrary.simpleMessage("遅延・毒の効果をかかっているの場合"),
    "esGroupError" : MessageLookupByLibrary.simpleMessage("<エラー>"),
    "esGroupOnDeath" : MessageLookupByLibrary.simpleMessage("死亡のとき"),
    "esGroupPlayerBuff" : MessageLookupByLibrary.simpleMessage("プレイヤーにかかっているスキル効果がありの場合"),
    "esGroupPreemptive" : MessageLookupByLibrary.simpleMessage("先制"),
    "esGroupStandard" : MessageLookupByLibrary.simpleMessage("一般"),
    "esGroupUnknown" : MessageLookupByLibrary.simpleMessage("不明"),
    "esGroupUnknownUse" : MessageLookupByLibrary.simpleMessage("使用条件は不明"),
    "esNotReviewedWarning" : MessageLookupByLibrary.simpleMessage("このモンスターの行動はまだ確認されていません。\n自己責任において使用してください。"),
    "eventClosed" : MessageLookupByLibrary.simpleMessage("終了しました"),
    "eventDays" : m21,
    "eventTabAll" : MessageLookupByLibrary.simpleMessage("すべて"),
    "eventTabGuerrilla" : MessageLookupByLibrary.simpleMessage("ゲリラ"),
    "eventTabNews" : MessageLookupByLibrary.simpleMessage("ニュース"),
    "eventTabSpecial" : MessageLookupByLibrary.simpleMessage("特殊"),
    "exampleYtVideos" : MessageLookupByLibrary.simpleMessage("ダンジョンクリアのチーム構成の例"),
    "exchangeNumberOf" : m22,
    "exchangeRequires" : m23,
    "exp" : MessageLookupByLibrary.simpleMessage("経験値"),
    "languageEn" : MessageLookupByLibrary.simpleMessage("英語"),
    "languageJa" : MessageLookupByLibrary.simpleMessage("日本語"),
    "languageKo" : MessageLookupByLibrary.simpleMessage("韓国語"),
    "max" : MessageLookupByLibrary.simpleMessage("最高"),
    "min" : MessageLookupByLibrary.simpleMessage("最低"),
    "monsterFilterModalActiveSkills" : MessageLookupByLibrary.simpleMessage("スキル"),
    "monsterFilterModalAwokens" : MessageLookupByLibrary.simpleMessage("覚醒スキル"),
    "monsterFilterModalClose" : MessageLookupByLibrary.simpleMessage("終了"),
    "monsterFilterModalCost" : MessageLookupByLibrary.simpleMessage("コスト"),
    "monsterFilterModalLeaderSkills" : MessageLookupByLibrary.simpleMessage("リーダースキル"),
    "monsterFilterModalMainAttr" : MessageLookupByLibrary.simpleMessage("主属性"),
    "monsterFilterModalRarity" : MessageLookupByLibrary.simpleMessage("レアリティ"),
    "monsterFilterModalReset" : MessageLookupByLibrary.simpleMessage("リセット"),
    "monsterFilterModalSeries" : MessageLookupByLibrary.simpleMessage("シリーズ"),
    "monsterFilterModalSubAttr" : MessageLookupByLibrary.simpleMessage("副属性"),
    "monsterFilterModalTitle" : MessageLookupByLibrary.simpleMessage("詳細検索"),
    "monsterFilterModalType" : MessageLookupByLibrary.simpleMessage("タイプ"),
    "monsterInfo297Awoken" : MessageLookupByLibrary.simpleMessage("+297＆フル覚醒"),
    "monsterInfoActiveSkillTitle" : MessageLookupByLibrary.simpleMessage("スキル："),
    "monsterInfoAtk" : MessageLookupByLibrary.simpleMessage("攻撃力"),
    "monsterInfoAvailableKillers" : MessageLookupByLibrary.simpleMessage("利用可能な潜在キラー"),
    "monsterInfoAwokenSkillSection" : MessageLookupByLibrary.simpleMessage("覚醒スキル"),
    "monsterInfoCost" : m24,
    "monsterInfoDropsTitle" : MessageLookupByLibrary.simpleMessage("ドロップしたダンジョン"),
    "monsterInfoDropsTitleNone" : MessageLookupByLibrary.simpleMessage("ドロップしたダンジョン：なし"),
    "monsterInfoEvoDiffAtk" : m25,
    "monsterInfoEvoDiffHp" : m26,
    "monsterInfoEvoDiffRcv" : m27,
    "monsterInfoEvolution" : MessageLookupByLibrary.simpleMessage("進化"),
    "monsterInfoExp" : MessageLookupByLibrary.simpleMessage("経験値"),
    "monsterInfoHistoryAdded" : m28,
    "monsterInfoHistoryTitle" : MessageLookupByLibrary.simpleMessage("歴史"),
    "monsterInfoHp" : MessageLookupByLibrary.simpleMessage("HP"),
    "monsterInfoLeaderSkillTitle" : MessageLookupByLibrary.simpleMessage("リーダースキル："),
    "monsterInfoLevel" : MessageLookupByLibrary.simpleMessage("ﾚﾍﾞﾙ"),
    "monsterInfoMaterialForHeader" : MessageLookupByLibrary.simpleMessage("進化素材"),
    "monsterInfoNo" : m29,
    "monsterInfoNonReversableEvolution" : MessageLookupByLibrary.simpleMessage("非可逆進化"),
    "monsterInfoRcv" : MessageLookupByLibrary.simpleMessage("回復力"),
    "monsterInfoReversableEvolution" : MessageLookupByLibrary.simpleMessage("可逆進化"),
    "monsterInfoSeriesHeader" : m30,
    "monsterInfoShield" : MessageLookupByLibrary.simpleMessage("ダメージ軽減率"),
    "monsterInfoSkillMaxed" : m31,
    "monsterInfoSkillTurns" : m32,
    "monsterInfoSkillupDungeonTitleNone" : MessageLookupByLibrary.simpleMessage("スキルアップダンジョン：なし"),
    "monsterInfoSkillupDungeonsTitle" : MessageLookupByLibrary.simpleMessage("スキルアップダンジョン"),
    "monsterInfoSkillupTitle" : MessageLookupByLibrary.simpleMessage("スキルアップモンスター"),
    "monsterInfoStatBonus" : MessageLookupByLibrary.simpleMessage("アシストによるステータスボーナス (+297)"),
    "monsterInfoSuperAwokenSkillSection" : MessageLookupByLibrary.simpleMessage("超覚醒スキル"),
    "monsterInfoTableBuyMp" : MessageLookupByLibrary.simpleMessage("MPを購入"),
    "monsterInfoTableFeedXp" : MessageLookupByLibrary.simpleMessage("合成経験値"),
    "monsterInfoTableFeedXpOnColor" : MessageLookupByLibrary.simpleMessage("合成経験値(同じ属性)"),
    "monsterInfoTableInfoMaxLevel" : MessageLookupByLibrary.simpleMessage("最大レベル"),
    "monsterInfoTableSellGold" : MessageLookupByLibrary.simpleMessage("コインを入手"),
    "monsterInfoTableSellMp" : MessageLookupByLibrary.simpleMessage("MPを入手"),
    "monsterInfoTransformationEvolution" : MessageLookupByLibrary.simpleMessage("Transformations"),
    "monsterInfoWeighted" : MessageLookupByLibrary.simpleMessage("ﾌﾟﾗｽ換算"),
    "monsterListAtk" : m33,
    "monsterListHp" : m34,
    "monsterListLevel" : m35,
    "monsterListLimitBreak" : m36,
    "monsterListMp" : m37,
    "monsterListNo" : m38,
    "monsterListRcv" : m39,
    "monsterListWeighted" : m40,
    "monsterMediaImage" : MessageLookupByLibrary.simpleMessage("画像"),
    "monsterMediaJPVoice" : MessageLookupByLibrary.simpleMessage("日本版のボイス"),
    "monsterMediaNAVoice" : MessageLookupByLibrary.simpleMessage("北米版のボイス"),
    "monsterMediaOrbs" : MessageLookupByLibrary.simpleMessage("ドロップ"),
    "monsterMediaVideo" : MessageLookupByLibrary.simpleMessage("ビデオ"),
    "monsterMediaWarningBody" : MessageLookupByLibrary.simpleMessage("アニメーションのファイルサイズは大きい (> 5MB)。 10個以上のアニメーションを表示するには、アプリの他の部分を合わせたよりも多くのデータが必要です。\nデータ量の使用に不安がある場合は、WiFiを使用していることを確認してください。"),
    "monsterSortAsc" : MessageLookupByLibrary.simpleMessage("昇順 ▲"),
    "monsterSortDesc" : MessageLookupByLibrary.simpleMessage("降順▼"),
    "monsterSortModalTitle" : MessageLookupByLibrary.simpleMessage("ソート順変更"),
    "monsterSortTypeAtk" : MessageLookupByLibrary.simpleMessage("攻撃力"),
    "monsterSortTypeAttr" : MessageLookupByLibrary.simpleMessage("属性"),
    "monsterSortTypeCost" : MessageLookupByLibrary.simpleMessage("コスト"),
    "monsterSortTypeHp" : MessageLookupByLibrary.simpleMessage("HP"),
    "monsterSortTypeLimitBrokenWeighted" : MessageLookupByLibrary.simpleMessage("限界突破後"),
    "monsterSortTypeMp" : MessageLookupByLibrary.simpleMessage("モンポ"),
    "monsterSortTypeNumber" : MessageLookupByLibrary.simpleMessage("No."),
    "monsterSortTypeRarity" : MessageLookupByLibrary.simpleMessage("レアリティ"),
    "monsterSortTypeRcv" : MessageLookupByLibrary.simpleMessage("回復力"),
    "monsterSortTypeSkillTurn" : MessageLookupByLibrary.simpleMessage("スキルターン数"),
    "monsterSortTypeSubAttr" : MessageLookupByLibrary.simpleMessage("副属性"),
    "monsterSortTypeType" : MessageLookupByLibrary.simpleMessage("タイプ"),
    "monsterSortTypeWeighted" : MessageLookupByLibrary.simpleMessage("プラス換算"),
    "mpAndMpPerStam" : m41,
    "noData" : MessageLookupByLibrary.simpleMessage("データなし"),
    "onboardingDisplayLanguage" : MessageLookupByLibrary.simpleMessage("表示言語"),
    "onboardingDisplayLanguageDesc" : MessageLookupByLibrary.simpleMessage("UIとパズドラデータに適用"),
    "onboardingDownloadDb" : MessageLookupByLibrary.simpleMessage("初期データはダウンロードしています"),
    "onboardingDownloadImages" : MessageLookupByLibrary.simpleMessage("アイコンセットはダウンロードしています"),
    "onboardingGameCountry" : MessageLookupByLibrary.simpleMessage("サーバ"),
    "onboardingGameCountryDesc" : MessageLookupByLibrary.simpleMessage("デフォルトのイベント、ニュース、データの通知を設定します"),
    "onboardingTitle" : MessageLookupByLibrary.simpleMessage("初回起動のセットアップ"),
    "onboardingUnpackDb" : MessageLookupByLibrary.simpleMessage("初期データ展開中"),
    "onboardingUnpackImages" : MessageLookupByLibrary.simpleMessage("アイコンセット展開中"),
    "onboardingWaitingSubTitle" : MessageLookupByLibrary.simpleMessage("数値がセットからは、後で設定タブで変更できます"),
    "onboardingWaitingTitle" : MessageLookupByLibrary.simpleMessage("待っている間..."),
    "reportBadInfo" : MessageLookupByLibrary.simpleMessage("誤った情報を報告する"),
    "serverModalTitle" : MessageLookupByLibrary.simpleMessage("サーバ"),
    "settingsAbout" : MessageLookupByLibrary.simpleMessage("アプリについて"),
    "settingsContactUs" : MessageLookupByLibrary.simpleMessage("お問い合わせ"),
    "settingsCopyright" : MessageLookupByLibrary.simpleMessage("コピーライト"),
    "settingsDarkMode" : MessageLookupByLibrary.simpleMessage("ダークモード"),
    "settingsEventCountry" : MessageLookupByLibrary.simpleMessage("イベントのサーバ"),
    "settingsEventCountryDesc" : MessageLookupByLibrary.simpleMessage("ゲリライベントの地域"),
    "settingsEventsHideClosed" : MessageLookupByLibrary.simpleMessage("終了したイベントを非表示"),
    "settingsEventsSection" : MessageLookupByLibrary.simpleMessage("イベント"),
    "settingsEventsStarterBlue" : MessageLookupByLibrary.simpleMessage("初期ﾊﾟｰﾄﾅｰ：プレシィ"),
    "settingsEventsStarterGreen" : MessageLookupByLibrary.simpleMessage("初期ﾊﾟｰﾄﾅｰ：ブラッキィ"),
    "settingsEventsStarterRed" : MessageLookupByLibrary.simpleMessage("初期ﾊﾟｰﾄﾅｰ：ティラ"),
    "settingsGameCountry" : MessageLookupByLibrary.simpleMessage("サーバ"),
    "settingsGameCountryDesc" : MessageLookupByLibrary.simpleMessage("ほかの地域固有の設定をいくつがセットする"),
    "settingsGeneralSection" : MessageLookupByLibrary.simpleMessage("一般"),
    "settingsHideUnreleasedMonsters" : MessageLookupByLibrary.simpleMessage("未リリースのモンスターを隠せる"),
    "settingsHideUnreleasedMonstersDesc" : MessageLookupByLibrary.simpleMessage("選ぶ地域の未リリースのモンスターを隠せる"),
    "settingsInfoLanguage" : MessageLookupByLibrary.simpleMessage("情報言語"),
    "settingsInfoLanguageDesc" : MessageLookupByLibrary.simpleMessage("モンスター 、ダンジョン名、スキルテキストなどに使える"),
    "settingsInfoSection" : MessageLookupByLibrary.simpleMessage("情報"),
    "settingsNotificationsDesc" : MessageLookupByLibrary.simpleMessage("ゲリラダンジョンが潜入可能と通知します。\nイベントまたはダンジョンを長押しして、通知を切り替えます。"),
    "settingsNotificationsEnabled" : MessageLookupByLibrary.simpleMessage("通知を有効する"),
    "settingsNotificationsSection" : MessageLookupByLibrary.simpleMessage("通知"),
    "settingsTitle" : MessageLookupByLibrary.simpleMessage("設定"),
    "settingsUiLanguage" : MessageLookupByLibrary.simpleMessage("UI言語"),
    "settingsUiLanguageDesc" : MessageLookupByLibrary.simpleMessage("デバイスの設定言語を上書きします"),
    "subDungeonSelectionTitle" : MessageLookupByLibrary.simpleMessage("難易度を選択"),
    "tabDungeon" : MessageLookupByLibrary.simpleMessage("ダンジョン"),
    "tabEvent" : MessageLookupByLibrary.simpleMessage("イベント"),
    "tabMonster" : MessageLookupByLibrary.simpleMessage("モンスター"),
    "tabSetting" : MessageLookupByLibrary.simpleMessage("設定"),
    "taskExecuting" : MessageLookupByLibrary.simpleMessage("タスク実行中"),
    "taskExecutingWithCount" : m42,
    "taskFailedWithCount" : m43,
    "taskFatalError" : MessageLookupByLibrary.simpleMessage("致命的なエラーが発生しました。アプリを再起動してみてください。"),
    "taskFinished" : MessageLookupByLibrary.simpleMessage("すべてのタスクが完了しますた"),
    "taskProgress" : m44,
    "taskRestarting" : MessageLookupByLibrary.simpleMessage("インターネット接続を確認してください。自動的に再起動します。"),
    "taskWaiting" : MessageLookupByLibrary.simpleMessage("タスクの開始を待っています"),
    "title" : MessageLookupByLibrary.simpleMessage("DadGuide"),
    "trackingPopupStartTrackingText" : MessageLookupByLibrary.simpleMessage("ダンジョンが利用可能になったときに通知します。"),
    "trackingPopupStopTrackingText" : MessageLookupByLibrary.simpleMessage("このダンジョンをトラックしなくなる"),
    "trackingTrackedItemText" : MessageLookupByLibrary.simpleMessage("トラック中"),
    "typeAttacker" : MessageLookupByLibrary.simpleMessage("攻撃"),
    "typeAwoken" : MessageLookupByLibrary.simpleMessage("能力覚醒用"),
    "typeBalanced" : MessageLookupByLibrary.simpleMessage("バランス"),
    "typeDevil" : MessageLookupByLibrary.simpleMessage("悪魔"),
    "typeDragon" : MessageLookupByLibrary.simpleMessage("ドラゴン"),
    "typeEnhance" : MessageLookupByLibrary.simpleMessage("強化合成用"),
    "typeEvoMat" : MessageLookupByLibrary.simpleMessage("進化用"),
    "typeGod" : MessageLookupByLibrary.simpleMessage("神"),
    "typeHealer" : MessageLookupByLibrary.simpleMessage("回復"),
    "typeMachine" : MessageLookupByLibrary.simpleMessage("マシン"),
    "typePhysical" : MessageLookupByLibrary.simpleMessage("体力"),
    "typeVendor" : MessageLookupByLibrary.simpleMessage("売却用"),
    "updateComplete" : MessageLookupByLibrary.simpleMessage("更新完了"),
    "updateFailed" : MessageLookupByLibrary.simpleMessage("アップデートを失敗しました"),
    "updateFailedTooOld" : MessageLookupByLibrary.simpleMessage("DadGuideは更新する必要があります"),
    "updateModalTitle" : MessageLookupByLibrary.simpleMessage("DadGuideデータの更新しています"),
    "upgradingDbTitle" : MessageLookupByLibrary.simpleMessage("データベースのアップデート"),
    "upgradingInfoText" : MessageLookupByLibrary.simpleMessage("一部の更新では、非互換性データベースの変更が導入されます。\nこれが発生した場合は、新しいデータを置換し、ダウンロードする必要があります\nこれには約20MBのデータがダウンロードします。\n ご不便おかけしてすみません。"),
    "upgradingInfoTitle" : MessageLookupByLibrary.simpleMessage("データベースの更新をダウンロードし、インストールしています"),
    "warning" : MessageLookupByLibrary.simpleMessage("警告"),
    "ytLaunchError" : MessageLookupByLibrary.simpleMessage("YouTubeを起動できませんでした")
  };
}
