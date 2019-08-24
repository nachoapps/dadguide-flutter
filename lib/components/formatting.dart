import 'package:intl/intl.dart';

final _commaFormat = NumberFormat.decimalPattern();

/// Displays a number with commas (or other separators depending on locale).
String commaFormat(num value) {
  return _commaFormat.format(value);
}
