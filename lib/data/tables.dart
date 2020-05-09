import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dadguide2/components/config/settings_manager.dart';
import 'package:dadguide2/components/models/data_objects.dart';
import 'package:dadguide2/components/models/enums.dart';
import 'package:dadguide2/components/models/stats.dart';
import 'package:dadguide2/components/utils/kana.dart';
import 'package:dadguide2/data/src/utils.dart';
import 'package:dadguide2/proto/utils/enemy_skills_utils.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart' as json_annotation;
import 'package:moor/moor.dart';
import 'package:moor_ffi/moor_ffi.dart';

part 'src/dungeons.dart';
part 'src/egg_machines.dart';
part 'src/exchanges.dart';
part 'src/monsters.dart';
part 'src/monster_search.dart';
part 'src/schedule.dart';
part 'tables.g.dart';

// Classes used for database code generation and the master DadGuideDatabase.
//
// Individual DAOs are split out into separate part files.
//
// There's not really any documentation on what is in these fields. For that you should
// either set up your own personal MySQL instance using the export, or you can refer
// to the python data loader.
//
// You need to run `flutter packages pub run build_runner watch` as described in the README.md
// in order to ensure code gen is executed on update.

class ActiveSkills extends Table {
  IntColumn get activeSkillId => integer().autoIncrement()();

  TextColumn get nameJp => text()();

  TextColumn get nameNa => text()();

  TextColumn get nameKr => text()();

  TextColumn get descJp => text()();

  TextColumn get descNa => text()();

  TextColumn get descKr => text()();

  IntColumn get turnMax => integer()();

  IntColumn get turnMin => integer()();

  TextColumn get tags => text()();

  IntColumn get tstamp => integer()();
}

/// This class is a hack; for some queries we only care about a subset of columns (the turn min/max
/// and tags) so there's no need to retrieve them.
class ActiveSkillsNoText extends Table {
  IntColumn get activeSkillId => integer().autoIncrement()();

  IntColumn get turnMax => integer()();

  IntColumn get turnMin => integer()();

  TextColumn get tags => text()();

  IntColumn get tstamp => integer()();

  @override
  String get tableName => 'active_skills';
}

class ActiveSkillTags extends Table {
  IntColumn get activeSkillTagId => integer().autoIncrement()();

  TextColumn get nameJp => text()();

  TextColumn get nameNa => text()();

  TextColumn get nameKr => text()();

  IntColumn get orderIdx => integer()();

  IntColumn get tstamp => integer()();
}

class Awakenings extends Table {
  IntColumn get awakeningId => integer().autoIncrement()();

  IntColumn get monsterId => integer()();

  IntColumn get awokenSkillId => integer()();

  BoolColumn get isSuper => boolean()();

  IntColumn get orderIdx => integer()();

  IntColumn get tstamp => integer()();
}

class AwokenSkills extends Table {
  IntColumn get awokenSkillId => integer().autoIncrement()();

  TextColumn get nameJp => text()();

  TextColumn get nameNa => text()();

  TextColumn get nameKr => text()();

  TextColumn get descJp => text()();

  TextColumn get descNa => text()();

  TextColumn get descKr => text()();

  IntColumn get adjHp => integer()();

  IntColumn get adjAtk => integer()();

  IntColumn get adjRcv => integer()();

  IntColumn get tstamp => integer()();
}

class Dungeons extends Table {
  IntColumn get dungeonId => integer().autoIncrement()();

  TextColumn get nameJp => text()();

  TextColumn get nameNa => text()();

  TextColumn get nameKr => text()();

  IntColumn get dungeonType => integer()();

  IntColumn get iconId => integer().nullable()();

  TextColumn get rewardJp => text().nullable()();

  TextColumn get rewardNa => text().nullable()();

  TextColumn get rewardKr => text().nullable()();

  TextColumn get rewardIconIds => text().nullable()();

  BoolColumn get visible => boolean()();

  IntColumn get tstamp => integer()();
}

class Drops extends Table {
  IntColumn get dropId => integer().autoIncrement()();

  IntColumn get encounterId => integer()();

  IntColumn get monsterId => integer()();

  IntColumn get tstamp => integer()();
}

class EggMachines extends Table {
  IntColumn get eggMachineId => integer().autoIncrement()();

  IntColumn get serverId => integer()();

  IntColumn get eggMachineTypeId => integer()();

  IntColumn get startTimestamp => integer()();

  IntColumn get endTimestamp => integer()();

  IntColumn get machineRow => integer()();

  IntColumn get machineType => integer()();

  TextColumn get name => text()();

  IntColumn get cost => integer()();

  TextColumn get contents => text()();

  IntColumn get tstamp => integer()();
}

class Encounters extends Table {
  IntColumn get encounterId => integer().autoIncrement()();

  IntColumn get dungeonId => integer()();

  IntColumn get subDungeonId => integer()();

  IntColumn get enemyId => integer()();

  IntColumn get monsterId => integer()();

  IntColumn get stage => integer()();

  TextColumn get commentJp => text().nullable()();

  TextColumn get commentNa => text().nullable()();

  TextColumn get commentKr => text().nullable()();

  IntColumn get amount => integer().nullable()();

  IntColumn get orderIdx => integer()();

  IntColumn get turns => integer()();

  IntColumn get level => integer()();

  IntColumn get hp => integer()();

  IntColumn get atk => integer()();

  IntColumn get defence => integer()();

  IntColumn get tstamp => integer()();
}

@DataClassName("EnemyDataItem")
class EnemyData extends Table {
  IntColumn get enemyId => integer().autoIncrement()();

  IntColumn get status => integer()();

  BlobColumn get behavior => blob()();

  IntColumn get tstamp => integer()();
}

class EnemySkills extends Table {
  IntColumn get enemySkillId => integer().autoIncrement()();

  TextColumn get nameJp => text()();

  TextColumn get nameNa => text()();

  TextColumn get nameKr => text()();

  TextColumn get descJp => text()();

  TextColumn get descNa => text()();

  TextColumn get descKr => text()();

  IntColumn get minHits => integer()();

  IntColumn get maxHits => integer()();

  IntColumn get atkMult => integer()();

  IntColumn get tstamp => integer()();
}

class Evolutions extends Table {
  IntColumn get evolutionId => integer().autoIncrement()();

  IntColumn get evolutionType => integer()();

  IntColumn get fromId => integer()();

  IntColumn get toId => integer()();

  IntColumn get mat1Id => integer().named('mat_1_id')();

  IntColumn get mat2Id => integer().named('mat_2_id').nullable()();

  IntColumn get mat3Id => integer().named('mat_3_id').nullable()();

  IntColumn get mat4Id => integer().named('mat_4_id').nullable()();

  IntColumn get mat5Id => integer().named('mat_5_id').nullable()();

  IntColumn get tstamp => integer()();
}

class Exchanges extends Table {
  IntColumn get exchangeId => integer().autoIncrement()();

  IntColumn get tradeId => integer()();

  IntColumn get serverId => integer()();

  IntColumn get targetMonsterId => integer()();

  TextColumn get requiredMonsterIds => text()();

  IntColumn get requiredCount => integer()();

  IntColumn get startTimestamp => integer()();

  IntColumn get endTimestamp => integer()();

  BoolColumn get permanent => boolean()();

  IntColumn get menuIdx => integer()();

  IntColumn get orderIdx => integer()();

  IntColumn get flags => integer()();

  IntColumn get tstamp => integer()();
}

class LeaderSkills extends Table {
  IntColumn get leaderSkillId => integer().autoIncrement()();

  TextColumn get nameJp => text()();

  TextColumn get nameNa => text()();

  TextColumn get nameKr => text()();

  TextColumn get descJp => text()();

  TextColumn get descNa => text()();

  TextColumn get descKr => text()();

  RealColumn get maxHp => real()();

  RealColumn get maxAtk => real()();

  RealColumn get maxRcv => real()();

  RealColumn get maxShield => real()();

  TextColumn get tags => text()();

  IntColumn get tstamp => integer()();
}

class LeaderSkillTags extends Table {
  IntColumn get leaderSkillTagId => integer().autoIncrement()();

  TextColumn get nameJp => text()();

  TextColumn get nameNa => text()();

  TextColumn get nameKr => text()();

  IntColumn get orderIdx => integer()();

  IntColumn get tstamp => integer()();
}

class LeaderSkillsForSearch extends Table {
  IntColumn get leaderSkillId => integer().autoIncrement()();

  RealColumn get maxHp => real()();

  RealColumn get maxAtk => real()();

  RealColumn get maxRcv => real()();

  RealColumn get maxShield => real()();

  TextColumn get tags => text()();

  @override
  String get tableName => 'leader_skills';
}

class Monsters extends Table {
  IntColumn get monsterId => integer().autoIncrement()();

  IntColumn get monsterNoJp => integer()();

  IntColumn get monsterNoNa => integer()();

  IntColumn get monsterNoKr => integer()();

  TextColumn get nameJp => text()();

  TextColumn get nameNa => text()();

  TextColumn get nameKr => text()();

  TextColumn get pronunciationJp => text()();

  IntColumn get hpMax => integer()();

  IntColumn get hpMin => integer()();

  RealColumn get hpScale => real()();

  IntColumn get atkMax => integer()();

  IntColumn get atkMin => integer()();

  RealColumn get atkScale => real()();

  IntColumn get rcvMax => integer()();

  IntColumn get rcvMin => integer()();

  RealColumn get rcvScale => real()();

  IntColumn get cost => integer()();

  IntColumn get exp => integer()();

  IntColumn get level => integer()();

  IntColumn get rarity => integer()();

  IntColumn get limitMult => integer().nullable()();

  IntColumn get attribute1Id => integer().named('attribute_1_id')();

  IntColumn get attribute2Id => integer().named('attribute_2_id').nullable()();

  IntColumn get leaderSkillId => integer().nullable()();

  IntColumn get activeSkillId => integer().nullable()();

  IntColumn get type1Id => integer().named('type_1_id')();

  IntColumn get type2Id => integer().named('type_2_id').nullable()();

  IntColumn get type3Id => integer().named('type_3_id').nullable()();

  BoolColumn get inheritable => boolean()();

  IntColumn get fodderExp => integer()();

  IntColumn get sellGold => integer()();

  IntColumn get sellMp => integer()();

  IntColumn get buyMp => integer().nullable()();

  TextColumn get regDate => text()();

  BoolColumn get onJp => boolean()();

  BoolColumn get onNa => boolean()();

  BoolColumn get onKr => boolean()();

  BoolColumn get palEgg => boolean()();

  BoolColumn get remEgg => boolean()();

  IntColumn get seriesId => integer()();

  BoolColumn get hasAnimation => boolean()();

  BoolColumn get hasHqimage => boolean()();

  IntColumn get orbSkinId => integer().nullable()();

  IntColumn get voiceIdJp => integer().nullable()();

  IntColumn get voiceIdNa => integer().nullable()();

  IntColumn get linkedMonsterId => integer().nullable()();

  TextColumn get nameNaOverride => text().nullable()();

  IntColumn get tstamp => integer()();
}

@DataClassName("ScheduleEvent")
class Schedule extends Table {
  IntColumn get eventId => integer().autoIncrement()();

  IntColumn get serverId => integer()();

  IntColumn get eventTypeId => integer()();

  IntColumn get startTimestamp => integer()();

  IntColumn get endTimestamp => integer()();

  IntColumn get iconId => integer().nullable()();

  TextColumn get groupName => text().nullable()();

  IntColumn get dungeonId => integer().nullable()();

  TextColumn get url => text().nullable()();

  TextColumn get infoJp => text().nullable()();

  TextColumn get infoNa => text().nullable()();

  TextColumn get infoKr => text().nullable()();

  IntColumn get tstamp => integer()();
}

@DataClassName("SeriesData")
class Series extends Table {
  IntColumn get seriesId => integer().autoIncrement()();

  TextColumn get nameJp => text()();

  TextColumn get nameNa => text()();

  TextColumn get nameKr => text()();

  IntColumn get tstamp => integer()();
}

class SubDungeons extends Table {
  IntColumn get subDungeonId => integer().autoIncrement()();

  IntColumn get dungeonId => integer()();

  TextColumn get nameJp => text()();

  TextColumn get nameNa => text()();

  TextColumn get nameKr => text()();

  TextColumn get rewardJp => text().nullable()();

  TextColumn get rewardNa => text().nullable()();

  TextColumn get rewardKr => text().nullable()();

  TextColumn get rewardIconIds => text().nullable()();

  IntColumn get coinMax => integer().nullable()();

  IntColumn get coinMin => integer().nullable()();

  IntColumn get coinAvg => integer().nullable()();

  IntColumn get expMax => integer().nullable()();

  IntColumn get expMin => integer().nullable()();

  IntColumn get expAvg => integer().nullable()();

  IntColumn get mpAvg => integer().nullable()();

  IntColumn get iconId => integer().nullable()();

  IntColumn get floors => integer()();

  IntColumn get stamina => integer()();

  RealColumn get hpMult => real()();

  RealColumn get atkMult => real()();

  RealColumn get defMult => real()();

  IntColumn get sRank => integer().nullable()();

  TextColumn get rewards => text().nullable()();

  BoolColumn get technical => boolean()();

  IntColumn get tstamp => integer()();
}

class Timestamps extends Table {
  TextColumn get name => text()();

  IntColumn get tstamp => integer()();

  @override
  Set<Column> get primaryKey => {name};
}

@UseMoor(
  daos: [
    DungeonsDao,
    EggMachinesDao,
    ExchangesDao,
    MonstersDao,
    MonsterSearchDao,
    ScheduleDao,
  ],
  tables: [
    ActiveSkills,
    ActiveSkillsNoText,
    ActiveSkillTags,
    Awakenings,
    AwokenSkills,
    Drops,
    Dungeons,
    EggMachines,
    Encounters,
    EnemyData,
    EnemySkills,
    Exchanges,
    Evolutions,
    LeaderSkills,
    LeaderSkillTags,
    LeaderSkillsForSearch,
    Monsters,
    Series,
    Schedule,
    SubDungeons,
    Timestamps,
  ],
  queries: {},
)
class DadGuideDatabase extends _$DadGuideDatabase {
  DadGuideDatabase(String dbPath) : super(VmDatabase(File(dbPath)));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(onCreate: (Migrator m) {
      Fimber.i('Initial database creation; skipping onCreate');
      return null;
    });
  }

  Future<int> maxTstamp(TableInfo info) async {
    var result =
        await customSelect('SELECT MAX(tstamp) AS tstamp from ${info.actualTableName}').get();
    return result.first.readInt('tstamp');
  }

  Future<void> upsertData<TD extends Table, D extends DataClass>(
      TableInfo<TD, D> info, Insertable<D> entity) async {
    await into(info).insert(entity, mode: InsertMode.insertOrReplace);
  }
}
