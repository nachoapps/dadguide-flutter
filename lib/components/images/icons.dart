import 'package:dadguide2/components/config/settings_manager.dart';
import 'package:flutter/widgets.dart';

/// Commonly used icons with their standard sizes.
class DadGuideIcons {
  // TODO: replace these with boxfit/width/height?
  static Widget get mp =>
      SizedBox(width: 12, height: 12, child: Image.asset('assets/images/mp_icon.png'));

  static Widget get largeMp =>
      Image.asset('assets/images/mp_icon.png', width: 18, height: 18, fit: BoxFit.fill);

  static Widget get srank =>
      SizedBox(width: 12, height: 12, child: Image.asset('assets/images/srank.png'));

  static Widget get enOn =>
      SizedBox(width: 24, height: 24, child: Image.asset('assets/images/na_on.png'));

  static Widget get jpOn =>
      SizedBox(width: 24, height: 24, child: Image.asset('assets/images/jp_on.png'));

  static Widget get krOn =>
      SizedBox(width: 24, height: 24, child: Image.asset('assets/images/kr_on.png'));

  static Widget get inheritableBadge => SizedBox(
      child: Image.asset('assets/images/inheritable_badge.png',
          width: 16, height: 16, fit: BoxFit.fill));

  static Widget get currentCountryOn =>
      Image.asset('assets/images/${Prefs.eventCountry.iconOnName}');

  static Image get fire => Image.asset('assets/images/orb_01.png', fit: BoxFit.fill);

  static Image get water => Image.asset('assets/images/orb_02.png', fit: BoxFit.fill);

  static Image get wood => Image.asset('assets/images/orb_03.png', fit: BoxFit.fill);

  static Image get light => Image.asset('assets/images/orb_04.png', fit: BoxFit.fill);

  static Image get dark => Image.asset('assets/images/orb_05.png', fit: BoxFit.fill);
}
