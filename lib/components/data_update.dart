import 'dart:async';

import 'package:dadguide2/components/settings_manager.dart';
import 'package:dadguide2/services/update_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fimber/flutter_fimber.dart';
import 'package:provider/provider.dart';

class DataUpdater with ChangeNotifier {
  final BuildContext _context;
  StreamSubscription<void> _subscription;

  DataUpdater(this._context);

  void subscribe() {
    _subscription = updateManager.updateStream.listen((_) {
      Scaffold.of(_context).showSnackBar((SnackBar(content: Text('Update Complete'))));
      notifyListeners();
    }, onError: (_) {
      Scaffold.of(_context).showSnackBar((SnackBar(content: Text('Update Failed'))));
    });
    if (Prefs.updateRequired()) {
      Fimber.w('Update is required, triggering');
      updateManager.start();
    }
  }

  void dispose() {
    super.dispose();
    if (_subscription != null) {
      _subscription.cancel();
    }
  }
}

class DataUpdaterWidget extends StatelessWidget {
  final Widget _child;

  const DataUpdaterWidget(this._child, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DataUpdater>(
      builder: (context) => DataUpdater(context)..subscribe(),
      child: _child,
    );
  }
}
