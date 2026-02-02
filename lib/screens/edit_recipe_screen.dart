import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ingredient.dart';
import '../models/recipe.dart';
import '../providers/recipe_provider.dart';
import '../widgets/ingredient_card.dart';

/// Screen for editing an existing recipe
class EditRecipeScreen extends StatefulWidget {
  final Recipe recipe;

  const EditRecipeScreen({super.key, required this.recipe});

  @override
  State<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  late TextEditingController _titleController;
  late List<Ingredient> _ingredients;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.recipe.title);
    _ingredients = List.from(widget.recipe.ingredients);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _updateIngredient(int index, Ingredient ingredient) {
    setState(() => _ingredients[index] = ingredient);
  }

  void _deleteIngredient(int index) {
    setState(() => _ingredients.removeAt(index));
  }

  void _addIngredient() {
    final nameController = TextEditingController();
    final qtyController = TextEditingController();
    final unitController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Ingredient'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: qtyController,
                    decoration: const InputDecoration(labelText: 'Qty', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: unitController,
                    decoration: const InputDecoration(labelText: 'Unit', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) return;
              setState(() {
                _ingredients.add(Ingredient(
                  name: nameController.text.trim(),
                  quantity: double.tryParse(qtyController.text),
                  unit: unitController.text.trim().isEmpty ? null : unitController.text.trim(),
                ));
              });
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _saveRecipe() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }
    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one ingredient')),
      );
      return;
    }

    final provider = context.read<RecipeProvider>();
    // Check for duplicate name (excluding current recipe)
    if (provider.nameExists(title, excludeId: widget.recipe.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A recipe with this name already exists')),
      );
      return;
    }

    final updatedRecipe = widget.recipe.copyWith(
      title: title,
      ingredients: _ingredients,
    );

    provider.updateRecipe(updatedRecipe);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recipe updated')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Recipe'),
        actions: [
          TextButton(onPressed: _saveRecipe, child: const Text('Save')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Recipe Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text('Ingredients (${_ingredients.length})',
                  style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              TextButton.icon(
                onPressed: _addIngredient,
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._ingredients.asMap().entries.map((entry) => IngredientCard(
                ingredient: entry.value,
                onUpdate: (ing) => _updateIngredient(entry.key, ing),
                onDelete: () => _deleteIngredient(entry.key),
              )),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
