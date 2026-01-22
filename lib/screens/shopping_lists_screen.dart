import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/shopping_list_provider.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/shopping_list_card.dart';
import 'create_shopping_list_screen.dart';
import 'shopping_list_detail_screen.dart';

/// Screen displaying the list of shopping lists
class ShoppingListsScreen extends StatelessWidget {
  const ShoppingListsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Lists'),
      ),
      body: Consumer<ShoppingListProvider>(
        builder: (context, provider, _) {
          final lists = provider.lists;

          if (lists.isEmpty) {
            return _buildEmptyState(context);
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: lists.length,
            itemBuilder: (context, index) {
              final list = lists[index];
              return ShoppingListCard(
                shoppingList: list,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ShoppingListDetailScreen(listId: list.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreateList(context),
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
      onAction: () => _navigateToCreateList(context),
    );
  }

  void _navigateToCreateList(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateShoppingListScreen(),
      ),
    );
  }
}
