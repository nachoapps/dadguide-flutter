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

//  String get title => Intl.message('DadGuide', name: 'title', desc: 'The application title');
//  String get title => Intl.message('DadGuide', name: 'title', desc: 'The application title');
//  String get title => Intl.message('DadGuide', name: 'title', desc: 'The application title');
//  String get title => Intl.message('DadGuide', name: 'title', desc: 'The application title');
//  String get title => Intl.message('DadGuide', name: 'title', desc: 'The application title');
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
