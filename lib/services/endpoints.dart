abstract class Endpoints {
  String media(String mediaType, String fileName);
  String api(String tableName, {int tstamp});
}

class DevEndpoints extends Endpoints {
  String media(String mediaType, String fileName) {
    return null;
  }

  String api(String tableName, {int tstamp}) {
    var url = 'http://192.168.1.108:8000/dadguide/api/serve?table=$tableName';
    if (tstamp != null) {
      url += '&tstamp=$tstamp';
    }
    return url;
  }
}

class ProdEndpoints extends Endpoints {
  String media(String mediaType, String fileName) {
    return null;
  }

  String api(String tableName, {int tstamp}) {
    var url = 'http://miru.info/dadguide/api/serve.php?table=$tableName';
    if (tstamp != null) {
      url += '&tstamp=$tstamp';
    }
    return url;
  }
}
