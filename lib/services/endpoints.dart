import 'package:dadguide2/components/config/service_locator.dart';
import 'package:dadguide2/components/utils/version_info.dart';

// This IP can be used to connect to the workstation that your emulator is running on.
final _emulatingMachineId = '10.0.2.2';

/// Returns URLs configured properly for the given arguments.
///
/// This makes switching between local dev and prod easier.
abstract class Endpoints {
  /// Files in the database directory; icons and sqlite db.
  String db(String fileName) {
    return 'https://f002.backblazeb2.com/file/dadguide-data/db/$fileName';
  }

  /// Where to find image files.
  String media(String mediaType, String fileName) {
    return 'https://f002.backblazeb2.com/file/dadguide-data/media/$mediaType/$fileName';
  }

  /// Where to find image files.
  String serverMedia(String mediaType, String server, String fileName) {
    return 'https://f002.backblazeb2.com/file/dadguide-data/media/$mediaType/$server/$fileName';
  }

  /// The update API url for the given table / tstamp.
  String api(String tableName, {int tstamp});

  /// The donor check url.
  String donor(String email);

  /// The submit purchase info url.
  String purchase();
}

/// Right now this points to my personal machine; if you're doing dev work against a local server,
/// update it to point to your own.
class DevEndpoints extends Endpoints {
  String api(String tableName, {int tstamp}) {
    var url = 'http://$_emulatingMachineId:8000/dadguide/api/serve?table=$tableName';
    if (tstamp != null) {
      url += '&tstamp=$tstamp';
    }
    var versionInfo = getIt<VersionInfo>();
    url += '&v=${versionInfo.projectCode}';
    return url;
  }

  String donor(String email) {
    return null;
  }

  String purchase() {
    return 'http://$_emulatingMachineId:8000/dadguide/api/v1/purchases';
  }
}

/// Points to the production server.
class ProdEndpoints extends Endpoints {
  String api(String tableName, {int tstamp}) {
    var url = 'http://miru.info/dadguide/api/serve.php?table=$tableName';
    if (tstamp != null) {
      url += '&tstamp=$tstamp';
    }
    var versionInfo = getIt<VersionInfo>();
    url += '&v=${versionInfo.projectCode}';
    return url;
  }

  String donor(String email) {
    return 'http://miru.info/dadguide/api/serve_donor.php?email=$email';
  }

  String purchase() {
    return 'http://api.miru.info/dadguide/api/v1/purchases';
  }
}
