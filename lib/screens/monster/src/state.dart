import 'package:dadguide2/components/config/service_locator.dart';
import 'package:dadguide2/components/models/data_objects.dart';
import 'package:dadguide2/components/utils/kana.dart';
import 'package:dadguide2/data/tables.dart';
import 'package:fimber_io/fimber_io.dart';
import 'package:rxdart/rxdart.dart';

/// Represents the overall status of the app.
enum MonsterSearchStatus {
  ///
  loading,

  ///
  results,

  ///
  error,
}

class MonsterSearchResults {
  final MonsterSearchStatus status;
  final List<ListMonster> results;

  MonsterSearchResults.loading()
      : status = MonsterSearchStatus.loading,
        results = [];
  MonsterSearchResults.results(this.results) : status = MonsterSearchStatus.results;
  MonsterSearchResults.error()
      : status = MonsterSearchStatus.error,
        results = [];
}

class MonsterSearchBloc {
  final searchResults = BehaviorSubject<MonsterSearchResults>();
  final _dao = getIt<MonsterSearchDao>();

  var lastResults = <ListMonster>[];

  void search(MonsterSearchArgs args) async {
    searchResults.add(MonsterSearchResults.loading());
    try {
      lastResults = await _dao.findListMonsters(args);
      doTextUpdateSearch(args.text);
    } catch (ex) {
      Fimber.e('Failed to search for monsters', ex: ex);
      searchResults.addError(ex);
    }
  }

  void doTextUpdateSearch(String text) {
    text = (text ?? '').trim().toLowerCase();
    var hiraganaText = containsHiragana(text) ? hiraganaToKatakana(text) : null;
    var katakanaText = containsKatakana(text) ? katakanaToHiragana(text) : null;
    if (text.isEmpty) {
      searchResults.add(MonsterSearchResults.results(lastResults));
      return;
    }

    var newResults = <ListMonster>[];
    for (var lm in lastResults) {
      var m = lm.monster;
      var intValue = int.tryParse(text);

      var accept = contains(m.nameJp, text) ||
          contains(m.nameJp, hiraganaText) ||
          contains(m.nameJp, katakanaText) ||
          contains(m.nameNa, text) ||
          contains(m.nameNaOverride, text) ||
          contains(m.nameKr, text) ||
          m.monsterNoJp == intValue ||
          m.monsterNoNa == intValue;
      if (accept) {
        newResults.add(lm);
      }
    }

    searchResults.add(MonsterSearchResults.results(newResults));
  }

  void dispose() {
    searchResults.close();
  }
}

bool contains(String src, String value) {
  return value != null && (src ?? '').toLowerCase().contains(value);
}
