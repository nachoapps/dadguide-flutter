import 'package:dadguide2/data_local/local_tables.dart';

/// Arguments to the list builds route.
class BuildListArgs {
  static const routeName = '/buildList';
}

/// Arguments to the edit a build route.
class BuildEditArgs {
  static const routeName = '/buildEdit';

  final EditableBuild build;
  BuildEditArgs(this.build);
}

/// Arguments to the view a build route.
class BuildViewArgs {
  static const routeName = '/buildView';

  final EditableBuild build;
  BuildViewArgs(this.build);
}
