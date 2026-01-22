import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ingredient.dart';
import '../providers/recipe_provider.dart';
import '../widgets/ingredient_card.dart';

/// Screen for reviewing and editing parsed ingredients before saving
class ReviewIngredientsScreen extends StatefulWidget {
  const ReviewIngredientsScreen({super.key});

  @override
  State<ReviewIngredientsScreen> createState() => _ReviewIngredientsScreenState();
}

class _ReviewIngredientsScreenState extends State<ReviewIngredientsScreen> {
  final _titleController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Initialize title from provider
    final provider = context.read<RecipeProvider>();
    _titleController.text = provider.pendingTitle ?? '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _saveRecipe() {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<RecipeProvider>();
    provider.setPendingTitle(_titleController.text.trim());

    final recipe = provider.savePendingRecipe();
    if (recipe != null) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Recipe "${recipe.title}" saved!'),
          backgroundColor: Colors.green,
        ),
      );

      // Pop back to recipes list
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to save recipe'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _addIngredient() {
    final provider = context.read<RecipeProvider>();
    provider.addPendingIngredient(
      Ingredient(name: 'New ingredient'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Ingredients'),
        actions: [
          TextButton.icon(
            onPressed: _saveRecipe,
            icon: const Icon(Icons.check),
            label: const Text('Save'),
          ),
        ],
      ),
      body: Consumer<RecipeProvider>(
        builder: (context, provider, child) {
          final ingredients = provider.pendingIngredients;

          return Form(
            key: _formKey,
            child: Column(
              children: [
                // Title input
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Recipe Title',
                      hintText: 'Enter a name for this recipe',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.restaurant_menu),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a recipe title';
                      }
                      if (value.trim().length < 2) {
                        return 'Title must be at least 2 characters';
                      }
                      return null;
                    },
                  ),
                ),

                // Ingredients count header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        '${ingredients.length} Ingredients',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: _addIngredient,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                ),

                // Ingredients list
                Expanded(
                  child: ingredients.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 64,
                                color: theme.colorScheme.outline,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No ingredients found',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              FilledButton.icon(
                                onPressed: _addIngredient,
                                icon: const Icon(Icons.add),
                                label: const Text('Add Ingredient'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: ingredients.length,
                          itemBuilder: (context, index) {
                            final ingredient = ingredients[index];
                            return IngredientCard(
                              ingredient: ingredient,
                              onUpdate: (updated) {
                                provider.updatePendingIngredient(index, updated);
                              },
                              onDelete: () {
                                provider.removePendingIngredient(index);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveRecipe,
        icon: const Icon(Icons.save),
        label: const Text('Save Recipe'),
      ),
    );
  }
}
