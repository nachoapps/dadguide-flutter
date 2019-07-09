class MonsterType {
  int _id;
  String _name;

  MonsterType(this._id, this._name);

  int get id => _id;
  String get name => _name;
}

MonsterType monsterTypeFor(int id) {
  return _monsterLookup[id];
}

var _allMonsterTypes = [
  MonsterType(0, 'Evo Material'),
  MonsterType(1, 'Balanced'),
  MonsterType(2, 'Physical'),
  MonsterType(3, 'Healer'),
  MonsterType(4, 'Dragon'),
  MonsterType(5, 'God'),
  MonsterType(6, 'Attacker'),
  MonsterType(7, 'Devil'),
  MonsterType(8, 'Machine'),
  MonsterType(12, 'Enhance'),
  MonsterType(14, 'Awoken'),
  MonsterType(15, 'Vendor'),
];

var _monsterLookup = Map.fromIterable(_allMonsterTypes, key: (mt) => mt.id);
