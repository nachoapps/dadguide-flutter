import 'package:dadguide2/components/config/service_locator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_fimber/flutter_fimber.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Thrown when an unexpected auth failure occurs.
class LoginErrorException implements Exception {
  final String cause;
  final Exception ex;
  LoginErrorException(this.cause, {this.ex});
}

/// Logs a user in via Google OAuth, and then into Firebase.
Future<FirebaseUser> googleSignIn() async {
  Fimber.i('Trying to log in');
  final googleSignIn = getIt<GoogleSignIn>();
  final firebaseAuth = FirebaseAuth.instance;

  if (await googleSignIn.isSignedIn()) {
    await googleSignIn.signOut();
  }
  var googleUser = await googleSignIn.signIn();
  if (googleUser == null) throw LoginErrorException('Login canceled');

  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );
  var firebaseUser = (await firebaseAuth.signInWithCredential(credential)).user;
  Fimber.i('Login complete: ${firebaseUser.email}');
  return firebaseUser;
}

/// Logs a user out of Google and Firebase.
Future<void> googleSignOut() async {
  Fimber.i('Trying to log out');
  final googleSignIn = getIt<GoogleSignIn>();
  final firebaseAuth = FirebaseAuth.instance;

  if (await googleSignIn.isSignedIn()) {
    await googleSignIn.signOut();
  }
  if (await firebaseAuth.currentUser() != null) {
    await FirebaseAuth.instance.signOut();
  }
  Fimber.i('Done logging out');
}
