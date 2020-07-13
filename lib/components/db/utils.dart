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

/// Temporary hack to fix null-safety for blobs.
class NullSafeDefaultValueSerializer extends ValueSerializer {
  const NullSafeDefaultValueSerializer();

  @override
  T fromJson<T>(dynamic json) {
    if (json == null) {
      return null;
    }
    if (T == DateTime) {
      return DateTime.fromMillisecondsSinceEpoch(json as int) as T;
    }

    if (T == double && json is int) {
      return json.toDouble() as T;
    }

    // blobs are encoded as a regular json array, so we manually convert that to
    // a Uint8List
    if (T == Uint8List && json is! Uint8List) {
      final asList = (json as List).cast<int>();
      return Uint8List.fromList(asList) as T;
    }

    return json as T;
  }

  @override
  dynamic toJson<T>(T value) {
    if (value is DateTime) {
      return value.millisecondsSinceEpoch;
    }

    return value;
  }
}
