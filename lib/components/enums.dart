class MonsterType {
  final int id;
  final String name;
  final List<KillerLatent> killers;

  MonsterType(this.id, this.name, this.killers);
}

MonsterType monsterTypeFor(int id) {
  return _monsterLookup[id];
}

var _allMonsterTypes = [
  MonsterType(0, 'Evo Material', []),
  MonsterType(1, 'Balanced', [
    _godKiller,
    _dragonKiller,
    _devilKiller,
    _machineKiller,
    _balancedKiller,
    _attackerKiller,
    _physicalKiller,
    _healerKiller,
  ]),
  MonsterType(2, 'Physical', [_machineKiller, _healerKiller]),
  MonsterType(3, 'Healer', [_dragonKiller, _attackerKiller]),
  MonsterType(4, 'Dragon', [_machineKiller, _healerKiller]),
  MonsterType(5, 'God', [_devilKiller]),
  MonsterType(6, 'Attacker', [_devilKiller, _physicalKiller]),
  MonsterType(7, 'Devil', [_godKiller]),
  MonsterType(8, 'Machine', [_godKiller, _balancedKiller]),
  MonsterType(12, 'Enhance', []),
  MonsterType(14, 'Awoken', []),
  MonsterType(15, 'Vendor', []),
];

var _monsterLookup = Map.fromIterable(_allMonsterTypes, key: (mt) => mt.id);

class KillerLatent {
  int id;
  String name;

  KillerLatent(this.id, this.name);
}

var _godKiller = KillerLatent(20, 'God');
var _dragonKiller = KillerLatent(21, 'Dragon');
var _devilKiller = KillerLatent(22, 'Devil');
var _machineKiller = KillerLatent(23, 'Machine');
var _balancedKiller = KillerLatent(24, 'Balanced');
var _attackerKiller = KillerLatent(25, 'Attacker');
var _physicalKiller = KillerLatent(26, 'Physical');
var _healerKiller = KillerLatent(27, 'Healer');
