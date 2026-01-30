import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recipe.dart';
import '../providers/recipe_provider.dart';
import 'edit_recipe_screen.dart';

/// Screen showing details of a single recipe
class RecipeDetailScreen extends StatelessWidget {
  final String recipeId;

  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<RecipeProvider>(
      builder: (context, provider, _) {
        final recipe = provider.getRecipeById(recipeId);

        if (recipe == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Recipe')),
            body: const Center(child: Text('Recipe not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(recipe.title),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Edit',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EditRecipeScreen(recipe: recipe)),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete',
                onPressed: () => _confirmDelete(context, recipe, provider),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Recipe info card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(_getSourceIcon(recipe.source),
                               color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(recipe.sourceLabel,
                               style: theme.textTheme.bodyMedium),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Added ${_formatDate(recipe.createdAt)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Ingredients section
              Text(
                'Ingredients (${recipe.ingredientCount})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              ...recipe.ingredients.map((ingredient) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      ingredient.name[0].toUpperCase(),
                      style: TextStyle(color: theme.colorScheme.primary),
                    ),
                  ),
                  title: Text(ingredient.displayString),
                  subtitle: ingredient.notes != null
                      ? Text(ingredient.notes!)
                      : null,
                ),
              )),
            ],
          ),
        );
      },
    );
  }

  IconData _getSourceIcon(RecipeSource source) {
    switch (source) {
      case RecipeSource.text:
        return Icons.edit_note;
      case RecipeSource.url:
        return Icons.link;
      case RecipeSource.manual:
        return Icons.person;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'today';
    if (diff.inDays == 1) return 'yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.month}/${date.day}/${date.year}';
  }

  void _confirmDelete(BuildContext context, Recipe recipe, RecipeProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Recipe'),
        content: Text('Delete "${recipe.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              provider.deleteRecipe(recipe.id);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
