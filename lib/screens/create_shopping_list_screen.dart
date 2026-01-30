import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recipe.dart';
import '../providers/recipe_provider.dart';
import '../providers/shopping_list_provider.dart';
import 'shopping_list_detail_screen.dart';

/// Screen for creating a new shopping list by selecting recipes
class CreateShoppingListScreen extends StatefulWidget {
  const CreateShoppingListScreen({super.key});

  @override
  State<CreateShoppingListScreen> createState() => _CreateShoppingListScreenState();
}

class _CreateShoppingListScreenState extends State<CreateShoppingListScreen> {
  final _nameController = TextEditingController();
  final _selectedRecipeIds = <String>{};
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Default name based on date
    final now = DateTime.now();
    _nameController.text = 'Shopping List ${now.month}/${now.day}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

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

  void _createList() {
    if (!_formKey.currentState!.validate()) return;
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

    // Ensure unique name
    final name = shoppingListProvider.getUniqueName(_nameController.text.trim());

    final shoppingList = shoppingListProvider.createFromRecipes(
      name: name,
      recipes: selectedRecipes,
    );

    // Navigate to the detail screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ShoppingListDetailScreen(listId: shoppingList.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recipes = context.watch<RecipeProvider>().recipes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Shopping List'),
      ),
      body: Column(
        children: [
          // List name input
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'List Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_cart),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
            ),
          ),

          // Recipe selection header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Select Recipes',
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

          const SizedBox(height: 8),

          // Recipe list
          Expanded(
            child: recipes.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = recipes[index];
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

          // Preview card and create button
          if (_selectedRecipeIds.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outlineVariant,
                  ),
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
                              Icons.shopping_basket,
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
                    // Create button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _createList,
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Create List'),
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

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No recipes yet',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some recipes first to create a shopping list',
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
