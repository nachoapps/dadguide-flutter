import 'package:flutter_fimber/flutter_fimber.dart';
import 'package:moor/moor.dart';

Expression<bool> orList(List<Expression<bool>> parts) {
  if (parts.isEmpty) {
    Fimber.e('Critical error; tried to OR an empty list');
    return null;
  } else if (parts.length == 1) {
    return parts.first;
  } else {
    return parts[0] | orList(parts.sublist(1));
  }
}
