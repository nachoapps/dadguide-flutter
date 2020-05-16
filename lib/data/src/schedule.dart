part of '../tables.dart';

class EventSearchArgs {
  List<Country> servers = Country.all;
  List<StarterDragon> starters = StarterDragon.all;
  ScheduleTabKey tab = ScheduleTabKey.all;
  DateTime dateStart = DateTime.now();
  DateTime dateEnd = DateTime.now().add(Duration(days: 1));
  bool hideClosed = false;

  EventSearchArgs();
  EventSearchArgs.from(
      this.servers, this.starters, this.tab, this.dateStart, this.dateEnd, this.hideClosed);

  List<int> get serverIds => servers.map((c) => c.id).toList();
  List<String> get starterNames => starters.map((s) => s.nameCode).toList();
}

@UseDao(
  tables: [
    Dungeons,
    Schedule,
  ],
)
class ScheduleDao extends DatabaseAccessor<DadGuideDatabase> with _$ScheduleDaoMixin {
  ScheduleDao(DadGuideDatabase db) : super(db);

  Future<List<ListEvent>> findListEvents(EventSearchArgs args) async {
    var s = Stopwatch()..start();
    final query = (select(schedule).join([
      leftOuterJoin(dungeons, dungeons.dungeonId.equalsExp(schedule.dungeonId)),
    ]));

    if (args.serverIds.isNotEmpty) {
      query.where(schedule.serverId.isIn(args.serverIds));
    }

    int dateStartTimestamp = args.dateStart.millisecondsSinceEpoch ~/ 1000;
    int dateEndTimestamp = args.dateEnd.millisecondsSinceEpoch ~/ 1000;
    var inDateRangePredicate = schedule.startTimestamp.isSmallerThanValue(dateEndTimestamp) &
        schedule.endTimestamp.isBiggerThanValue(dateStartTimestamp);

    var nowTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    var finalPredicate = args.hideClosed
        ? inDateRangePredicate & schedule.endTimestamp.isBiggerThanValue(nowTimestamp)
        : inDateRangePredicate;

    query.where(finalPredicate);

    var results = await query.get().then((rows) {
      return rows.map((row) {
        return ListEvent(row.readTable(schedule), row.readTable(dungeons));
      }).toList();
    });

    results = results.where((e) {
      var groupName = e.event.groupName;
      var isSpecial = groupName == null;
      var passesGroupFilter = isSpecial || args.starterNames.contains(groupName);
      if (args.tab == ScheduleTabKey.all) {
        return passesGroupFilter;
      } else if (args.tab == ScheduleTabKey.special) {
        return isSpecial;
      } else if (args.tab == ScheduleTabKey.guerrilla) {
        return !isSpecial && passesGroupFilter;
      } else {
        return false;
      }
    }).toList();

    Fimber.d('events lookup complete in: ${s.elapsed} with ${results.length} values');
    return results;
  }
}
