part of '../local_tables.dart';

@UseDao(tables: [Builds])
class BuildsDao extends DatabaseAccessor<LocalStorageDatabase> with _$BuildsDaoMixin {
  BuildsDao(LocalStorageDatabase db) : super(db);

  ValueStream<List<Build>> buildsStream() {
    return ValueConnectableStream(select(builds).watch())..autoConnect();
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
