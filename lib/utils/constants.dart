/// App-wide constants for Recipe2Order
class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'Recipe2Order';
  static const String appVersion = '1.0.0';

  // Limits
  static const int maxRecipesPerList = 20;
  static const int maxIngredientsPerRecipe = 100;
  static const int maxTextInputLength = 5000;
  static const int ingredientParsingTimeoutSeconds = 30;

  // Storage keys
  static const String storageKeyRecipes = 'saved_recipes';
  static const String storageKeyShoppingLists = 'shopping_lists';
  static const String storageKeyThemeMode = 'theme_mode';
  static const String storageKeyOnboardingComplete = 'onboarding_complete';

  // Database
  static const String databaseName = 'recipe2order.db';
  static const int databaseVersion = 1;

  // Animation durations (milliseconds)
  static const int animationDurationShort = 200;
  static const int animationDurationMedium = 300;
  static const int animationDurationLong = 500;
}
