import 'package:dadguide2/components/icons.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    int _index =
        0; // Make sure this is outside build(), otherwise every setState will chage the value back to 0

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
              ListTile(
                title: Text('Select the UI display language'),
                subtitle: Text('Elements like this text will be updated'),
              ),
              SupportedLanguageSelector(),
              SizedBox(height: 5),
              Divider(),
              ListTile(
                title: Text('Select the data language'),
                subtitle: Text('This will be used when displaying PAD data'),
              ),
              SupportedLanguageSelector(),
            ],
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: () => print('hi'),
        tooltip: 'Increment Counter',
        child: Icon(Icons.chevron_right), //Change Icon
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat, //Change for different locations
    );

    return Container();
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
    print('changing language from $_language to $l');
    setState(() => _language = l);
    print('done changing language from $_language to $l');
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
        value: SupportedLanguage.korean,
        groupValue: selectedLanguage,
        onChanged: (SupportedLanguage value) {
          languageCallback(value);
        },
      ),
    );
  }
}
