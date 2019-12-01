import 'package:dadguide2/components/ads.dart';
import 'package:dadguide2/components/background_fetch.dart';
import 'package:dadguide2/components/service_locator.dart';
import 'package:dadguide2/components/settings_manager.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:dadguide2/screens/home/root_screen.dart';
import 'package:dadguide2/screens/onboarding/onboarding_screen.dart';
import 'package:dadguide2/services/onboarding_task.dart';
import 'package:dadguide2/theme/theme.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fimber/flutter_fimber.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

/// If true, toggles some helpful things like logging of HTTP requests. Also disables Crashlytics
/// handler which seems to swallow some helpful Flutter error reporting. This should never be
/// checked in with true. It gets stored as a preference for re-use throughout the app.
bool inDevMode = false;

/// If true, uses dev (local) endpoints. Unless you're running the Sanic webserver from the
/// dadguide-data project, you probably don't want this.
bool useDevEndpoints = false;

void main() async {
  // Dont report errors from dev mode to crashlytics.
  Crashlytics.instance.enableInDevMode = false;

  // Pass all uncaught errors to Crashlytics.
  if (!inDevMode) {
    FlutterError.onError = Crashlytics.instance.recordFlutterError;
  }

  // Set up logging.
  Fimber.plantTree(FimberTree());

  // Initialize ads.
  FirebaseAdMob.instance.initialize(appId: appId(), analyticsEnabled: true);

  // Ensure the preference defaults are set.
  await Prefs.init();

  // Set dev mode for re-use throughout the app
  Prefs.setInDevMode(inDevMode);

  // Set up services that are guaranteed to start with getIt.
  await initializeServiceLocator(logHttpRequests: inDevMode, useDevEndpoints: useDevEndpoints);

  // Try to initialize the DB and register it with getIt; this will fail on first-launch.
  await tryInitializeServiceLocatorDb(false);

  // Start the app.
  runApp(DadGuideApp());
}

/// This is the root widget for the entire application.
///
/// It sets up the MaterialApp and Theme for the whole thing. Based on the status of the database
/// it may spawn the initial onboarding step.
class DadGuideApp extends StatefulWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics();

  @override
  _DadGuideAppState createState() => _DadGuideAppState();
}

class _DadGuideAppState extends State<DadGuideApp> {
  @override
  Widget build(BuildContext context) {
    // Prevent landscape mode.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // Initializes all the background_fetch plugin.
    BackgroundFetchInit();
    return ChangeNotifierProvider<LocaleChangedNotifier>(
        builder: (_) => LocaleChangedNotifier(this),
        child: MaterialApp(
          onGenerateTitle: (BuildContext context) => DadGuideLocalizations.of(context).title,
          theme: themeFromPrefs(),
          darkTheme: themeFromPrefs(),
          locale: Locale(Prefs.uiLanguage.languageCode),
          debugShowCheckedModeBanner: false,
          home: SetupRequiredChecker(),
          onGenerateRoute: (settings) {
            if (settings.name == '/home') {
              return MaterialPageRoute(builder: (_) => StatefulHomeScreen());
            } else if (settings.name == '/onboarding') {
              return MaterialPageRoute(builder: (_) => OnboardingScreen());
            }
            throw 'Route not implemented: ${settings.name}';
          },
          localizationsDelegates: [
            DadGuideLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            const Locale('en'), // English
            const Locale('ja'), // Japanese
            const Locale('ko'), // Korean
          ],
          localeResolutionCallback: (Locale locale, Iterable<Locale> supportedLocales) {
            // Added this to support non-supported locales, since fallback selection seems broken.
            return Locale(Prefs.uiLanguage.languageCode);
          },
        ));
  }
}

/// Placeholder widget that kicks off the async check that determines if we need to do onboarding
/// (initial database and image pack downloading) or if we're ready to start the app.
class SetupRequiredChecker extends StatefulWidget {
  @override
  SetupRequiredCheckerState createState() => new SetupRequiredCheckerState();
}

class SetupRequiredCheckerState extends State<SetupRequiredChecker> {
  @override
  void initState() {
    super.initState();
    _checkSetupRequired();
  }

  @override
  Widget build(BuildContext context) {
    // This check doesn't take much time, so don't bother displaying a loading UI.
    // TODO: Save the future from _checkSetupRequired, and use FutureBuilder here so that we can
    //       update the UI if the check fails. That really shouldn't happen, but an error would be
    //       better than a blank screen if it does.
    return Container();
  }

  Future<void> _checkSetupRequired() async {
    Fimber.i('Checking if setup is required');
    if (await onboardingManager.mustRun()) {
      Fimber.i('Navigating to onboarding');
      Navigator.pushReplacementNamed(context, '/onboarding');
      onboardingManager.start();
    } else {
      Fimber.i('Navigating to home');
      Navigator.pushReplacementNamed(context, '/home');
    }
  }
}
