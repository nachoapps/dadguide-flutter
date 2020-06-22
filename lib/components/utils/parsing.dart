/// Converts a DadGuide-standard CSV list of ints wrapped in parens into a list of ints.
List<int> parseCsvIntList(String input) {
  input ??= '';
  return input
      .replaceAll('(', '')
      .replaceAll(')', '')
      .split(',')
      .map(int.tryParse)
      .where((item) => item != null)
      .toList();
}
