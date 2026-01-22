import 'package:flutter/material.dart';

import '../widgets/empty_state_widget.dart';

/// Screen displaying the list of shopping lists
class ShoppingListsScreen extends StatelessWidget {
  const ShoppingListsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Lists'),
      ),
      // Show empty state for now, will be dynamic in Phase 4
      body: _buildEmptyState(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to create shopping list screen - implemented in Phase 4
        },
        icon: const Icon(Icons.add),
        label: const Text('Create List'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.shopping_cart_outlined,
      title: 'No shopping lists yet',
      subtitle: 'Create a shopping list by selecting recipes to combine',
      actionLabel: 'Create List',
      onAction: () {
        // Navigate to create shopping list screen - implemented in Phase 4
      },
    );
  }
}
