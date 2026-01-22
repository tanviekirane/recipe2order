import 'package:flutter_test/flutter_test.dart';
import 'package:recipe2order/utils/unit_converter.dart';

void main() {
  group('UnitConverter', () {
    group('normalizeUnit', () {
      test('normalizes cup variations', () {
        expect(UnitConverter.normalizeUnit('cup'), equals('cup'));
        expect(UnitConverter.normalizeUnit('cups'), equals('cup'));
        expect(UnitConverter.normalizeUnit('c'), equals('cup'));
        expect(UnitConverter.normalizeUnit('C'), equals('cup'));
      });

      test('normalizes tablespoon variations', () {
        expect(UnitConverter.normalizeUnit('tablespoon'), equals('tbsp'));
        expect(UnitConverter.normalizeUnit('tablespoons'), equals('tbsp'));
        expect(UnitConverter.normalizeUnit('tbsp'), equals('tbsp'));
        expect(UnitConverter.normalizeUnit('Tbsp'), equals('tbsp'));
        expect(UnitConverter.normalizeUnit('tbs'), equals('tbsp'));
      });

      test('normalizes teaspoon variations', () {
        expect(UnitConverter.normalizeUnit('teaspoon'), equals('tsp'));
        expect(UnitConverter.normalizeUnit('teaspoons'), equals('tsp'));
        expect(UnitConverter.normalizeUnit('tsp'), equals('tsp'));
      });

      test('normalizes weight units', () {
        expect(UnitConverter.normalizeUnit('pound'), equals('lb'));
        expect(UnitConverter.normalizeUnit('pounds'), equals('lb'));
        expect(UnitConverter.normalizeUnit('lb'), equals('lb'));
        expect(UnitConverter.normalizeUnit('lbs'), equals('lb'));
        expect(UnitConverter.normalizeUnit('ounce'), equals('oz'));
        expect(UnitConverter.normalizeUnit('ounces'), equals('oz'));
        expect(UnitConverter.normalizeUnit('gram'), equals('g'));
        expect(UnitConverter.normalizeUnit('grams'), equals('g'));
      });

      test('returns null for null input', () {
        expect(UnitConverter.normalizeUnit(null), isNull);
      });

      test('returns lowercase for unknown units', () {
        expect(UnitConverter.normalizeUnit('unknown'), equals('unknown'));
        expect(UnitConverter.normalizeUnit('UNKNOWN'), equals('unknown'));
      });
    });

    group('parseFraction', () {
      test('parses simple integers', () {
        expect(UnitConverter.parseFraction('1'), equals(1.0));
        expect(UnitConverter.parseFraction('10'), equals(10.0));
        expect(UnitConverter.parseFraction('0'), equals(0.0));
      });

      test('parses simple decimals', () {
        expect(UnitConverter.parseFraction('0.5'), equals(0.5));
        expect(UnitConverter.parseFraction('1.25'), equals(1.25));
      });

      test('parses simple fractions', () {
        expect(UnitConverter.parseFraction('1/2'), equals(0.5));
        expect(UnitConverter.parseFraction('1/4'), equals(0.25));
        expect(UnitConverter.parseFraction('3/4'), equals(0.75));
        expect(UnitConverter.parseFraction('2/3'), closeTo(0.667, 0.001));
      });

      test('parses mixed fractions', () {
        expect(UnitConverter.parseFraction('1 1/2'), equals(1.5));
        expect(UnitConverter.parseFraction('2 1/4'), equals(2.25));
        expect(UnitConverter.parseFraction('3 3/4'), equals(3.75));
      });

      test('handles unicode fractions', () {
        expect(UnitConverter.parseFraction('½'), equals(0.5));
        expect(UnitConverter.parseFraction('¼'), equals(0.25));
        expect(UnitConverter.parseFraction('¾'), equals(0.75));
        expect(UnitConverter.parseFraction('1½'), equals(1.5));
      });

      test('returns null for invalid input', () {
        expect(UnitConverter.parseFraction('abc'), isNull);
        expect(UnitConverter.parseFraction(''), isNull);
      });
    });

    group('isKnownUnit', () {
      test('returns true for known units', () {
        expect(UnitConverter.isKnownUnit('cup'), isTrue);
        expect(UnitConverter.isKnownUnit('cups'), isTrue);
        expect(UnitConverter.isKnownUnit('tbsp'), isTrue);
        expect(UnitConverter.isKnownUnit('oz'), isTrue);
        expect(UnitConverter.isKnownUnit('lb'), isTrue);
      });

      test('returns false for unknown units', () {
        expect(UnitConverter.isKnownUnit('unknown'), isFalse);
        expect(UnitConverter.isKnownUnit('xyz'), isFalse);
      });

      test('is case insensitive', () {
        expect(UnitConverter.isKnownUnit('CUP'), isTrue);
        expect(UnitConverter.isKnownUnit('Cup'), isTrue);
        expect(UnitConverter.isKnownUnit('TBSP'), isTrue);
      });
    });
  });
}
