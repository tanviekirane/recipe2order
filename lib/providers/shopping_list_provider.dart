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
}
