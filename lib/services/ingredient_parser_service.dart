import '../models/ingredient.dart';
import '../utils/logger.dart';
import '../utils/unit_converter.dart';

/// Service for parsing ingredient text into structured Ingredient objects
class IngredientParserService {
  IngredientParserService._();

  /// Parse a block of text containing multiple ingredients
  static List<Ingredient> parseText(String text) {
    final lines = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .where((line) => _isLikelyIngredient(line))
        .toList();

    final ingredients = <Ingredient>[];

    for (final line in lines) {
      final ingredient = parseLine(line);
      if (ingredient != null) {
        ingredients.add(ingredient);
      }
    }

    Logger.info('Parsed ${ingredients.length} ingredients from ${lines.length} lines', tag: 'IngredientParser');
    return ingredients;
  }

  /// Parse a single line of text into an Ingredient
  static Ingredient? parseLine(String line) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) return null;

    // Remove common list markers (-, *, •, numbers with period/paren)
    final cleaned = _removeListMarkers(trimmed);
    if (cleaned.isEmpty) return null;

    // Try different parsing patterns
    final result = _tryParseWithQuantityUnitName(cleaned) ??
        _tryParseWithQuantityName(cleaned) ??
        _tryParseNameOnly(cleaned);

    if (result != null) {
      return result.copyWith(rawText: trimmed);
    }

    return null;
  }

  /// Remove common list markers from the beginning of a line
  static String _removeListMarkers(String line) {
    // Remove: "- ", "* ", "• ", "1. ", "1) ", "1: ", etc.
    // Be careful not to remove quantity numbers like "2 cups"
    // Only remove numbered list markers that have a non-digit after the punctuation
    return line
        .replaceFirst(RegExp(r'^[-*•]\s*'), '')
        .replaceFirst(RegExp(r'^\d+[.):]\s+'), '')  // Only match if followed by space after punctuation
        .trim();
  }

  /// Check if a line looks like an ingredient (vs instruction or other text)
  static bool _isLikelyIngredient(String line) {
    final lower = line.toLowerCase();

    // Skip common non-ingredient patterns
    final skipPatterns = [
      RegExp(r'^(instructions?|directions?|steps?|method|notes?|tips?|serving|prep|cook|total)\s*:?', caseSensitive: false),
      RegExp(r'^(preheat|bake|cook|mix|stir|add|combine|heat|place|set|let|cover|remove)\s', caseSensitive: false),
      RegExp(r'^\d+\s*(minutes?|mins?|hours?|hrs?|seconds?|secs?)\b', caseSensitive: false),
      RegExp(r'(degrees?|°|fahrenheit|celsius)\b', caseSensitive: false),
    ];

    for (final pattern in skipPatterns) {
      if (pattern.hasMatch(lower)) {
        return false;
      }
    }

    // Likely an ingredient if it has quantity patterns or common food words
    final ingredientPatterns = [
      RegExp(r'^\d'), // Starts with number
      RegExp(r'\d+\s*(cup|tbsp|tsp|oz|lb|g|kg|ml|can|pkg|piece)', caseSensitive: false),
      RegExp(r'\d+\/\d+'), // Fraction
      RegExp(r'^(a|an)\s+(pinch|dash|handful)', caseSensitive: false),
    ];

    for (final pattern in ingredientPatterns) {
      if (pattern.hasMatch(lower)) {
        return true;
      }
    }

    // Check for common ingredient words
    final ingredientWords = [
      'flour', 'sugar', 'salt', 'pepper', 'butter', 'oil', 'egg', 'eggs',
      'milk', 'cream', 'cheese', 'chicken', 'beef', 'pork', 'fish',
      'onion', 'garlic', 'tomato', 'potato', 'carrot', 'celery',
      'rice', 'pasta', 'bread', 'water', 'broth', 'stock', 'wine',
      'vanilla', 'cinnamon', 'baking', 'yeast', 'honey', 'maple',
    ];

    for (final word in ingredientWords) {
      if (lower.contains(word)) {
        return true;
      }
    }

    // If line is short (likely a simple ingredient name), include it
    if (line.length < 50 && !line.contains('.')) {
      return true;
    }

    return false;
  }

  /// Try to parse: "2 cups all-purpose flour" or "1/2 tsp salt"
  static Ingredient? _tryParseWithQuantityUnitName(String text) {
    // Pattern: quantity (with optional fraction) + unit + name
    // Quantity can be: integer, decimal, fraction, or mixed number
    // Examples: "2 cups flour", "1 1/2 tbsp sugar", "1/2 tsp salt", "0.5 kg potatoes"
    final pattern = RegExp(
      r'^(\d+(?:\.\d+)?|\d+\s+\d+\/\d+|\d+\/\d+)\s+([a-zA-Z]+\.?)\s+(.+)$',
    );

    final match = pattern.firstMatch(text);
    if (match != null) {
      final quantityStr = match.group(1)!;
      final unitStr = match.group(2)!;
      final rest = match.group(3)!;

      // Verify this looks like a unit
      if (UnitConverter.isKnownUnit(unitStr)) {
        final quantity = UnitConverter.parseFraction(quantityStr);
        final unit = UnitConverter.normalizeUnit(unitStr);
        final (name, notes) = _extractNameAndNotes(rest);

        return Ingredient(
          name: name,
          quantity: quantity,
          unit: unit,
          notes: notes,
        );
      }
    }

    return null;
  }

  /// Try to parse: "3 eggs" or "2 onions, diced"
  static Ingredient? _tryParseWithQuantityName(String text) {
    // Pattern: quantity + name (no unit)
    // Quantity can be: integer, decimal, fraction, or mixed number
    final pattern = RegExp(r'^(\d+(?:\.\d+)?|\d+\s+\d+\/\d+|\d+\/\d+)\s+(.+)$');

    final match = pattern.firstMatch(text);
    if (match != null) {
      final quantityStr = match.group(1)!;
      final rest = match.group(2)!;

      final quantity = UnitConverter.parseFraction(quantityStr);
      final (name, notes) = _extractNameAndNotes(rest);

      return Ingredient(
        name: name,
        quantity: quantity,
        notes: notes,
      );
    }

    return null;
  }

  /// Parse just a name (no quantity)
  static Ingredient? _tryParseNameOnly(String text) {
    if (text.isEmpty) return null;

    final (name, notes) = _extractNameAndNotes(text);

    return Ingredient(
      name: name,
      notes: notes,
    );
  }

  /// Extract ingredient name and any notes/modifications
  /// e.g., "chicken breast, diced" -> ("chicken breast", "diced")
  static (String name, String? notes) _extractNameAndNotes(String text) {
    // Common separators for notes: comma, parentheses, dash
    final commaMatch = RegExp(r'^([^,]+),\s*(.+)$').firstMatch(text);
    if (commaMatch != null) {
      return (commaMatch.group(1)!.trim(), commaMatch.group(2)!.trim());
    }

    final parenMatch = RegExp(r'^([^(]+)\(([^)]+)\)').firstMatch(text);
    if (parenMatch != null) {
      return (parenMatch.group(1)!.trim(), parenMatch.group(2)!.trim());
    }

    return (text.trim(), null);
  }

  /// Try to extract a recipe title from text
  static String? extractTitle(String text) {
    final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

    if (lines.isEmpty) return null;

    // First non-empty line that doesn't look like an ingredient
    for (final line in lines.take(3)) {
      // Skip if it starts with a number (likely an ingredient)
      if (RegExp(r'^\d').hasMatch(line)) continue;
      // Skip if it contains quantity patterns
      if (RegExp(r'\d+\s*(cup|tbsp|tsp|oz|lb|g)', caseSensitive: false).hasMatch(line)) continue;
      // Skip list markers only
      if (RegExp(r'^[-*•]$').hasMatch(line)) continue;

      // Good candidate for title
      if (line.length >= 3 && line.length <= 100) {
        return line;
      }
    }

    return null;
  }
}
