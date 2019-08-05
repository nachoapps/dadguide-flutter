import 'package:dadguide2/components/service_locator.dart';
import 'package:dadguide2/components/settings_manager.dart';
import 'package:dadguide2/screens/home/root_screen.dart';
import 'package:dadguide2/screens/onboarding/onboarding_screen.dart';
import 'package:dadguide2/services/onboarding_task.dart';
import 'package:dadguide2/theme/theme.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fimber/flutter_fimber.dart';
import 'package:provider/provider.dart';

bool inDevMode = false;

void main() async {
  // Dont report errors from dev mode to crashlytics.
  Crashlytics.instance.enableInDevMode = false;

  // Pass all uncaught errors to Crashlytics.
  if (!inDevMode) {
    FlutterError.onError = (FlutterErrorDetails details) {
      Crashlytics.instance.onError(details);
    };
  }

  // Set up logging.
  Fimber.plantTree(FimberTree());

  // Initialize ads.
  FirebaseAdMob.instance.initialize(appId: 'ca-app-pub-6128472825595951~4484271468');
  // Sample bottom banner
  // ca-app-pub-3940256099942544/6300978111

  await Prefs.init();
  initializeServiceLocator(dev: inDevMode);
  await tryInitializeServiceLocatorDb(false);
  runApp(DadGuideApp());
}

class DadGuideApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Prevent landscape mode.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MultiProvider(
      providers: [
        // TODO: Convert this to get_it ?
        Provider<FirebaseAnalytics>.value(value: analytics),
        Provider<FirebaseAnalyticsObserver>.value(value: observer),
      ],
      child: MaterialApp(
        title: 'DadGuide',
        theme: appTheme(),
        debugShowCheckedModeBanner: false,
        navigatorObservers: [observer],
        home: SetupRequiredChecker(),
        onGenerateRoute: (settings) {
          if (settings.name == '/home') {
            return MaterialPageRoute(builder: (_) => StatefulHomeScreen());
          } else if (settings.name == '/onboarding') {
            return MaterialPageRoute(builder: (_) => OnboardingScreen());
          }
          throw 'Route not implemented: ${settings.name}';
        },
      ),
    );
  }
}

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
    return Center(child: CircularProgressIndicator());
  }

  Future<void> _checkSetupRequired() async {
    Fimber.i('Checking if setup is required');
    if (await onboardingManager.mustRun()) {
      Fimber.i('Navigating to onboarding');
      Navigator.pushReplacementNamed(context, '/onboarding');
      onboardingManager.start();
    } else {
      _goHome(context);
    }
  }

  void _goHome(BuildContext ctx) {
    Fimber.i('Navigating to home');
    Navigator.pushReplacementNamed(ctx, '/home');
  }
}
