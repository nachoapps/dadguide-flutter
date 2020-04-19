import 'package:dadguide2/components/auth/src/user.dart';
import 'package:dadguide2/components/auth/user.dart';
import 'package:dadguide2/components/config/settings_manager.dart';
import 'package:dadguide2/components/utils/streams.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:flutter_fimber/flutter_fimber.dart';

import 'google.dart';

/// Displays as a 'log in' button if the user is logged out, or a 'log out' button if the user is
/// logged in, and takes the appropraite actions when pressed.
class SignInAndOutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SimpleRxStreamBuilder<DgUser>(
      stream: UserManager.instance.stream,
      builder: (context, data) {
        if (!data.loggedIn) {
          return GoogleSignInButton(
              darkMode: Prefs.uiDarkMode,
              onPressed: () async {
                try {
                  await googleSignIn();
                  Scaffold.of(context).showSnackBar(SnackBar(content: Text('Sign-in complete')));
                } catch (ex) {
                  Fimber.e('Sign-in failed', ex: ex);
                  Scaffold.of(context).showSnackBar(SnackBar(content: Text('Sign-in failed')));
                }
              });
        } else {
          return RaisedButton(
            onPressed: () async {
              Fimber.i('Trying to log out');
              await googleSignOut();
              Fimber.i('Log out done');
            },
            child: Text('Log Out'),
          );
        }
      },
    );
  }
}
