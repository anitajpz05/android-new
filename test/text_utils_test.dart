import 'package:flutter_test/flutter_test.dart';
import 'package:renotes/utils/text_utils.dart';

void main() {
  group('normalizeText', () {
    test('ignora mayúsculas, acentos y espacios de los extremos', () {
      expect(normalizeText('Metodología'), normalizeText('metodologia'));
      expect(normalizeText('Metodología'), normalizeText('METODOLOGIA'));
      expect(normalizeText('  Estadística  '), 'estadistica');
    });

    test('no elimina la ñ (no es un acento) ni los espacios internos', () {
      expect(normalizeText('Año nuevo'), 'año nuevo');
    });
  });

  group('excerpt', () {
    test('devuelve el texto completo si cabe', () {
      expect(excerpt('Texto corto'), 'Texto corto');
    });

    test('une saltos de línea y recorta con puntos suspensivos', () {
      final result = excerpt('Línea uno\n\nLínea dos ' * 20, maxLength: 30);
      expect(result.endsWith('…'), isTrue);
      expect(result.contains('\n'), isFalse);
      expect(result.length, lessThanOrEqualTo(31));
    });
  });

  test('formatDate usa dd/mm/aaaa hh:mm', () {
    expect(formatDate(DateTime(2026, 3, 5, 9, 7)), '05/03/2026 09:07');
  });
}
