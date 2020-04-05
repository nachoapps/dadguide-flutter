import 'package:dadguide2/components/ui/navigation.dart';
import 'package:dadguide2/screens/monster_compare/src/state.dart';
import 'package:dadguide2/screens/monster_compare/src/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class MonsterCompareScreen extends StatelessWidget {
  final CompareState state;

  MonsterCompareScreen(MonsterCompareArgs args) : state = CompareState(args.left, args.right);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ChangeNotifierProvider.value(
        value: state,
        child: CompareFrame(),
      ),
    );
  }
}
