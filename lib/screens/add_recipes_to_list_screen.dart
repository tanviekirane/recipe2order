import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recipe.dart';
import '../providers/recipe_provider.dart';
import '../providers/shopping_list_provider.dart';

/// Screen for adding recipes to an existing shopping list
class AddRecipesToListScreen extends StatefulWidget {
  final String listId;

  const AddRecipesToListScreen({super.key, required this.listId});

  @override
  State<AddRecipesToListScreen> createState() => _AddRecipesToListScreenState();
}

class _AddRecipesToListScreenState extends State<AddRecipesToListScreen> {
  final _selectedRecipeIds = <String>{};

  void _toggleRecipe(String recipeId) {
    setState(() {
      if (_selectedRecipeIds.contains(recipeId)) {
        _selectedRecipeIds.remove(recipeId);
      } else {
        _selectedRecipeIds.add(recipeId);
      }
    });
  }

  int _getTotalIngredientCount(List<Recipe> recipes) {
    final selectedRecipes = recipes.where((r) => _selectedRecipeIds.contains(r.id));
    return selectedRecipes.fold(0, (sum, r) => sum + r.ingredients.length);
  }

  void _addRecipes() {
    if (_selectedRecipeIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one recipe')),
      );
      return;
    }

    final recipeProvider = context.read<RecipeProvider>();
    final shoppingListProvider = context.read<ShoppingListProvider>();

    final selectedRecipes = recipeProvider.recipes
        .where((r) => _selectedRecipeIds.contains(r.id))
        .toList();

    final addedCount = shoppingListProvider.addRecipesToList(
      widget.listId,
      selectedRecipes,
    );

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added $addedCount ingredients from ${selectedRecipes.length} recipe${selectedRecipes.length == 1 ? '' : 's'}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recipes = context.watch<RecipeProvider>().recipes;
    final shoppingList = context.watch<ShoppingListProvider>().getListById(widget.listId);

    if (shoppingList == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Add Recipes')),
        body: const Center(child: Text('List not found')),
      );
    }

    // Filter out recipes already in the list
    final availableRecipes = recipes.where((r) => !shoppingList.recipeIds.contains(r.id)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Add to ${shoppingList.name}'),
      ),
      body: Column(
        children: [
          // Info banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: theme.colorScheme.surfaceContainerLow,
            child: Row(
              children: [
                Icon(Icons.info_outline, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Select recipes to add their ingredients to this list. Duplicate ingredients will be combined.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),

          // Recipe selection header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Available Recipes',
                  style: theme.textTheme.titleMedium,
                ),
                const Spacer(),
                if (_selectedRecipeIds.isNotEmpty)
                  Text(
                    '${_selectedRecipeIds.length} selected',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),

          // Recipe list
          Expanded(
            child: availableRecipes.isEmpty
                ? _buildEmptyState(context, recipes.isEmpty)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: availableRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = availableRecipes[index];
                      final isSelected = _selectedRecipeIds.contains(recipe.id);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: CheckboxListTile(
                          value: isSelected,
                          onChanged: (_) => _toggleRecipe(recipe.id),
                          title: Text(recipe.title),
                          subtitle: Text(
                            '${recipe.ingredients.length} ingredients',
                            style: theme.textTheme.bodySmall,
                          ),
                          secondary: CircleAvatar(
                            backgroundColor: isSelected
                                ? theme.colorScheme.primaryContainer
                                : theme.colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.restaurant_menu,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          controlAffinity: ListTileControlAffinity.trailing,
                        ),
                      );
                    },
                  ),
          ),

          // Preview card and add button
          if (_selectedRecipeIds.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                border: Border(
                  top: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Preview card
                    Card(
                      color: theme.colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.add_shopping_cart,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${_getTotalIngredientCount(recipes)} ingredients from ${_selectedRecipeIds.length} recipe${_selectedRecipeIds.length == 1 ? '' : 's'}',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Add button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _addRecipes,
                        icon: const Icon(Icons.add),
                        label: const Text('Add to List'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool noRecipesAtAll) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            noRecipesAtAll ? Icons.restaurant_menu : Icons.check_circle_outline,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            noRecipesAtAll ? 'No recipes yet' : 'All recipes added',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            noRecipesAtAll
                ? 'Add some recipes first'
                : 'All your recipes are already in this list',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
}
