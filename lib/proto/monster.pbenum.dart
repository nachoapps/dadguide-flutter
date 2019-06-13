///
//  Generated code. Do not modify.
//  source: protos/monster.proto
///
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name

// ignore_for_file: UNDEFINED_SHOWN_NAME,UNUSED_SHOWN_NAME
import 'dart:core' as $core show int, dynamic, String, List, Map;
import 'package:protobuf/protobuf.dart' as $pb;

class MonsterType extends $pb.ProtobufEnum {
  static const MonsterType UNKNOWN_MONSTER_TYPE = MonsterType._(0, 'UNKNOWN_MONSTER_TYPE');
  static const MonsterType GOD = MonsterType._(1, 'GOD');
  static const MonsterType WORK = MonsterType._(2, 'WORK');

  static const $core.List<MonsterType> values = <MonsterType> [
    UNKNOWN_MONSTER_TYPE,
    GOD,
    WORK,
  ];

  static final $core.Map<$core.int, MonsterType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static MonsterType valueOf($core.int value) => _byValue[value];

  const MonsterType._($core.int v, $core.String n) : super(v, n);
}

class Awakening extends $pb.ProtobufEnum {
  static const Awakening UNKNOWN_AWAKENING = Awakening._(0, 'UNKNOWN_AWAKENING');
  static const Awakening HP_BOOST = Awakening._(1, 'HP_BOOST');

  static const $core.List<Awakening> values = <Awakening> [
    UNKNOWN_AWAKENING,
    HP_BOOST,
  ];

  static final $core.Map<$core.int, Awakening> _byValue = $pb.ProtobufEnum.initByValue(values);
  static Awakening valueOf($core.int value) => _byValue[value];

  const Awakening._($core.int v, $core.String n) : super(v, n);
}

