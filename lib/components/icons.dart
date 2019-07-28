import 'package:flutter/widgets.dart';

class DadGuideIcons {
  // TODO: replace these with boxfit/width/height?
  static Widget get mp =>
      SizedBox(width: 12, height: 12, child: Image.asset('assets/images/mp_icon.png'));
  static Widget get largeMp =>
      Image.asset('assets/images/mp_icon.png', width: 18, height: 18, fit: BoxFit.fill);
  static Widget get srank =>
      SizedBox(width: 12, height: 12, child: Image.asset('assets/images/srank.png'));
  static Widget get enOn =>
      SizedBox(width: 24, height: 24, child: Image.asset('assets/images/en_on.png'));
  static Widget get jpOn =>
      SizedBox(width: 24, height: 24, child: Image.asset('assets/images/jp_on.png'));
  static Widget get krOn =>
      SizedBox(width: 24, height: 24, child: Image.asset('assets/images/kr_on.png'));
  static Widget get inheritableBadge => SizedBox(
      child: Image.asset('assets/images/inheritable_badge.png',
          width: 16, height: 16, fit: BoxFit.fill));
}
