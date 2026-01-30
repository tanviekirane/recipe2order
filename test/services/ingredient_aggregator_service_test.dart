import 'package:flutter_test/flutter_test.dart';
import 'package:recipe2order/models/ingredient.dart';
import 'package:recipe2order/models/recipe.dart';
import 'package:recipe2order/services/ingredient_aggregator_service.dart';

void main() {
  group('IngredientAggregatorService', () {
    group('aggregateFromRecipes', () {
      test('aggregates ingredients from multiple recipes', () {
        final recipe1 = Recipe(
          id: 'recipe1',
          title: 'Recipe 1',
          source: RecipeSource.text,
          ingredients: [
            Ingredient(name: 'flour', quantity: 2, unit: 'cup'),
            Ingredient(name: 'sugar', quantity: 1, unit: 'cup'),
          ],
        );

        final recipe2 = Recipe(
          id: 'recipe2',
          title: 'Recipe 2',
          source: RecipeSource.text,
          ingredients: [
            Ingredient(name: 'flour', quantity: 1, unit: 'cup'),
            Ingredient(name: 'eggs', quantity: 3),
          ],
        );

        final items = IngredientAggregatorService.aggregateFromRecipes([recipe1, recipe2]);

        expect(items.length, equals(3)); // flour, sugar, eggs

        // Find flour item - should be combined (2 + 1 = 3 cups)
        final flour = items.firstWhere((i) => i.ingredientName == 'flour');
        expect(flour.quantity, equals(3.0));
        expect(flour.unit, equals('cup'));
        expect(flour.sourceRecipeIds.length, equals(2));

        // Find sugar item - only from recipe1
        final sugar = items.firstWhere((i) => i.ingredientName == 'sugar');
        expect(sugar.quantity, equals(1.0));
        expect(sugar.sourceRecipeIds.length, equals(1));

        // Find eggs item - only from recipe2
        final eggs = items.firstWhere((i) => i.ingredientName == 'eggs');
        expect(eggs.quantity, equals(3.0));
        expect(eggs.unit, isNull);
      });

      test('handles empty recipe list', () {
        final items = IngredientAggregatorService.aggregateFromRecipes([]);
        expect(items, isEmpty);
      });

      test('handles recipes with no ingredients', () {
        final recipe = Recipe(
          id: 'recipe1',
          title: 'Empty Recipe',
          source: RecipeSource.text,
          ingredients: [],
        );

        final items = IngredientAggregatorService.aggregateFromRecipes([recipe]);
        expect(items, isEmpty);
      });

      test('does not combine ingredients with different units', () {
        final recipe1 = Recipe(
          id: 'recipe1',
          title: 'Recipe 1',
          source: RecipeSource.text,
          ingredients: [
            Ingredient(name: 'butter', quantity: 2, unit: 'tbsp'),
          ],
        );

        final recipe2 = Recipe(
          id: 'recipe2',
          title: 'Recipe 2',
          source: RecipeSource.text,
          ingredients: [
            Ingredient(name: 'butter', quantity: 1, unit: 'stick'),
          ],
        );

        final items = IngredientAggregatorService.aggregateFromRecipes([recipe1, recipe2]);

        // Should have 2 separate butter items (different units)
        final butterItems = items.where((i) => i.ingredientName == 'butter').toList();
        expect(butterItems.length, equals(2));
      });

      test('combines ingredients case-insensitively', () {
        final recipe1 = Recipe(
          id: 'recipe1',
          title: 'Recipe 1',
          source: RecipeSource.text,
          ingredients: [
            Ingredient(name: 'Flour', quantity: 1, unit: 'cup'),
          ],
        );

        final recipe2 = Recipe(
          id: 'recipe2',
          title: 'Recipe 2',
          source: RecipeSource.text,
          ingredients: [
            Ingredient(name: 'flour', quantity: 1, unit: 'cup'),
          ],
        );

        final items = IngredientAggregatorService.aggregateFromRecipes([recipe1, recipe2]);

        // Should combine into one item
        expect(items.length, equals(1));
        expect(items.first.quantity, equals(2.0));
      });

      test('handles null quantities', () {
        final recipe1 = Recipe(
          id: 'recipe1',
          title: 'Recipe 1',
          source: RecipeSource.text,
          ingredients: [
            Ingredient(name: 'salt'),
          ],
        );

        final recipe2 = Recipe(
          id: 'recipe2',
          title: 'Recipe 2',
          source: RecipeSource.text,
          ingredients: [
            Ingredient(name: 'salt'),
          ],
        );

        final items = IngredientAggregatorService.aggregateFromRecipes([recipe1, recipe2]);

        expect(items.length, equals(1));
        // When both quantities are null, result should be null (or 0)
        final salt = items.first;
        expect(salt.ingredientName, equals('salt'));
      });

      test('sorts items alphabetically', () {
        final recipe = Recipe(
          id: 'recipe1',
          title: 'Recipe 1',
          source: RecipeSource.text,
          ingredients: [
            Ingredient(name: 'zucchini', quantity: 1),
            Ingredient(name: 'apple', quantity: 2),
            Ingredient(name: 'milk', quantity: 1, unit: 'cup'),
          ],
        );

        final items = IngredientAggregatorService.aggregateFromRecipes([recipe]);

        expect(items[0].ingredientName, equals('apple'));
        expect(items[1].ingredientName, equals('milk'));
        expect(items[2].ingredientName, equals('zucchini'));
      });
    });
  });
}
