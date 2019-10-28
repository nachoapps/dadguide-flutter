import 'package:flutter/material.dart';

/// Slightly more compact than body1 with a bolder weight for headers.
TextStyle subtitle(BuildContext context) {
  return Theme.of(context).textTheme.subhead.copyWith(fontWeight: FontWeight.w500);
}

/// A slightly smaller, greyer text for supporting info
TextStyle secondary(BuildContext context) {
  return Theme.of(context).textTheme.body2.copyWith(color: Colors.grey[600]);
}
