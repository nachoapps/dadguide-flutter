import 'package:dadguide2/proto/monster.pb.dart';

class MonsterListModel {
  // TODO: should take a server
  // rename monster_no to monster_id
  static final columns = <String>[
    'monster_no',
    'monster_no_jp',
    'monster_no_kr',
    'monster_no_na',
    'name_jp',
    'name_kr',
    'name_na',
    'hp_max',
    'hp_min',
    'hp_scale',
    'atk_max',
    'atk_min',
    'atk_scale',
    'rcv_max',
    'rcv_min',
    'rcv_scale',
    'cost',
    'exp',
    'level',
    'scale',
  ];

  final Monster _m;

  MonsterListModel(this._m);

  Monster get m => _m;
}

Monster monsterFromJson(Map<String, dynamic> json) {
  return Monster()
    ..monsterNo = json['monster_no']
    ..monsterId = (CrossServerInt()
      ..jp = json['monster_no_jp'] ?? 0
      ..kr = json['monster_no_kr'] ?? 0
      ..na = json['monster_no_us'] ?? 0)
    ..name = (CrossServerString()
      ..jp = json['name_jp'] ?? 'unset'
      ..kr = json['name_kr'] ?? 'unset'
      ..na = json['name_us'] ?? 'unset')
    ..hp = (Curve()
      ..max = json['hp_max']
      ..min = json['hp_min']
      ..scale = json['hp_scale'].toDouble())
    ..atk = (Curve()
      ..max = json['atk_max']
      ..min = json['atk_min']
      ..scale = json['atk_scale'].toDouble())
    ..rcv = (Curve()
      ..max = json['rcv_max']
      ..min = json['rcv_min']
      ..scale = json['rcv_scale'].toDouble())
    ..cost = json['cost']
    ..exp = json['exp']
    ..level = json['level']
    ..rarity = json['rarity'];
}
