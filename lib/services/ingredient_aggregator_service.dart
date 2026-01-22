import '../models/list_item.dart';
import '../models/recipe.dart';
import '../utils/logger.dart';

/// Service for aggregating ingredients across multiple recipes
class IngredientAggregatorService {
  IngredientAggregatorService._();

  /// Aggregate ingredients from multiple recipes into list items
  /// Combines ingredients with the same name and unit, summing quantities
  static List<ListItem> aggregateFromRecipes(List<Recipe> recipes) {
    final aggregated = <String, _AggregatedIngredient>{};

    for (final recipe in recipes) {
      for (final ingredient in recipe.ingredients) {
        final key = _createKey(ingredient.name, ingredient.unit);

        if (aggregated.containsKey(key)) {
          // Add to existing
          final existing = aggregated[key]!;
          existing.quantity = _addQuantities(existing.quantity, ingredient.quantity);
          if (!existing.sourceRecipeIds.contains(recipe.id)) {
            existing.sourceRecipeIds.add(recipe.id);
          }
        } else {
          // Create new
          aggregated[key] = _AggregatedIngredient(
            name: ingredient.name,
            unit: ingredient.unit,
            quantity: ingredient.quantity,
            sourceRecipeIds: [recipe.id],
          );
        }
      }
    }

    // Convert to ListItems
    final items = aggregated.values.map((agg) {
      return ListItem(
        ingredientName: agg.name,
        quantity: agg.quantity,
        unit: agg.unit,
        sourceRecipeIds: agg.sourceRecipeIds,
      );
    }).toList();

    // Sort alphabetically by name
    items.sort((a, b) => a.ingredientName.toLowerCase().compareTo(b.ingredientName.toLowerCase()));

    Logger.info(
      'Aggregated ${items.length} items from ${recipes.length} recipes',
      tag: 'IngredientAggregator',
    );

    return items;
  }

  /// Create a key for grouping ingredients
  /// Ingredients with the same name and unit should be combined
  static String _createKey(String name, String? unit) {
    final normalizedName = name.toLowerCase().trim();
    final normalizedUnit = (unit ?? '').toLowerCase().trim();
    return '$normalizedName|$normalizedUnit';
  }

  /// Add two quantities, handling null values
  static double? _addQuantities(double? a, double? b) {
    if (a == null && b == null) return null;
    return (a ?? 0) + (b ?? 0);
  }
}

/// Helper class for aggregation
class _AggregatedIngredient {
  final String name;
  final String? unit;
  double? quantity;
  final List<String> sourceRecipeIds;

  _AggregatedIngredient({
    required this.name,
    this.unit,
    this.quantity,
    required this.sourceRecipeIds,
  });
}
