import 'package:dadguide2/components/icons.dart';
import 'package:dadguide2/components/task.dart';
import 'package:dadguide2/services/onboarding_task.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DadGuide'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'First-launch setup',
                style: Theme.of(context).textTheme.headline,
              ),
              SizedBox(height: 5),
              Divider(),
              TaskListProgress(onboardingManager.instance),
              SizedBox(height: 5),
              Divider(),
              ListTile(
                title: Text('UI display language'),
                subtitle: Text('Applies to DadGuide text elements'),
              ),
              SupportedLanguageSelector(),
              SizedBox(height: 5),
              Divider(),
              ListTile(
                title: Text('PAD data language'),
                subtitle: Text('Preferred server for monster/skill text'),
              ),
              SupportedLanguageSelector(),
            ],
          )),
    );
  }
}

enum SupportedLanguage { english, japanese, korean }

class SupportedLanguageSelector extends StatefulWidget {
  SupportedLanguageSelector({Key key}) : super(key: key);

  @override
  SupportedLanguageSelectorState createState() => SupportedLanguageSelectorState();
}

class SupportedLanguageSelectorState extends State<SupportedLanguageSelector> {
  SupportedLanguage _language = SupportedLanguage.english;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        LanguageRadio(DadGuideIcons.enOn, SupportedLanguage.english, _language, _applyLanguage),
        LanguageRadio(DadGuideIcons.jpOn, SupportedLanguage.japanese, _language, _applyLanguage),
        LanguageRadio(DadGuideIcons.krOn, SupportedLanguage.korean, _language, _applyLanguage),
      ],
    );
  }

  SupportedLanguage get language => _language;

  void _applyLanguage(SupportedLanguage l) {
    setState(() => _language = l);
  }
}

class LanguageRadio extends StatelessWidget {
  final Widget icon;
  final SupportedLanguage language;
  final SupportedLanguage selectedLanguage;
  final Function languageCallback;

  LanguageRadio(this.icon, this.language, this.selectedLanguage, this.languageCallback);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: RadioListTile<SupportedLanguage>(
        dense: true,
        title: icon,
        value: language,
        groupValue: selectedLanguage,
        onChanged: (SupportedLanguage value) {
          languageCallback(value);
        },
      ),
    );
  }
}
