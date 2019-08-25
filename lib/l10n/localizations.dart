import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'messages_all.dart';

class DadGuideLocalizations {
  // ---- The rest of this class is strings used by DadGuide ----
  String get title {
    return Intl.message('Hello world App', name: 'title', desc: 'The application title');
  }

  String get hello {
    return Intl.message('Hello', name: 'hello');
  }

  // ---- Everything below here is boilerplate that doesn't matter to a translator ----

  static Future<DadGuideLocalizations> load(Locale locale) {
    final String name = locale.countryCode == null ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((bool _) {
      Intl.defaultLocale = localeName;
      return new DadGuideLocalizations();
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
