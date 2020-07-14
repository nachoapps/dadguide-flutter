part of '../local_tables.dart';

@UseDao(tables: [Builds])
class BuildsDao extends DatabaseAccessor<LocalStorageDatabase> with _$BuildsDaoMixin {
  BuildsDao(LocalStorageDatabase db) : super(db);

  ValueStream<List<Build>> buildsStream() {
    return ValueConnectableStream(select(builds).watch())..autoConnect();
  }

  /// Returns an inflated build, required for editing/display.
  /// A non-inflated build is only necessary for the 'list' view.
  Future<Build> inflateBuild(Build build) async {
    var monstersDao = getIt<MonstersDao>();
    final teams = [
      build.team1,
      if (build.team2 != null) build.team2,
      if (build.team3 != null) build.team3,
    ];
    // Inflate the items in the team
    for (var team in teams) {
      for (var m in team.allMonsters) {
        if (m.assist.monsterId != 0) {
          try {
            m.assist.setMonster(await monstersDao.monsterForBuild(m.assist.monsterId));
          } catch (ex) {
            Fimber.e('Failed to load assist', ex: ex);
            m.assist.clear();
          }
        }
        if (m.base.monsterId != 0) {
          try {
            m.base.setMonster(await monstersDao.monsterForBuild(m.base.monsterId));
          } catch (ex) {
            Fimber.e('Failed to load base', ex: ex);
            m.base.clear();
          }
        }
      }
    }
    return build;
  }

  Future<Build> saveBuild(Build build) async {
    try {
      var newId = await into(builds).insert(build, mode: InsertMode.insertOrReplace);
      return build.copyWith(buildId: newId);
    } catch (ex) {
      Fimber.e('Failed to save build', ex: ex);
      return null;
    }
  }

  Future<int> deleteBuild(Build build) async {
    return await delete(builds).delete(build);
  }
}

class EditableBuild {
  final int buildId;
  String title;
  String description;
  Team team1;
  Team team2;
  Team team3;

  EditableBuild({this.buildId, this.title, this.description, this.team1, this.team2, this.team3});
  EditableBuild.copy(Build build)
      : buildId = build.buildId,
        title = build.title,
        description = build.description,
        team1 = build.team1,
        team2 = build.team2,
        team3 = build.team3;

  Build toBuild() {
    return Build(
      buildId: buildId,
      title: title,
      description: description,
      team1: team1,
      team2: team2,
      team3: team3,
    );
  }

  String get displayTitle => title.isEmpty ? 'Untitled' : title;
}
