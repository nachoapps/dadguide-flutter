## Localization files

Command to regenerate `intl_messages.arb` and the corresponding English messages (the default):
```
flutter pub run intl_translation:extract_to_arb --locale=en --output-dir=lib/l10n lib/l10n/localizations.dart
cp lib/l10n/intl_messages.arb lib/l10n/intl_en.arb
```

There is a helpful tool to manage translations:
https://translate.google.com/toolkit/list

Not clear what the proper workflow is to manage these going forwards. Possibly use a diff tool
to merge new translations from intl_messages.arb into intl_messages_<language> and then re-upload
them to the tool for translations.

Once translations are applied, copy them into place and run the following command to regenerate
the l10n code:
```
flutter pub pub run intl_translation:generate_from_arb --output-dir=lib/l10n --no-use-deferred-loading lib/main.dart lib/l10n/intl_??.arb
```

If we ever support CN languages:
https://flutter.dev/docs/development/accessibility-and-localization/internationalization#advanced-locale-definition
