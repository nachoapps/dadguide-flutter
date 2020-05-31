import 'package:firebase_auth/firebase_auth.dart';

/// Represents the current user. Should always be non-null.
///
/// The user starts off as anonymous, and once they log in via Firebase some fields get filled in.
/// If the user logs out, they move back to anonymous.
class DgUser {
  /// The display name for the user, empty string if !loggedIn.
  final String userName;

  /// The email for the user, empty string if !loggedIn.
  final String email;

  /// If the user is logged in vs anonymous.
  final bool loggedIn;

  /// If the user's log-in has been verified.
  ///
  /// This might be false even though loggedIn is true, if the user has used a method that requires
  /// further action (e.g. email verification).
  final bool verified;

  DgUser.anonymous()
      : userName = '',
        email = '',
        loggedIn = false,
        verified = false;

  DgUser.fromFirebase(FirebaseUser user)
      : userName = user.displayName ?? 'no name',
        email = user.email,
        loggedIn = true,
        verified = user.isEmailVerified;
}
