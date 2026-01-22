/// Utility class for normalizing and converting cooking units
class UnitConverter {
  UnitConverter._();

  /// Common unit normalizations (various forms -> standard form)
  static const Map<String, String> _unitNormalization = {
    // Cups
    'cup': 'cup',
    'cups': 'cup',
    'c': 'cup',
    'c.': 'cup',

    // Tablespoons
    'tablespoon': 'tbsp',
    'tablespoons': 'tbsp',
    'tbsp': 'tbsp',
    'tbsps': 'tbsp',
    'tbs': 'tbsp',
    'tb': 'tbsp',
    't': 'tbsp',

    // Teaspoons
    'teaspoon': 'tsp',
    'teaspoons': 'tsp',
    'tsp': 'tsp',
    'tsps': 'tsp',
    'ts': 'tsp',

    // Ounces
    'ounce': 'oz',
    'ounces': 'oz',
    'oz': 'oz',
    'oz.': 'oz',

    // Pounds
    'pound': 'lb',
    'pounds': 'lb',
    'lb': 'lb',
    'lbs': 'lb',
    'lb.': 'lb',

    // Grams
    'gram': 'g',
    'grams': 'g',
    'g': 'g',
    'gm': 'g',
    'gr': 'g',

    // Kilograms
    'kilogram': 'kg',
    'kilograms': 'kg',
    'kg': 'kg',
    'kilo': 'kg',
    'kilos': 'kg',

    // Milliliters
    'milliliter': 'ml',
    'milliliters': 'ml',
    'ml': 'ml',
    'mls': 'ml',

    // Liters
    'liter': 'L',
    'liters': 'L',
    'litre': 'L',
    'litres': 'L',
    'l': 'L',

    // Pieces/whole items
    'piece': 'piece',
    'pieces': 'piece',
    'pc': 'piece',
    'pcs': 'piece',

    // Pinch
    'pinch': 'pinch',
    'pinches': 'pinch',

    // Dash
    'dash': 'dash',
    'dashes': 'dash',

    // Clove
    'clove': 'clove',
    'cloves': 'clove',

    // Bunch
    'bunch': 'bunch',
    'bunches': 'bunch',

    // Can
    'can': 'can',
    'cans': 'can',

    // Package
    'package': 'pkg',
    'packages': 'pkg',
    'pkg': 'pkg',
    'pkgs': 'pkg',
    'packet': 'pkg',
    'packets': 'pkg',

    // Slice
    'slice': 'slice',
    'slices': 'slice',

    // Stick
    'stick': 'stick',
    'sticks': 'stick',

    // Head
    'head': 'head',
    'heads': 'head',

    // Sprig
    'sprig': 'sprig',
    'sprigs': 'sprig',

    // Whole/each
    'whole': 'whole',
    'each': 'each',
    'large': 'large',
    'medium': 'medium',
    'small': 'small',
  };

  /// Display names for normalized units
  static const Map<String, String> _unitDisplayNames = {
    'cup': 'cup',
    'tbsp': 'tbsp',
    'tsp': 'tsp',
    'oz': 'oz',
    'lb': 'lb',
    'g': 'g',
    'kg': 'kg',
    'ml': 'ml',
    'L': 'L',
    'piece': 'piece',
    'pinch': 'pinch',
    'dash': 'dash',
    'clove': 'clove',
    'bunch': 'bunch',
    'can': 'can',
    'pkg': 'pkg',
    'slice': 'slice',
    'stick': 'stick',
    'head': 'head',
    'sprig': 'sprig',
    'whole': 'whole',
    'each': 'each',
    'large': 'large',
    'medium': 'medium',
    'small': 'small',
  };

  /// List of all recognized units
  static List<String> get allUnits => _unitDisplayNames.keys.toList();

  /// Normalize a unit string to its standard form
  static String? normalizeUnit(String? unit) {
    if (unit == null || unit.isEmpty) return null;

    final normalized = _unitNormalization[unit.toLowerCase().trim()];
    return normalized ?? unit.toLowerCase().trim();
  }

  /// Get display name for a unit
  static String getDisplayName(String? unit) {
    if (unit == null || unit.isEmpty) return '';
    final normalized = normalizeUnit(unit);
    return _unitDisplayNames[normalized] ?? normalized ?? unit;
  }

  /// Check if a string is a known unit
  static bool isKnownUnit(String text) {
    return _unitNormalization.containsKey(text.toLowerCase().trim());
  }

  /// Parse a fraction string to double (e.g., "1/2" -> 0.5, "1 1/2" -> 1.5)
  static double? parseFraction(String text) {
    final trimmed = text.trim();

    // Try simple number first
    final simple = double.tryParse(trimmed);
    if (simple != null) return simple;

    // Try mixed number (e.g., "1 1/2")
    final mixedMatch = RegExp(r'^(\d+)\s+(\d+)/(\d+)$').firstMatch(trimmed);
    if (mixedMatch != null) {
      final whole = int.parse(mixedMatch.group(1)!);
      final numerator = int.parse(mixedMatch.group(2)!);
      final denominator = int.parse(mixedMatch.group(3)!);
      if (denominator != 0) {
        return whole + (numerator / denominator);
      }
    }

    // Try simple fraction (e.g., "1/2")
    final fractionMatch = RegExp(r'^(\d+)/(\d+)$').firstMatch(trimmed);
    if (fractionMatch != null) {
      final numerator = int.parse(fractionMatch.group(1)!);
      final denominator = int.parse(fractionMatch.group(2)!);
      if (denominator != 0) {
        return numerator / denominator;
      }
    }

    // Try unicode fractions
    const unicodeFractions = {
      '½': 0.5,
      '⅓': 0.333,
      '⅔': 0.667,
      '¼': 0.25,
      '¾': 0.75,
      '⅕': 0.2,
      '⅖': 0.4,
      '⅗': 0.6,
      '⅘': 0.8,
      '⅙': 0.167,
      '⅚': 0.833,
      '⅛': 0.125,
      '⅜': 0.375,
      '⅝': 0.625,
      '⅞': 0.875,
    };

    // Handle mixed unicode (e.g., "1½")
    for (final entry in unicodeFractions.entries) {
      if (trimmed.contains(entry.key)) {
        final parts = trimmed.split(entry.key);
        final wholePart = parts[0].trim();
        final whole = wholePart.isEmpty ? 0 : (int.tryParse(wholePart) ?? 0);
        return whole + entry.value;
      }
    }

    return null;
  }
}
