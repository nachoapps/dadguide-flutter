import 'package:intl/intl.dart';

final _commaFormat = NumberFormat.decimalPattern();

String commaFormat(num value) {
  return _commaFormat.format(value);
}