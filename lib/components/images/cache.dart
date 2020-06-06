import 'dart:io';
import 'dart:typed_data';

import 'package:fimber/fimber.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Importing this so I can manually bulk cache files which is not supported by the library.
/// ignore: implementation_imports
import 'package:flutter_cache_manager/src/cache_object.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Logs all HTTP requests for the cache (mainly images). Used to verify that the cache is working
/// properly.
Future<FileFetcherResponse> _loggingHttpGetter(String url, {Map<String, String> headers}) async {
  Fimber.v('Retrieving $url');
  var httpResponse = await http.get(url, headers: headers);
  return HttpFileFetcherResponse(httpResponse);
}

/// All images retrieved into the cache are stored forever.
var _foreverDuration = Duration(days: 9999);

/// A version of the cache that enforces all items are stored permanently.
///
/// Also extends the base cache to allow for bulk insertion of cache items.
class PermanentCacheManager extends BaseCacheManager {
  static const key = 'libCachedImageData';

  PermanentCacheManager()
      : super(key,
            maxAgeCacheObject: _foreverDuration,
            maxNrOfCacheObjects: 99999,
            fileFetcher: _loggingHttpGetter);

  @override
  Future<String> getFilePath() async {
    var directory = await getTemporaryDirectory();
    return join(directory.path, key);
  }

  /// TODO: convert to using Endpoints.
  static String urlForImageNamed(String name) {
    return 'https://f002.backblazeb2.com/file/dadguide-data/media/$name';
  }

  /// Stores a file permanently in the cache.
  ///
  /// The returned [File] is saved on disk.
  @override
  Future<File> putFile(String url, Uint8List fileBytes,
      {String eTag,
      Duration maxAge = const Duration(days: 30), // This value is ignored.
      String fileExtension = 'file'}) async {
    return super.putFile(url, fileBytes,
        eTag: null, maxAge: _foreverDuration, fileExtension: fileExtension);
  }

  /// Unzip files directly from an archive into the cache.
  ///
  /// Based on cache_manager.dart:putFile and reimplemented for bulk put efficiency.
  Future<void> storeImageDir(Directory unpackDir, Function progressCallback) async {
    var baseFile = Directory(await getFilePath());
    if (!(await baseFile.exists())) {
      baseFile.createSync(recursive: true);
    }

    final prefix = '${unpackDir.path}/';
    var filesUnpacked = 0;
    var archiveFiles = unpackDir.listSync(recursive: true);
    for (var archiveFile in archiveFiles) {
      if (archiveFile.statSync().type == FileSystemEntityType.directory) {
        // Skip directories.
        continue;
      }

      final fileName = archiveFile.path.substring(prefix.length);
      var url = urlForImageNamed(fileName);
      var relativePath = '${Uuid().v1()}.file';
      var cacheObject = CacheObject(url, relativePath: relativePath);
      cacheObject.validTill = DateTime.now().add(_foreverDuration);
      cacheObject.eTag = null;
      await store.putFile(cacheObject);

      final path = join(baseFile.path, cacheObject.relativePath);
      await archiveFile.rename(path);
      filesUnpacked += 1;
      progressCallback(100 * filesUnpacked ~/ archiveFiles.length);
    }
  }
}
