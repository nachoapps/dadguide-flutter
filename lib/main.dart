import 'package:dadguide2/components/config/service_locator.dart';
import 'package:dadguide2/components/config/settings_manager.dart';
import 'package:dadguide2/components/firebase/ads.dart';
import 'package:dadguide2/components/firebase/remote_config.dart';
import 'package:dadguide2/components/updates/background_fetch.dart';
import 'package:dadguide2/components/utils/app_reloader.dart';
import 'package:dadguide2/components/utils/logging.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:dadguide2/screens/home/root_screen.dart';
import 'package:dadguide2/screens/onboarding/onboarding_screen.dart';
import 'package:dadguide2/screens/onboarding/onboarding_task.dart';
import 'package:dadguide2/screens/onboarding/upgrading_screen.dart';
import 'package:dadguide2/theme/theme.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fimber/flutter_fimber.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'components/config/app_state.dart';

/// If true, toggles some helpful things like logging of HTTP requests. Also disables Crashlytics
/// handler which seems to swallow some helpful Flutter error reporting. This should never be
/// checked in with true.
bool inDevMode = false;

/// If true, uses dev (local) endpoints. Unless you're running the Sanic webserver from the
/// dadguide-data project, you probably don't want this.
bool useDevEndpoints = false;

void main() async {
  // Do quick init.
  _syncInit();

  // Wait for critical async init and then start up.
  runApp(InitAppWidget());
}

/// Basic, quick, synchronous init ops we execute before starting the app.
void _syncInit() {
  // Dont report errors from dev mode to crashlytics.
  Crashlytics.instance.enableInDevMode = false;

  // Pass all uncaught errors to Crashlytics.
  if (!inDevMode) {
    FlutterError.onError = Crashlytics.instance.recordFlutterError;
  }

  // Set up logging.
  initLogging();
}

/// Long running actions that we expect to complete before starting the app.
Future<bool> _asyncInit() async {
  // Set up file logger.
  await initAsyncLogging();

  // Ensure the preference defaults are set.
  await Prefs.init();

  // Set up services that are guaranteed to start with getIt.
  await initializeServiceLocator(logHttpRequests: inDevMode, useDevEndpoints: useDevEndpoints);

  // Try to initialize the DB and register it with getIt; this will fail on first-launch or
  // when the database needs to be upgraded.
  await tryInitializeServiceLocatorDb();

  if (await onboardingManager.upgradingMustRun()) {
    Fimber.i('Starting upgrading');
    appStatusSubject.add(AppStatus.upgrading);
    onboardingManager.start();
  } else if (await onboardingManager.onboardingMustRun()) {
    Fimber.i('Starting onboarding');
    appStatusSubject.add(AppStatus.onboarding);
    onboardingManager.start();
  } else {
    Fimber.i('Starting the app normally');
    appStatusSubject.add(AppStatus.ready);
  }

  // These tasks are not critical to startup and don't need to be awaited.
  RemoteConfigWrapper.instance.then((rc) => Fimber.i('Remote config ready'));

  FirebaseAdMob.instance
      .initialize(appId: appId(), analyticsEnabled: true)
      .then((am) => Fimber.i('AdMob ready'));

  configureUpdateDatabaseTask();

  return true;
}

/// Waits until the async init tasks have been completed before starting the app.
class InitAppWidget extends StatefulWidget {
  @override
  _InitAppWidgetState createState() => _InitAppWidgetState();
}

class _InitAppWidgetState extends State<InitAppWidget> {
  Future<bool> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _asyncInit();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return DadGuideApp();
        } else if (snapshot.hasError) {
          return Container(color: Colors.red);
        }
        return Container();
      },
    );
  }
}

/// This is the root widget for the entire application.
///
/// It sets up the MaterialApp and Theme for the whole thing. Based on the status of the database
/// it may spawn the initial onboarding step.
class DadGuideApp extends StatefulWidget {
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

    return ChangeNotifierProvider<ReloadAppChangeNotifier>(
        create: (_) => ReloadAppChangeNotifier(this),
        child: MaterialApp(
          onGenerateTitle: (BuildContext context) => DadGuideLocalizations.of(context).title,
          theme: themeFromPrefs(),
          darkTheme: themeFromPrefs(),
          locale: Locale(Prefs.uiLanguage.languageCode),
          debugShowCheckedModeBanner: false,
          home: AppOrOnboardingWidget(),
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
            // Not sure why this is necessary given the hardcoded locale.
            return Locale(Prefs.uiLanguage.languageCode);
          },
        ));
  }
}

class AppOrOnboardingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: AppStatus.initializing,
      stream: appStatusSubject.stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Container(color: Colors.red);
        } else if (!snapshot.hasData) {
          // Probably can't happen but anyway.
          return Container();
        }

        switch (snapshot.data) {
          case AppStatus.initializing:
            // Either shouldn't occur or should be brief.
            return Container();
          case AppStatus.onboarding:
            return OnboardingScreen();
          case AppStatus.upgrading:
            return UpgradingScreen();
          case AppStatus.ready:
            return StatefulHomeScreen();
          default:
            return Text('Error; unexpected state ${snapshot.data}');
        }
      },
    );
  }
}
