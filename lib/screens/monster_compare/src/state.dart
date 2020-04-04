import 'package:dadguide2/components/models/data_objects.dart';
import 'package:flutter/foundation.dart';

class CompareState with ChangeNotifier {
  FullMonster left;
  FullMonster right;

  CompareState(this.left, this.right);
}
