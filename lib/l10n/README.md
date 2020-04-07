## Localization files

We use crowdin.com to manage translations:
https://crowdin.com/project/dadguide/settings#translations

Pre-work is to pull strings out of the project into `localizations.dart`, and use the helpers in
place of the hardcoded strings.

Then regenerate `intl_messages.arb` and the corresponding English messages (the default):

```
flutter pub run intl_translation:extract_to_arb --locale=en --output-dir=lib/l10n lib/l10n/localizations.dart
cp lib/l10n/intl_messages.arb lib/l10n/intl_en.arb
```

Go to https://crowdin.com/project/dadguide/settings#files and click 'Update'. Select 
`intl_messages.arb` and hit OK. This will update the strings in the project.

Ask the translators for JP/KR to take a look and suggest translations. When they're done, review
their suggestions and hit approve.

Then go to https://crowdin.com/project/dadguide/settings#translations and click 'Build & Download'.
After some processing, a zip file will download. Unzip the file, and rename the JP file to
`intl_ja.arb` and the KR file to `intl_ko.arb`. Copy them into place over their existing files.

Diff the files against their existing versions, for some reason they always export with the wrong
locale and you need to replace them.

Then run the following command to regenerate the l10n code:
```
flutter pub pub run intl_translation:generate_from_arb --output-dir=lib/l10n --no-use-deferred-loading lib/l10n/localizations.dart lib/l10n/intl_??.arb
```

If we ever support CN languages:
https://flutter.dev/docs/development/accessibility-and-localization/internationalization#advanced-locale-definition
