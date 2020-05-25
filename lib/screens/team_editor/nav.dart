import 'package:dadguide2/screens/team_editor/team_data.dart';

/// Arguments to the list teams route.
class TeamListArgs {
  static const routeName = '/teamList';
}

/// Arguments to the edit a team route.
class TeamEditArgs {
  static const routeName = '/teamEdit';

  final Team team;
  TeamEditArgs(this.team);
}

/// Arguments to the view a team route.
class TeamViewArgs {
  static const routeName = '/teamView';

  final Team team;
  TeamViewArgs(this.team);
}
