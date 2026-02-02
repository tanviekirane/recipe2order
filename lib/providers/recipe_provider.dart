import 'package:flutter/foundation.dart';

import '../models/ingredient.dart';
import '../models/recipe.dart';
import '../utils/logger.dart';

/// Provider for managing recipes state
class RecipeProvider extends ChangeNotifier {
  final List<Recipe> _recipes = [];
  bool _isLoading = false;
  String? _error;

  // Temporary state for recipe being created/edited
  List<Ingredient> _pendingIngredients = [];
  String? _pendingTitle;
  RecipeSource? _pendingSource;
  String? _pendingSourceUrl;
  String? _pendingRawText;

  List<Recipe> get recipes => List.unmodifiable(_recipes);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasRecipes => _recipes.isNotEmpty;

  /// Check if a recipe name already exists (case-insensitive)
  bool nameExists(String name, {String? excludeId}) {
    final lowerName = name.toLowerCase().trim();
    return _recipes.any((recipe) =>
        recipe.title.toLowerCase().trim() == lowerName &&
        (excludeId == null || recipe.id != excludeId));
  }

  /// Get a unique name by appending a number if needed
  String getUniqueName(String baseName) {
    if (!nameExists(baseName)) return baseName;
    int counter = 2;
    while (nameExists('$baseName ($counter)')) {
      counter++;
    }
    return '$baseName ($counter)';
  }

  // Pending recipe getters
  List<Ingredient> get pendingIngredients => List.unmodifiable(_pendingIngredients);
  String? get pendingTitle => _pendingTitle;

  /// Add a new recipe
  void addRecipe(Recipe recipe) {
    _recipes.insert(0, recipe); // Add to beginning (newest first)
    Logger.info('Added recipe: ${recipe.title}', tag: 'RecipeProvider');
    notifyListeners();
  }

  /// Update an existing recipe
  void updateRecipe(Recipe recipe) {
    final index = _recipes.indexWhere((r) => r.id == recipe.id);
    if (index != -1) {
      _recipes[index] = recipe;
      Logger.info('Updated recipe: ${recipe.title}', tag: 'RecipeProvider');
      notifyListeners();
    }
  }

  /// Delete a recipe by ID
  void deleteRecipe(String id) {
    _recipes.removeWhere((r) => r.id == id);
    Logger.info('Deleted recipe: $id', tag: 'RecipeProvider');
    notifyListeners();
  }

  /// Get a recipe by ID
  Recipe? getRecipeById(String id) {
    try {
      return _recipes.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Start creating a new recipe (set pending state)
  void startNewRecipe({
    required RecipeSource source,
    String? sourceUrl,
    String? rawText,
  }) {
    _pendingIngredients = [];
    _pendingTitle = null;
    _pendingSource = source;
    _pendingSourceUrl = sourceUrl;
    _pendingRawText = rawText;
    _error = null;
    Logger.debug('Started new recipe from $source', tag: 'RecipeProvider');
  }

  /// Set pending ingredients after parsing
  void setPendingIngredients(List<Ingredient> ingredients) {
    _pendingIngredients = List.from(ingredients);
    Logger.debug('Set ${ingredients.length} pending ingredients', tag: 'RecipeProvider');
    notifyListeners();
  }

  /// Set pending recipe title
  void setPendingTitle(String title) {
    _pendingTitle = title;
    notifyListeners();
  }

  /// Update a pending ingredient
  void updatePendingIngredient(int index, Ingredient ingredient) {
    if (index >= 0 && index < _pendingIngredients.length) {
      _pendingIngredients[index] = ingredient;
      notifyListeners();
    }
  }

  /// Add a new pending ingredient
  void addPendingIngredient(Ingredient ingredient) {
    _pendingIngredients.add(ingredient);
    notifyListeners();
  }

  /// Remove a pending ingredient
  void removePendingIngredient(int index) {
    if (index >= 0 && index < _pendingIngredients.length) {
      _pendingIngredients.removeAt(index);
      notifyListeners();
    }
  }

  /// Save the pending recipe
  Recipe? savePendingRecipe() {
    if (_pendingTitle == null || _pendingTitle!.isEmpty) {
      _error = 'Recipe title is required';
      notifyListeners();
      return null;
    }

    if (_pendingIngredients.isEmpty) {
      _error = 'At least one ingredient is required';
      notifyListeners();
      return null;
    }

    final recipe = Recipe(
      title: _pendingTitle!,
      source: _pendingSource ?? RecipeSource.manual,
      sourceUrl: _pendingSourceUrl,
      rawText: _pendingRawText,
      ingredients: List.from(_pendingIngredients),
    );

    addRecipe(recipe);
    clearPendingRecipe();
    return recipe;
  }

  /// Clear pending recipe state
  void clearPendingRecipe() {
    _pendingIngredients = [];
    _pendingTitle = null;
    _pendingSource = null;
    _pendingSourceUrl = null;
    _pendingRawText = null;
    _error = null;
  }

  /// Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
