part of '../tables.dart';

@UseDao(
  tables: [
    Exchanges,
    Monsters,
  ],
)
class ExchangesDao extends DatabaseAccessor<DadGuideDatabase> with _$ExchangesDaoMixin {
  ExchangesDao(DadGuideDatabase db) : super(db);

  Future<List<FullExchange>> findExchanges() async {
    var s = Stopwatch()..start();
    final query = select(exchanges);

    var nowTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    query.where(
        (ex) => ex.endTimestamp.isBiggerThanValue(nowTimestamp) | ex.permanent.equals(true));

    var results = await query.get();
    Fimber.d('exchange lookup complete in: ${s.elapsed}');
    return results.map((e) => FullExchange(e)).toList();
  }
}
