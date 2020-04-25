import 'package:moor/src/runtime/expressions/expression.dart'; // ignore: implementation_imports
import 'package:flutter_fimber/flutter_fimber.dart';
import 'package:moor_flutter/moor_flutter.dart';

Expression<bool, BoolType> orList(List<Expression<bool, BoolType>> parts) {
  if (parts.isEmpty) {
    Fimber.e('Critical error; tried to OR an empty list');
    return null;
  } else if (parts.length == 1) {
    return parts.first;
  } else {
    return or(parts[0], orList(parts.sublist(1)));
  }
}
