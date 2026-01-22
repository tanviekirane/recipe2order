import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/list_item.dart';
import '../models/shopping_list.dart';
import '../providers/shopping_list_provider.dart';
import '../widgets/list_item_tile.dart';

/// Screen showing details of a shopping list with check/uncheck functionality
class ShoppingListDetailScreen extends StatelessWidget {
  final String listId;

  const ShoppingListDetailScreen({
    super.key,
    required this.listId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<ShoppingListProvider>(
      builder: (context, provider, _) {
        final shoppingList = provider.getListById(listId);

        if (shoppingList == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Shopping List')),
            body: const Center(child: Text('List not found')),
          );
        }

        final uncheckedItems = shoppingList.items.where((i) => !i.isChecked).toList();
        final checkedItems = shoppingList.items.where((i) => i.isChecked).toList();

        return Scaffold(
          appBar: AppBar(
            title: Text(shoppingList.name),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(context, value, shoppingList),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'check_all',
                    child: ListTile(
                      leading: Icon(Icons.check_box),
                      title: Text('Check All'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'uncheck_all',
                    child: ListTile(
                      leading: Icon(Icons.check_box_outline_blank),
                      title: Text('Uncheck All'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'clear_checked',
                    child: ListTile(
                      leading: Icon(Icons.delete_sweep),
                      title: Text('Clear Checked'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text('Delete List', style: TextStyle(color: Colors.red)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              // Progress indicator
              _buildProgressSection(context, shoppingList),

              // Item list
              Expanded(
                child: shoppingList.items.isEmpty
                    ? _buildEmptyState(context)
                    : ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          // Unchecked items section
                          if (uncheckedItems.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.only(top: 16, bottom: 8),
                              child: Text(
                                'To Buy (${uncheckedItems.length})',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            ...uncheckedItems.map((item) => ListItemTile(
                                  item: item,
                                  onToggle: () => _toggleItem(context, item),
                                  onDelete: () => _deleteItem(context, item),
                                )),
                          ],

                          // Checked items section
                          if (checkedItems.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.only(top: 24, bottom: 8),
                              child: Row(
                                children: [
                                  Text(
                                    'Completed (${checkedItems.length})',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...checkedItems.map((item) => ListItemTile(
                                  item: item,
                                  onToggle: () => _toggleItem(context, item),
                                  onDelete: () => _deleteItem(context, item),
                                )),
                          ],

                          const SizedBox(height: 80), // Space for FAB
                        ],
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddItemDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Item'),
          ),
        );
      },
    );
  }

  Widget _buildProgressSection(BuildContext context, ShoppingList list) {
    final theme = Theme.of(context);
    final progress = list.progress;
    final isComplete = list.isComplete;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isComplete
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                isComplete ? Icons.check_circle : Icons.shopping_cart,
                color: isComplete
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isComplete
                      ? 'All done!'
                      : '${list.checkedCount} of ${list.totalCount} items',
                  style: theme.textTheme.titleMedium,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
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
            Icons.shopping_basket_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No items in this list',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add items',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleItem(BuildContext context, ListItem item) {
    context.read<ShoppingListProvider>().toggleItemChecked(listId, item.id);
  }

  void _deleteItem(BuildContext context, ListItem item) {
    context.read<ShoppingListProvider>().deleteItem(listId, item.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed ${item.ingredientName}'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            context.read<ShoppingListProvider>().addItem(listId, item);
          },
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action, ShoppingList list) {
    final provider = context.read<ShoppingListProvider>();

    switch (action) {
      case 'check_all':
        provider.checkAllItems(listId);
        break;
      case 'uncheck_all':
        provider.uncheckAllItems(listId);
        break;
      case 'clear_checked':
        _showClearCheckedDialog(context);
        break;
      case 'delete':
        _showDeleteListDialog(context);
        break;
    }
  }

  void _showClearCheckedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Checked Items'),
        content: const Text('Remove all checked items from this list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<ShoppingListProvider>().clearCheckedItems(listId);
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showDeleteListDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete List'),
        content: const Text('Are you sure you want to delete this shopping list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              context.read<ShoppingListProvider>().deleteList(listId);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    final unitController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Item Name',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Qty',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: unitController,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      border: OutlineInputBorder(),
                      hintText: 'cups, lbs...',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) return;

              final quantity = double.tryParse(quantityController.text);
              final unit = unitController.text.trim();

              final item = ListItem(
                ingredientName: name,
                quantity: quantity,
                unit: unit.isEmpty ? null : unit,
              );

              context.read<ShoppingListProvider>().addItem(listId, item);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
