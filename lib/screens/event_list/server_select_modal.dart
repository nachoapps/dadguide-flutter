import 'package:dadguide2/components/config/settings_manager.dart';
import 'package:dadguide2/components/models/enums.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:dadguide2/screens/event_list/event_search_bloc.dart';
import 'package:dadguide2/screens/event_list/update_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fimber/flutter_fimber.dart';

/// Displays a dialog that lets the user toggle their event server, or kick off the update.
Future<void> showServerSelectDialog(BuildContext context, ScheduleDisplayState displayState) async {
  var loc = DadGuideLocalizations.of(context);

  Fimber.i('Displaying server select dialog');
  return showDialog(
      context: context,
      builder: (innerContext) {
        return SimpleDialog(
          title: Text(loc.serverModalTitle),
          children: [
            CountryTile(displayState, Country.jp),
            CountryTile(displayState, Country.na),
            CountryTile(displayState, Country.kr),
            ListTile(
              onTap: () {
                Navigator.pop(innerContext);
                showUpdateDialog(context);
              },
              leading: Icon(Icons.refresh),
              title: Text(loc.dataSync),
            ),
          ],
        );
      });
}

/// Country icon and name; when clicked, changes the selected events country.
class CountryTile extends StatelessWidget {
  final ScheduleDisplayState displayState;
  final Country country;
  CountryTile(this.displayState, this.country);

  @override
  Widget build(BuildContext context) {
    var selectedCountry = Prefs.eventCountry;
    var icon = selectedCountry == country ? country.iconOnName : country.iconOffName;
    return ListTile(
      onTap: () {
        displayState.server = country;
        Navigator.pop(context);
      },
      leading: Image.asset('assets/images/$icon'),
      title: Text(country.countryName()),
    );
  }
}
