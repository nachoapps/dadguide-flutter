import 'package:rxdart/rxdart.dart';

enum UpdateStatus {
  /// No update ongoing.
  idle,

  // Update ongoing.
  updating,

  // The update completed successfully. An idle status should be emitted immediately afterwards.
  completed,

  // The update failed. An idle status should be emitted immediately afterwards.
  // An error event should be emitted as well when this occurs.
  error,
}

/// Publishes status events for the updater.
final updateStatusSubject = BehaviorSubject<UpdateStatus>.seeded(UpdateStatus.idle);
