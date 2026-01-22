import 'constants.dart';

/// Validation result with success status and optional error message
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult.valid() : isValid = true, errorMessage = null;
  const ValidationResult.invalid(this.errorMessage) : isValid = false;
}

/// Utility class for validating user input
class InputValidator {
  InputValidator._();

  /// Minimum text length for recipe input
  static const int minTextLength = 10;

  /// Validate recipe text input
  static ValidationResult validateRecipeText(String? text) {
    if (text == null || text.trim().isEmpty) {
      return const ValidationResult.invalid('Please enter recipe text');
    }

    final trimmed = text.trim();

    if (trimmed.length < minTextLength) {
      return ValidationResult.invalid(
        'Text must be at least $minTextLength characters',
      );
    }

    if (trimmed.length > AppConstants.maxTextInputLength) {
      return ValidationResult.invalid(
        'Text cannot exceed ${AppConstants.maxTextInputLength} characters',
      );
    }

    // Check if it looks like it contains ingredients
    if (!_containsIngredientLikeContent(trimmed)) {
      return const ValidationResult.invalid(
        'Text doesn\'t appear to contain ingredients. Try including quantities like "2 cups" or "1 lb"',
      );
    }

    return const ValidationResult.valid();
  }

  /// Validate URL input
  static ValidationResult validateUrl(String? url) {
    if (url == null || url.trim().isEmpty) {
      return const ValidationResult.invalid('Please enter a URL');
    }

    final trimmed = url.trim();

    // Basic URL format check
    final urlPattern = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
      caseSensitive: false,
    );

    if (!urlPattern.hasMatch(trimmed)) {
      return const ValidationResult.invalid(
        'Please enter a valid URL (e.g., https://example.com/recipe)',
      );
    }

    return const ValidationResult.valid();
  }

  /// Validate recipe title
  static ValidationResult validateRecipeTitle(String? title) {
    if (title == null || title.trim().isEmpty) {
      return const ValidationResult.invalid('Please enter a recipe title');
    }

    final trimmed = title.trim();

    if (trimmed.length < 2) {
      return const ValidationResult.invalid(
        'Title must be at least 2 characters',
      );
    }

    if (trimmed.length > 100) {
      return const ValidationResult.invalid(
        'Title cannot exceed 100 characters',
      );
    }

    return const ValidationResult.valid();
  }

  /// Check if text contains ingredient-like content
  static bool _containsIngredientLikeContent(String text) {
    // Look for common ingredient patterns
    final patterns = [
      // Quantity + unit patterns
      RegExp(r'\d+\s*(cup|cups|tbsp|tsp|oz|lb|g|kg|ml|L|tablespoon|teaspoon|ounce|pound|gram)', caseSensitive: false),
      // Fraction patterns
      RegExp(r'\d+\/\d+'),
      // Number at start of line
      RegExp(r'^\d+', multiLine: true),
      // Common ingredients
      RegExp(r'\b(flour|sugar|salt|pepper|butter|oil|egg|milk|water|chicken|beef|onion|garlic)\b', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      if (pattern.hasMatch(text)) {
        return true;
      }
    }

    return false;
  }

  /// Sanitize input text (trim, normalize whitespace)
  static String sanitizeText(String text) {
    return text
        .trim()
        .replaceAll(RegExp(r'\r\n'), '\n') // Normalize line endings
        .replaceAll(RegExp(r'[ \t]+'), ' ') // Collapse horizontal whitespace
        .replaceAll(RegExp(r'\n{3,}'), '\n\n'); // Max 2 consecutive newlines
  }
}
