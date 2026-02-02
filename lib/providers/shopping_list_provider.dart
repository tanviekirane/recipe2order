import 'package:flutter/foundation.dart';

import '../models/list_item.dart';
import '../models/recipe.dart';
import '../models/shopping_list.dart';
import '../services/ingredient_aggregator_service.dart';
import '../utils/logger.dart';

/// Provider for managing shopping lists state
class ShoppingListProvider extends ChangeNotifier {
  final List<ShoppingList> _lists = [];

  /// Get all shopping lists
  List<ShoppingList> get lists => List.unmodifiable(_lists);

  /// Get a shopping list by ID
  ShoppingList? getListById(String id) {
    try {
      return _lists.firstWhere((list) => list.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Check if a name already exists (case-insensitive)
  bool nameExists(String name, {String? excludeId}) {
    final lowerName = name.toLowerCase().trim();
    return _lists.any((list) =>
        list.name.toLowerCase().trim() == lowerName &&
        (excludeId == null || list.id != excludeId));
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

  /// Rename a shopping list
  void renameList(String listId, String newName) {
    final index = _lists.indexWhere((list) => list.id == listId);
    if (index != -1) {
      _lists[index] = _lists[index].copyWith(name: newName);
      notifyListeners();
      Logger.info('Renamed list to: $newName', tag: 'ShoppingListProvider');
    }
  }

  /// Create a new shopping list from selected recipes
  ShoppingList createFromRecipes({
    required String name,
    required List<Recipe> recipes,
  }) {
    final items = IngredientAggregatorService.aggregateFromRecipes(recipes);
    final recipeIds = recipes.map((r) => r.id).toList();

    final shoppingList = ShoppingList(
      name: name,
      items: items,
      recipeIds: recipeIds,
    );

    _lists.insert(0, shoppingList);
    notifyListeners();

    Logger.info('Created shopping list "${shoppingList.name}" with ${items.length} items', tag: 'ShoppingListProvider');

    return shoppingList;
  }

  /// Add a shopping list
  void addList(ShoppingList list) {
    _lists.insert(0, list);
    notifyListeners();
    Logger.info('Added shopping list: ${list.name}', tag: 'ShoppingListProvider');
  }

  /// Update an existing shopping list
  void updateList(ShoppingList updatedList) {
    final index = _lists.indexWhere((list) => list.id == updatedList.id);
    if (index != -1) {
      _lists[index] = updatedList;
      notifyListeners();
      Logger.info('Updated shopping list: ${updatedList.name}', tag: 'ShoppingListProvider');
    }
  }

  /// Delete a shopping list
  void deleteList(String listId) {
    final index = _lists.indexWhere((list) => list.id == listId);
    if (index != -1) {
      final removed = _lists.removeAt(index);
      notifyListeners();
      Logger.info('Deleted shopping list: ${removed.name}', tag: 'ShoppingListProvider');
    }
  }

  /// Toggle the checked state of an item
  void toggleItemChecked(String listId, String itemId) {
    final listIndex = _lists.indexWhere((list) => list.id == listId);
    if (listIndex == -1) return;

    final list = _lists[listIndex];
    final itemIndex = list.items.indexWhere((item) => item.id == itemId);
    if (itemIndex == -1) return;

    final item = list.items[itemIndex];
    final updatedItem = item.copyWith(isChecked: !item.isChecked);

    final updatedItems = List<ListItem>.from(list.items);
    updatedItems[itemIndex] = updatedItem;

    _lists[listIndex] = list.copyWith(items: updatedItems);
    notifyListeners();
  }

  /// Update an item in a shopping list
  void updateItem(String listId, ListItem updatedItem) {
    final listIndex = _lists.indexWhere((list) => list.id == listId);
    if (listIndex == -1) return;

    final list = _lists[listIndex];
    final itemIndex = list.items.indexWhere((item) => item.id == updatedItem.id);
    if (itemIndex == -1) return;

    final updatedItems = List<ListItem>.from(list.items);
    updatedItems[itemIndex] = updatedItem;

    _lists[listIndex] = list.copyWith(items: updatedItems);
    notifyListeners();
  }

  /// Delete an item from a shopping list
  void deleteItem(String listId, String itemId) {
    final listIndex = _lists.indexWhere((list) => list.id == listId);
    if (listIndex == -1) return;

    final list = _lists[listIndex];
    final updatedItems = list.items.where((item) => item.id != itemId).toList();

    _lists[listIndex] = list.copyWith(items: updatedItems);
    notifyListeners();
  }

  /// Add an item to a shopping list
  void addItem(String listId, ListItem item) {
    final listIndex = _lists.indexWhere((list) => list.id == listId);
    if (listIndex == -1) return;

    final list = _lists[listIndex];
    final updatedItems = [...list.items, item];

    _lists[listIndex] = list.copyWith(items: updatedItems);
    notifyListeners();
  }

  /// Check all items in a list
  void checkAllItems(String listId) {
    final listIndex = _lists.indexWhere((list) => list.id == listId);
    if (listIndex == -1) return;

    final list = _lists[listIndex];
    final updatedItems = list.items.map((item) => item.copyWith(isChecked: true)).toList();

    _lists[listIndex] = list.copyWith(items: updatedItems);
    notifyListeners();
  }

  /// Uncheck all items in a list
  void uncheckAllItems(String listId) {
    final listIndex = _lists.indexWhere((list) => list.id == listId);
    if (listIndex == -1) return;

    final list = _lists[listIndex];
    final updatedItems = list.items.map((item) => item.copyWith(isChecked: false)).toList();

    _lists[listIndex] = list.copyWith(items: updatedItems);
    notifyListeners();
  }

  /// Clear all checked items from a list
  void clearCheckedItems(String listId) {
    final listIndex = _lists.indexWhere((list) => list.id == listId);
    if (listIndex == -1) return;

    final list = _lists[listIndex];
    final updatedItems = list.items.where((item) => !item.isChecked).toList();

    _lists[listIndex] = list.copyWith(items: updatedItems);
    notifyListeners();
  }

  /// Add recipes to an existing shopping list
  /// Aggregates new ingredients with existing items
  int addRecipesToList(String listId, List<Recipe> recipes) {
    final listIndex = _lists.indexWhere((list) => list.id == listId);
    if (listIndex == -1) return 0;

    final list = _lists[listIndex];

    // Get new items from recipes
    final newItems = IngredientAggregatorService.aggregateFromRecipes(recipes);
    if (newItems.isEmpty) return 0;

    // Merge with existing items
    final existingItems = List<ListItem>.from(list.items);
    int addedCount = 0;

    for (final newItem in newItems) {
      // Check if similar item exists (same name and unit)
      final existingIndex = existingItems.indexWhere((existing) =>
          existing.ingredientName.toLowerCase() == newItem.ingredientName.toLowerCase() &&
          existing.unit == newItem.unit);

      if (existingIndex != -1) {
        // Combine quantities
        final existing = existingItems[existingIndex];
        final combinedQty = (existing.quantity ?? 0) + (newItem.quantity ?? 0);
        final combinedSources = {...existing.sourceRecipeIds, ...newItem.sourceRecipeIds};

        existingItems[existingIndex] = existing.copyWith(
          quantity: combinedQty > 0 ? combinedQty : null,
          sourceRecipeIds: combinedSources.toList(),
        );
      } else {
        // Add as new item
        existingItems.add(newItem);
        addedCount++;
      }
    }

    // Sort alphabetically
    existingItems.sort((a, b) =>
        a.ingredientName.toLowerCase().compareTo(b.ingredientName.toLowerCase()));

    // Update recipe IDs
    final updatedRecipeIds = {...list.recipeIds, ...recipes.map((r) => r.id)}.toList();

    _lists[listIndex] = list.copyWith(
      items: existingItems,
      recipeIds: updatedRecipeIds,
    );
    notifyListeners();

    Logger.info('Added ${recipes.length} recipes to list "${list.name}" ($addedCount new items)', tag: 'ShoppingListProvider');

    return newItems.length;
  }
}
