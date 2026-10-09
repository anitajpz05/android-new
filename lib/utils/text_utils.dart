const Map<String, String> _accentMap = {
  'á': 'a', 'à': 'a', 'â': 'a', 'ä': 'a',
  'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
  'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
  'ó': 'o', 'ò': 'o', 'ô': 'o', 'ö': 'o',
  'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
};

/// Normaliza un texto para comparar: quita espacios de los extremos, pasa a
/// minúsculas y elimina acentos. "  Metodología " y "metodologia" dan el mismo
/// resultado.
String normalizeText(String input) {
  final buffer = StringBuffer();
  for (final rune in input.trim().toLowerCase().runes) {
    final char = String.fromCharCode(rune);
    buffer.write(_accentMap[char] ?? char);
  }
  return buffer.toString();
}

/// Extracto de una descripción para las listas: una sola línea y recortada.
String excerpt(String text, {int maxLength = 120}) {
  final flat = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (flat.length <= maxLength) return flat;
  return '${flat.substring(0, maxLength).trimRight()}…';
}

/// Formato de fecha dd/mm/aaaa hh:mm, sin depender de paquetes externos.
String formatDate(DateTime date) {
  String two(int value) => value.toString().padLeft(2, '0');
  return '${two(date.day)}/${two(date.month)}/${date.year} '
      '${two(date.hour)}:${two(date.minute)}';
}
