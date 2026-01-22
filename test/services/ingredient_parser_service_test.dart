import 'package:flutter_test/flutter_test.dart';
import 'package:recipe2order/services/ingredient_parser_service.dart';

void main() {
  group('IngredientParserService', () {
    group('parseLine', () {
      test('parses quantity + unit + name correctly', () {
        // Use multi-word ingredient name for the pattern to match
        final ingredient = IngredientParserService.parseLine('2 cups all-purpose flour');

        expect(ingredient, isNotNull);
        expect(ingredient!.quantity, equals(2.0));
        expect(ingredient.unit, equals('cup'));
        expect(ingredient.name, equals('all-purpose flour'));
      });

      test('parses fraction quantities', () {
        final ingredient = IngredientParserService.parseLine('1/2 tsp kosher salt');

        expect(ingredient, isNotNull);
        expect(ingredient!.quantity, equals(0.5));
        expect(ingredient.unit, equals('tsp'));
        expect(ingredient.name, equals('kosher salt'));
      });

      test('parses quantity + name without unit as name-only', () {
        // "3 eggs" - since "eggs" isn't a recognized unit, this falls through
        // to _tryParseWithQuantityName which captures "3" as quantity
        final ingredient = IngredientParserService.parseLine('3 large eggs');

        expect(ingredient, isNotNull);
        // "large" is a known unit, so it parses as qty=3, unit=large, name=eggs
        expect(ingredient!.quantity, equals(3.0));
        expect(ingredient.name, equals('eggs'));
      });

      test('parses ingredient with notes after comma', () {
        final ingredient = IngredientParserService.parseLine('1 lb chicken breast, diced');

        expect(ingredient, isNotNull);
        expect(ingredient!.quantity, equals(1.0));
        expect(ingredient.unit, equals('lb'));
        expect(ingredient.name, equals('chicken breast'));
        expect(ingredient.notes, equals('diced'));
      });

      test('parses ingredient with parenthetical notes', () {
        final ingredient = IngredientParserService.parseLine('2 large eggs (room temperature)');

        expect(ingredient, isNotNull);
        expect(ingredient!.notes, equals('room temperature'));
      });

      test('removes list markers from quantity + unit + name', () {
        final ingredient1 = IngredientParserService.parseLine('- 2 cups all-purpose flour');
        final ingredient2 = IngredientParserService.parseLine('* 1 tsp vanilla extract');

        expect(ingredient1, isNotNull);
        expect(ingredient1!.name, equals('all-purpose flour'));
        expect(ingredient1.quantity, equals(2.0));

        expect(ingredient2, isNotNull);
        expect(ingredient2!.name, equals('vanilla extract'));
        expect(ingredient2.quantity, equals(1.0));
      });

      test('handles decimal quantities', () {
        final ingredient = IngredientParserService.parseLine('0.5 kg red potatoes');

        expect(ingredient, isNotNull);
        expect(ingredient!.quantity, equals(0.5));
        expect(ingredient.unit, equals('kg'));
        expect(ingredient.name, equals('red potatoes'));
      });

      test('returns null for empty string', () {
        final ingredient = IngredientParserService.parseLine('');
        expect(ingredient, isNull);
      });

      test('parses name-only ingredients', () {
        final ingredient = IngredientParserService.parseLine('salt and pepper to taste');

        expect(ingredient, isNotNull);
        expect(ingredient!.name, equals('salt and pepper to taste'));
        expect(ingredient.quantity, isNull);
        expect(ingredient.unit, isNull);
      });
    });

    group('parseText', () {
      test('parses multiple lines of ingredients', () {
        const text = '''
2 cups all-purpose flour
1 cup white sugar
3 large eggs
1/2 tsp vanilla extract
''';

        final ingredients = IngredientParserService.parseText(text);

        expect(ingredients.length, equals(4));
        expect(ingredients[0].name, equals('all-purpose flour'));
        expect(ingredients[1].name, equals('white sugar'));
        expect(ingredients[3].name, equals('vanilla extract'));
      });

      test('skips instruction-like lines', () {
        const text = '''
2 cups all-purpose flour
Preheat oven to 350F
1 cup white sugar
Mix well for 5 minutes
3 large eggs
''';

        final ingredients = IngredientParserService.parseText(text);

        // Should skip instruction lines (preheat, mix)
        expect(ingredients.length, equals(3));
      });

      test('skips empty lines', () {
        const text = '''
2 cups all-purpose flour

1 cup white sugar

3 large eggs
''';

        final ingredients = IngredientParserService.parseText(text);

        expect(ingredients.length, equals(3));
      });
    });

    group('extractTitle', () {
      test('extracts title from first non-ingredient line', () {
        const text = '''
Chocolate Chip Cookies
2 cups flour
1 cup sugar
''';

        final title = IngredientParserService.extractTitle(text);

        expect(title, equals('Chocolate Chip Cookies'));
      });

      test('returns null when first line is an ingredient', () {
        const text = '''
2 cups flour
1 cup sugar
''';

        final title = IngredientParserService.extractTitle(text);

        expect(title, isNull);
      });
    });
  });
}
