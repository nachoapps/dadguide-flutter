import 'package:dadguide2/components/firebase/analytics.dart';
import 'package:dadguide2/components/ui/navigation.dart';
import 'package:flutter/material.dart';

import 'exchange_content.dart';

class ExchangeScreen extends StatelessWidget {
  final ExchangeArgs args;

  ExchangeScreen(this.args) {
    screenChangeEvent(runtimeType.toString());
  }

  @override
  Widget build(BuildContext context) {
    return ExchangeTabbedViewWidget(args.exchanges, key: ValueKey(args.server));
  }
}
