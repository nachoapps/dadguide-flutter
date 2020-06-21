import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class _RebuildNotifier with ChangeNotifier {
  void rebuild() {
    notifyListeners();
  }
}

/// A simple way to expose a notifier to an object so it can trigger itself to rebuild
class SimpleNotifier extends StatelessWidget {
  final Widget Function(BuildContext context, _RebuildNotifier notifier) builder;

  const SimpleNotifier({Key key, @required this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => _RebuildNotifier(),
      child: Consumer<_RebuildNotifier>(builder: (_, notifier, __) => builder(context, notifier)),
    );
  }
}
