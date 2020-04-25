part of 'tables.dart';

@UseDao(
  tables: [
    EggMachines,
    Monsters,
  ],
)
class EggMachinesDao extends DatabaseAccessor<DadGuideDatabase> with _$EggMachinesDaoMixin {
  EggMachinesDao(DadGuideDatabase db) : super(db);

  Future<List<FullEggMachine>> findEggMachines() async {
    var s = new Stopwatch()..start();
    final query = select(eggMachines);

    var nowTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    query.where((em) => em.endTimestamp.isBiggerThanValue(nowTimestamp));

    var results = <FullEggMachine>[];
    var queryResults = await query.get();
    for (var em in queryResults) {
      var eggMonsters = <EggMachineMonster>[];
      try {
        var contents = json.decode(em.contents);
        for (var entry in contents.entries) {
          try {
            var monsterIdStr = entry.key as String;
            var rate = entry.value as num;
            var monsterId = int.parse(monsterIdStr.replaceAll(new RegExp(r'\(|\)'), ''));
            var monsterQuery = select(monsters)..where((m) => m.monsterId.equals(monsterId));
            var loadedMonster = await monsterQuery.getSingle();
            eggMonsters.add(EggMachineMonster(loadedMonster, rate.toDouble()));
          } catch (ex) {
            Fimber.e('Failed to parse monster in egg machine $entry', ex: ex);
          }
        }
        results.add(FullEggMachine(em, eggMonsters));
      } catch (ex) {
        Fimber.e('Could not decode egg machine json', ex: ex);
      }
    }

    Fimber.d('egg machine lookup complete in: ${s.elapsed}');
    return results;
  }
}