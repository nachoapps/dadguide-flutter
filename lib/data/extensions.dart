part of 'tables.dart';

// Since we can't edit the generated moor models, this file contains extension methods
// that make using them easier.

// TODO: Remove these from FullMonster
extension MonsterExtension on Monster {
  MonsterType get type1 => MonsterType.byId(type1Id);
  MonsterType get type2 => MonsterType.byId(type2Id);
  MonsterType get type3 => MonsterType.byId(type3Id);
  List<MonsterType> get types => [type1, type2, type3]..removeWhere((e) => e == null);

  OrbType get attr1 => OrbType.byId(attribute1Id);
  OrbType get attr2 => OrbType.byId(attribute2Id);

  Set<Latent> get killers {
    var killers = <Latent>{};
    killers.addAll(type1.killers);
    killers.addAll(type2?.killers ?? []);
    killers.addAll(type3?.killers ?? []);
    return killers;
  }

  bool get isReincarnated => nameNa.toLowerCase().contains('reincarnated') ||
          nameJp.toLowerCase().contains('転生');
}
