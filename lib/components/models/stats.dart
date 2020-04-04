import 'package:dadguide2/data/tables.dart';

/// Simplifies the process of calculating various monster stat adjustments.
///
/// Also provides a getter for the weighted value.
class StatHolder {
  final int hp;
  final int atk;
  final int rcv;
  final int limitMult;

  final bool is297;
  final bool isLimitBroken;

  StatHolder(this.hp, this.atk, this.rcv, this.limitMult,
      {this.is297 = false, this.isLimitBroken = false});

  StatHolder.monster(Monster m)
      : hp = m.hpMax,
        atk = m.atkMax,
        rcv = m.rcvMax,
        limitMult = m.limitMult,
        is297 = false,
        isLimitBroken = false;

  int get weighted => (hp / 10 + atk / 5 + rcv / 3).round();
  int get weightedHp => (hp / 10).round();
  int get weightedAtk => (atk / 5).round();
  int get weightedRcv => (rcv / 3).round();

  StatHolder maxPlus() {
    if (is297) throw Exception('already 297');
    return StatHolder(
      hp + 99 * 10,
      atk + 99 * 5,
      rcv + 99 * 3,
      limitMult,
      is297: true,
      isLimitBroken: isLimitBroken,
    );
  }

  StatHolder limitBreak() {
    if (limitMult == null || limitMult == 100) throw Exception('monster cant lb');
    if (is297) throw Exception('already 297, cant lb');
    if (isLimitBroken) throw Exception('already lb');
    return StatHolder(
      (hp * limitMult / 100).round(),
      (atk * limitMult / 100).round(),
      (rcv * limitMult / 100).round(),
      limitMult,
      is297: false,
      isLimitBroken: true,
    );
  }

  StatHolder adjust(int extraHp, int extraAtk, int extraRcv) {
    return StatHolder(
      hp + extraHp,
      atk + extraAtk,
      rcv + extraRcv,
      limitMult,
      is297: is297,
      isLimitBroken: isLimitBroken,
    );
  }
}

/// Holder for comparison of a monster against it's peers at a given rarity.
class StatComparison {
  final int rarity;
  final int hpAbove;
  final int hpBelow;
  final int atkAbove;
  final int atkBelow;
  final int rcvAbove;
  final int rcvBelow;
  final int weightedAbove;
  final int weightedBelow;

  StatComparison(this.rarity, this.hpAbove, this.hpBelow, this.atkAbove, this.atkBelow,
      this.rcvAbove, this.rcvBelow, this.weightedAbove, this.weightedBelow);

  double get hpPct => hpBelow / (hpAbove + hpBelow);
  double get atkPct => atkBelow / (atkAbove + atkBelow);
  double get rcvPct => rcvBelow / (rcvAbove + rcvBelow);
  double get weightedPct => weightedBelow / (weightedAbove + weightedBelow);
}
