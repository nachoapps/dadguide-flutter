import 'package:dadguide2/components/firebase/analytics.dart';
import 'package:dadguide2/components/ui/navigation.dart';
import 'package:flutter/material.dart';

import 'egg_machine_content.dart';

class EggMachineScreen extends StatelessWidget {
  final EggMachineArgs args;

  EggMachineScreen(this.args) {
    screenChangeEvent(runtimeType.toString());
  }

  @override
  Widget build(BuildContext context) {
    return EggMachineTabbedViewWidget(args.machines);
  }
}
