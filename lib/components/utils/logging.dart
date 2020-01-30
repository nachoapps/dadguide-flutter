import 'package:flutter_fimber/flutter_fimber.dart';
import 'package:path_provider/path_provider.dart';

final _fimberTree = FimberTree();
var _fileTree;

/// Initializes the static console logger.
void initLogging() {
  Fimber.plantTree(_fimberTree);
}

/// Initializes the file logger, which requires async calls to find the tempdir.
Future<void> initAsyncLogging() async {
  try {
    var tempDir = await getTemporaryDirectory();
    await tempDir.create(recursive: true);
    _fileTree = SizeRollingFileTree(DataSize(kilobytes: 10), filenamePrefix: '${tempDir.path}/log');
    Fimber.plantTree(_fileTree);
    Fimber.w('File logger init complete');
  } catch (e) {
    Fimber.e('Failed to init file logger', ex: e);
  }
}

/// Gets the current log file path. May return null if the logging failed to initialize.
String loggingFilePath() => _fileTree?.outputFileName;
