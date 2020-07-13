import 'package:flutter_fimber/flutter_fimber.dart';
import 'package:moor/moor.dart';

/// Simplifies or-ing a list of expressions together.
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

// Converts a DadGuide-standard CSV list of ints wrapped in parens into a list of ints.
List<int> parseCsvIntList(String input) {
  input ??= '';
  return input
      .replaceAll('(', '')
      .replaceAll(')', '')
      .split(',')
      .map(int.tryParse)
      .where((item) => item != null)
      .toList();
}
