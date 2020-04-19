import 'package:kana/kana.dart';

/// Mapping from Hiragana characters to Katakana ones.
final HIRAGANA_TO_KATAKANA = HIRAGANA_ROMAJI.map((h, r) => MapEntry(h, ROMAJI_KATAKANA[r]));

/// Mapping from Katakana characters to Hiragana ones.
final KATAKANA_TO_HIRAGANA = KATAKANA_ROMAJI.map((k, r) => MapEntry(k, ROMAJI_HIRAGANA[r]));

/// Returns true if the string contains at least one Hiragana character, false otherwise.
bool containsHiragana(String str) {
  for (var h in HIRAGANA_ROMAJI.keys) {
    if (str.contains(h)) {
      return true;
    }
  }
  return false;
}

/// Returns true if the string contains at least one Katakana character, false otherwise.
bool containsKatakana(String str) {
  for (var h in KATAKANA_ROMAJI.keys) {
    if (str.contains(h)) {
      return true;
    }
  }
  return false;
}

/// Replaces every Katakana character with its Hiragana equivalent.
String katakanaToHiragana(String str) {
  for (var entry in KATAKANA_TO_HIRAGANA.entries) {
    str = str.replaceAll(entry.key, entry.value);
  }
  return str;
}

/// Replaces every Hiragana character with its Katakana equivalent.
String hiraganaToKatakana(String str) {
  for (var entry in KATAKANA_TO_HIRAGANA.entries) {
    str = str.replaceAll(entry.key, entry.value);
  }
  return str;
}
