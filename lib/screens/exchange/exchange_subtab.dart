import 'package:dadguide2/components/config/service_locator.dart';
import 'package:dadguide2/components/config/settings_manager.dart';
import 'package:dadguide2/components/firebase/analytics.dart';
import 'package:dadguide2/components/models/data_objects.dart';
import 'package:dadguide2/components/ui/navigation.dart';
import 'package:dadguide2/data/tables.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fimber/flutter_fimber.dart';

import 'exchange_content.dart';

class ExchangeScreen extends StatefulWidget {
  final ExchangeArgs args;

  ExchangeScreen(this.args) {
    screenChangeEvent(runtimeType.toString());
  }

  @override
  _ExchangeScreenState createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {
  Future<List<FullExchange>> loadingFuture;

  _ExchangeScreenState();

  @override
  void initState() {
    super.initState();
    loadingFuture = getIt<ExchangesDao>().findExchanges();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _retrieveMachines(),
    );
  }

  FutureBuilder<List<FullExchange>> _retrieveMachines() {
    return FutureBuilder<List<FullExchange>>(
        future: loadingFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            Fimber.e('Error retrieving egg machines', ex: snapshot.error);
            return Center(child: Icon(Icons.error));
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var data = snapshot.data;
          var selectedCountry = Prefs.eventCountry;
          var serverData = data.where((fem) => fem.server == selectedCountry).toList();
          return ExchangeTabbedViewWidget(serverData, key: ValueKey(selectedCountry));
        });
  }
}
