import 'package:dadguide2/components/config/service_locator.dart';
import 'package:dadguide2/components/config/settings_manager.dart';
import 'package:dadguide2/components/firebase/analytics.dart';
import 'package:dadguide2/components/notifications/notifications.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_fimber/flutter_fimber.dart';

// Can be used by ChangeNotifierProviders to trigger updates to the TrackedChip.
class TrackingNotifier with ChangeNotifier {
  void trackingChanged() {
    notifyListeners();
  }
}

/// This is the area on the left in the line above the dungeon name
class TrackedChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var loc = DadGuideLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(3),
      child: Text(loc.trackingTrackedItemText,
          style: Theme.of(context)
              .textTheme
              .caption
              .copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}

/// Displays the menu, trigger by a long press of the dungeon row.
Future<bool> showDungeonMenu(BuildContext context, int dungeonId, bool currentlyTracked) async {
  var loc = DadGuideLocalizations.of(context);
  final addOrRemoveText =
      currentlyTracked ? loc.trackingPopupStopTrackingText : loc.trackingPopupStartTrackingText;

  var value = await showMenu(
    position: _buttonMenuPosition(context),
    context: context,
    items: [
      PopupMenuItem(
        child: Text(addOrRemoveText),
        value: dungeonId,
      )
    ],
  );

  if (value != dungeonId) {
    return currentlyTracked;
  }

  try {
    if (currentlyTracked) {
      await _stopTracking(dungeonId);
    } else {
      await _startTracking(dungeonId);
    }
  } catch (ex, stacktrace) {
    Fimber.e('Failed to swap tracking for $dungeonId from tracked:$currentlyTracked',
        ex: ex, stacktrace: stacktrace);
  }
  return !currentlyTracked;
}

Future<void> _startTracking(int dungeonId) async {
  recordEvent('start_tracking_dungeon');
  Prefs.addTrackedDungeon(dungeonId);
  await getIt<NotificationManager>().ensureEventsScheduled();
}

Future<void> _stopTracking(int dungeonId) async {
  recordEvent('stop_tracking_dungeon');
  Prefs.removeTrackedDungeon(dungeonId);
  await getIt<NotificationManager>().ensureEventsScheduled();
}

/// showMenu() needs to be given the menu position as a parameter.
/// This calculates where the context's Widget was on the screen.
RelativeRect _buttonMenuPosition(BuildContext c) {
  final RenderBox bar = c.findRenderObject();
  final RenderBox overlay = Overlay.of(c).context.findRenderObject();
  final position = RelativeRect.fromRect(
    Rect.fromPoints(
      bar.localToGlobal(bar.size.centerLeft(Offset.zero), ancestor: overlay),
      bar.localToGlobal(bar.size.centerLeft(Offset.zero), ancestor: overlay),
    ),
    Offset.zero & overlay.size,
  );
  return position;
}
