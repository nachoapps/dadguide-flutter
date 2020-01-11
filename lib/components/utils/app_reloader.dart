import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Helper class that triggers a state change for the entire application.
///
/// This uses a hacky workaround; I couldn't get the MaterialApp to rebuild via
/// a ChangeNotifierProvider and I'm not sure why.
class ReloadAppChangeNotifier with ChangeNotifier {
  State _state;

  ReloadAppChangeNotifier(this._state);

  void notify() {
    // ignore: invalid_use_of_protected_member
    _state.setState(() {});
  }
}
