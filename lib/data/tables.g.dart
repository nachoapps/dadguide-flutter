// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tables.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps
class MonsterRow extends DataClass {
  final int monsterId;
  MonsterRow({this.monsterId});
  factory MonsterRow.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    return MonsterRow(
      monsterId:
          intType.mapFromDatabaseResponse(data['${effectivePrefix}monster_id']),
    );
  }
  factory MonsterRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer = const ValueSerializer.defaults()}) {
    return MonsterRow(
      monsterId: serializer.fromJson<int>(json['monsterId']),
    );
  }
  @override
  Map<String, dynamic> toJson(
      {ValueSerializer serializer = const ValueSerializer.defaults()}) {
    return {
      'monsterId': serializer.toJson<int>(monsterId),
    };
  }

  MonsterRow copyWith({int monsterId}) => MonsterRow(
        monsterId: monsterId ?? this.monsterId,
      );
  @override
  String toString() {
    return (StringBuffer('MonsterRow(')
          ..write('monsterId: $monsterId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(0, monsterId.hashCode));
  @override
  bool operator ==(other) =>
      identical(this, other) ||
      (other is MonsterRow && other.monsterId == monsterId);
}

class $MonstersTable extends Monsters
    with TableInfo<$MonstersTable, MonsterRow> {
  final GeneratedDatabase _db;
  final String _alias;
  $MonstersTable(this._db, [this._alias]);
  GeneratedIntColumn _monsterId;
  @override
  GeneratedIntColumn get monsterId => _monsterId ??= _constructMonsterId();
  GeneratedIntColumn _constructMonsterId() {
    return GeneratedIntColumn('monster_id', $tableName, false,
        hasAutoIncrement: true);
  }

  @override
  List<GeneratedColumn> get $columns => [monsterId];
  @override
  $MonstersTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'monsters';
  @override
  final String actualTableName = 'monsters';
  @override
  bool validateIntegrity(MonsterRow instance, bool isInserting) =>
      monsterId.isAcceptableValue(instance.monsterId, isInserting);
  @override
  Set<GeneratedColumn> get $primaryKey => {monsterId};
  @override
  MonsterRow map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return MonsterRow.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  Map<String, Variable> entityToSql(MonsterRow d, {bool includeNulls = false}) {
    final map = <String, Variable>{};
    if (d.monsterId != null || includeNulls) {
      map['monster_id'] = Variable<int, IntType>(d.monsterId);
    }
    return map;
  }

  @override
  $MonstersTable createAlias(String alias) {
    return $MonstersTable(_db, alias);
  }
}

class EventRow extends DataClass {
  final int eventId;
  EventRow({this.eventId});
  factory EventRow.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    return EventRow(
      eventId:
          intType.mapFromDatabaseResponse(data['${effectivePrefix}event_id']),
    );
  }
  factory EventRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer = const ValueSerializer.defaults()}) {
    return EventRow(
      eventId: serializer.fromJson<int>(json['eventId']),
    );
  }
  @override
  Map<String, dynamic> toJson(
      {ValueSerializer serializer = const ValueSerializer.defaults()}) {
    return {
      'eventId': serializer.toJson<int>(eventId),
    };
  }

  EventRow copyWith({int eventId}) => EventRow(
        eventId: eventId ?? this.eventId,
      );
  @override
  String toString() {
    return (StringBuffer('EventRow(')..write('eventId: $eventId')..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(0, eventId.hashCode));
  @override
  bool operator ==(other) =>
      identical(this, other) || (other is EventRow && other.eventId == eventId);
}

class $EventsTable extends Events with TableInfo<$EventsTable, EventRow> {
  final GeneratedDatabase _db;
  final String _alias;
  $EventsTable(this._db, [this._alias]);
  GeneratedIntColumn _eventId;
  @override
  GeneratedIntColumn get eventId => _eventId ??= _constructEventId();
  GeneratedIntColumn _constructEventId() {
    return GeneratedIntColumn('event_id', $tableName, false,
        hasAutoIncrement: true);
  }

  @override
  List<GeneratedColumn> get $columns => [eventId];
  @override
  $EventsTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'events';
  @override
  final String actualTableName = 'events';
  @override
  bool validateIntegrity(EventRow instance, bool isInserting) =>
      eventId.isAcceptableValue(instance.eventId, isInserting);
  @override
  Set<GeneratedColumn> get $primaryKey => {eventId};
  @override
  EventRow map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return EventRow.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  Map<String, Variable> entityToSql(EventRow d, {bool includeNulls = false}) {
    final map = <String, Variable>{};
    if (d.eventId != null || includeNulls) {
      map['event_id'] = Variable<int, IntType>(d.eventId);
    }
    return map;
  }

  @override
  $EventsTable createAlias(String alias) {
    return $EventsTable(_db, alias);
  }
}

abstract class _$Database extends GeneratedDatabase {
  _$Database(QueryExecutor e) : super(const SqlTypeSystem.withDefaults(), e);
  $MonstersTable _monsters;
  $MonstersTable get monsters => _monsters ??= $MonstersTable(this);
  $EventsTable _events;
  $EventsTable get events => _events ??= $EventsTable(this);
  @override
  List<TableInfo> get allTables => [monsters, events];
}
