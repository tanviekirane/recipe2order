import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/recipe_provider.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/recipe_card.dart';
import 'add_recipe_screen.dart';

/// Screen displaying the list of saved recipes
class RecipesScreen extends StatelessWidget {
  const RecipesScreen({super.key});

  void _navigateToAddRecipe(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddRecipeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Recipes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Search will be implemented in Phase 6
            },
            tooltip: 'Search recipes',
          ),
        ],
      ),
      body: Consumer<RecipeProvider>(
        builder: (context, provider, child) {
          if (provider.hasRecipes) {
            return _buildRecipesList(context, provider);
          }
          return _buildEmptyState(context);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddRecipe(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Recipe'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.restaurant_menu,
      title: 'No recipes yet',
      subtitle: 'Add your first recipe by entering text or pasting a URL',
      actionLabel: 'Add Recipe',
      onAction: () => _navigateToAddRecipe(context),
    );
  }

  Widget _buildRecipesList(BuildContext context, RecipeProvider provider) {
    final recipes = provider.recipes;

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return RecipeCard(
          recipe: recipe,
          onTap: () {
            // TODO: Navigate to recipe detail screen
          },
          onDelete: () {
            provider.deleteRecipe(recipe.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Deleted "${recipe.title}"'),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {
                    provider.addRecipe(recipe);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
