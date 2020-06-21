import 'package:dadguide2/components/ui/buttons.dart';
import 'package:dadguide2/components/ui/navigation.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:dadguide2/screens/monster_compare/src/state.dart';
import 'package:dadguide2/screens/monster_compare/src/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

class MonsterCompareScreen extends StatelessWidget {
  final screenshotController = ScreenshotController();
  final CompareState state;

  MonsterCompareScreen(MonsterCompareArgs args) : state = CompareState(args.left, args.right);

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: state),
        Provider.value(value: screenshotController),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(loc.monsterCompareTitle),
          actions: <Widget>[
            ScreenshotButton(controller: screenshotController),
          ],
        ),
        body: CompareFrame(),
        bottomNavigationBar: BottomBar(),
        resizeToAvoidBottomInset: false,
      ),
    );
  }
}
