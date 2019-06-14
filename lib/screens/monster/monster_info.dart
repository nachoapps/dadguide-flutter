import 'package:async/async.dart';
import 'package:flutter/material.dart';

class MonsterDetailScreen extends StatefulWidget {
  final int monster_id;

  MonsterDetailScreen(this.monster_id);

  @override
  _MonsterDetailScreenState createState() =>
      _MonsterDetailScreenState(monster_id);
}

class _MonsterDetailScreenState extends State<MonsterDetailScreen> {
  final int monster_id;
//  final _memoizer = AsyncMemoizer<List<MonsterListModel>>();

  _MonsterDetailScreenState(this.monster_id);

  @override
  Widget build(BuildContext context) {}
}
