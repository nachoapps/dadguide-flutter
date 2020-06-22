import 'dart:async';

import 'package:dadguide2/components/config/settings_manager.dart';
import 'package:preferences/preference_service.dart';

/// Wrapper for mutations of favorite monsters; updates a stream when favorites are changed.
///
/// Also contains static methods to get the favorites, but mutations must go through the instance.
class FavoriteManager {
  static final instance = FavoriteManager._internal();
  FavoriteManager._internal();

  final _controller = StreamController<void>.broadcast();

  Stream<void> get updateStream => _controller.stream;

  void add(int monsterId) {
    _addFavoriteMonster(monsterId);
    _controller.add(null);
  }

  void remove(int monsterId) {
    _removeFavoriteMonster(monsterId);
    _controller.add(null);
  }

  void toggle(int monsterId) {
    var favorites = favoriteMonsters;
    if (favorites.contains(monsterId)) {
      favorites.remove(monsterId);
    } else {
      favorites.add(monsterId);
    }
    _favoriteMonsters = favorites;
    _controller.add(null);
  }

  static List<int> get favoriteMonsters =>
      stringToIntList(PrefService.getString(PrefKeys.favoriteMonsters));

  static bool isFavorite(int monsterId) => favoriteMonsters.contains(monsterId);

  static set _favoriteMonsters(Iterable<int> monsters) =>
      PrefService.setString(PrefKeys.favoriteMonsters, monsters.join(','));

  static void _addFavoriteMonster(int monsterId) =>
      _favoriteMonsters = favoriteMonsters..add(monsterId);

  static void _removeFavoriteMonster(int monsterId) =>
      _favoriteMonsters = favoriteMonsters..remove(monsterId);
}
