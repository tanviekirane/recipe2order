import 'package:flutter/material.dart';

import '../widgets/empty_state_widget.dart';

/// Screen displaying the list of saved recipes
class RecipesScreen extends StatelessWidget {
  const RecipesScreen({super.key});

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
      // Show empty state for now, will be dynamic in Phase 2
      body: _buildEmptyState(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to add recipe screen - implemented in Phase 2
        },
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
      onAction: () {
        // Navigate to add recipe screen - implemented in Phase 2
      },
    );
  }
}
