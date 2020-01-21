import 'package:dadguide2/l10n/localizations.dart';
import 'package:intl/intl.dart';

class TimedEvent {
  static final longFormat = DateFormat.MMMd().add_jm();
  static final shortFormat = DateFormat.jm();

  final DateTime startTime;
  final DateTime endTime;

  TimedEvent.fromDates(this.startTime, this.endTime);

  TimedEvent(int startTimestamp, int endTimestamp)
      : startTime = DateTime.fromMillisecondsSinceEpoch(startTimestamp * 1000, isUtc: true),
        endTime = DateTime.fromMillisecondsSinceEpoch(endTimestamp * 1000, isUtc: true);

  bool isOpen() {
    var now = DateTime.now();
    return startTime.isBefore(now) && endTime.isAfter(now);
  }

  bool isClosed() {
    var now = DateTime.now();
    return endTime.isBefore(now);
  }

  bool isPending() {
    return !isOpen() && !isClosed();
  }

  int daysUntilClose() {
    var now = DateTime.now();
    return now.difference(endTime).inDays;
  }

  String durationText(DadGuideLocalizations loc, DateTime displayedDate) {
    if (isClosed()) {
      return loc.eventClosed;
    }

    String text = '';
    if (!isOpen()) {
      text = _adjDate(displayedDate, startTime);
    }
    text += ' ~ ';
    text += _adjDate(displayedDate, endTime);

    int deltaDays = daysUntilClose();
    if (deltaDays > 0) {
      var dayText = loc.eventDays(deltaDays);
      text += ' [$dayText]';
    }
    return text.trim();
  }
}

String _adjDate(DateTime displayedDate, DateTime timeToDisplay) {
  displayedDate = displayedDate.toLocal();
  timeToDisplay = timeToDisplay.toLocal();
  if (displayedDate.day != timeToDisplay.day) {
    return TimedEvent.longFormat.format(timeToDisplay);
  } else {
    return TimedEvent.shortFormat.format(timeToDisplay);
  }
}
