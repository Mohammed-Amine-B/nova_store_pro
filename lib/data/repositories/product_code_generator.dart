/// Generates a product code from its name, e.g. "Coca Cola 1L" -> "COCO1L".
/// Words that are purely letters contribute their first 2 letters (uppercased,
/// or just 1 if the word is a single letter). Words containing digits
/// (size/unit tokens like "1L", "500G") are kept whole.
String generateProductCode(String name) {
  final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  final buffer = StringBuffer();
  for (final word in words) {
    final hasDigit = word.contains(RegExp(r'[0-9]'));
    if (hasDigit) {
      buffer.write(word.toUpperCase());
    } else {
      final letters = word.length >= 2 ? word.substring(0, 2) : word;
      buffer.write(letters.toUpperCase());
    }
  }
  final code = buffer.toString();
  return code.isEmpty ? 'PROD' : code;
}