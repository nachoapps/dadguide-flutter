import 'package:dadguide2/components/config/service_locator.dart';
import 'package:dadguide2/components/config/settings_manager.dart';
import 'package:dadguide2/components/firebase/analytics.dart';
import 'package:dadguide2/components/models/data_objects.dart';
import 'package:dadguide2/components/ui/navigation.dart';
import 'package:dadguide2/data/tables.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fimber/flutter_fimber.dart';

import 'egg_machine_content.dart';

class EggMachineScreen extends StatefulWidget {
  final EggMachineArgs args;

  EggMachineScreen(this.args) {
    screenChangeEvent(runtimeType.toString());
  }

  @override
  _EggMachineScreenState createState() => _EggMachineScreenState();
}

class _EggMachineScreenState extends State<EggMachineScreen> {
  Future<List<FullEggMachine>> loadingFuture;

  _EggMachineScreenState();

  @override
  void initState() {
    super.initState();
    loadingFuture = getIt<EggMachinesDao>().findEggMachines();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _retrieveMachines(),
    );
  }

  FutureBuilder<List<FullEggMachine>> _retrieveMachines() {
    return FutureBuilder<List<FullEggMachine>>(
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
          print(data.length);
          var selectedCountry = Prefs.eventCountry;
          var serverData = data.where((fem) => fem.server == selectedCountry).toList();
          return EggMachineTabbedViewWidget(serverData, key: ValueKey(selectedCountry));
        });
  }
}
