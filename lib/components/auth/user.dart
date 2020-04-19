import 'package:dadguide2/components/auth/src/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_fimber/flutter_fimber.dart';
import 'package:rxdart/rxdart.dart';

/// Wrapper for user login/logout and event streams.
class UserManager {
  UserManager._internal();
  static final UserManager instance = UserManager._internal();

  /// Publishes status events for the app.
  ///
  /// The user starts out anonymous, but once firebaseInit() is called if the user had been
  /// previously logged in, an event will spawn with that login value.
  final _userSubject = BehaviorSubject.seeded(DgUser.anonymous());

  void firebaseInit() {
    FirebaseAuth.instance.onAuthStateChanged.map((fu) {
      Fimber.w('Auth state changed: ${fu?.uid}');
      return fu == null ? DgUser.anonymous() : DgUser.fromFirebase(fu);
    }).pipe(_userSubject);
  }

  /// Get the underlying BehaviorSubject as a stream.
  ValueStream<DgUser> get stream => _userSubject.stream;

  /// Since UserManager lives for the lifecycle of the app, this is likely not to be called.
  void dispose() {
    _userSubject.close();
  }
}
