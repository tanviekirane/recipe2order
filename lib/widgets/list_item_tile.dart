import 'package:flutter/material.dart';

import '../models/list_item.dart';

/// A tile widget for displaying a shopping list item with checkbox
class ListItemTile extends StatelessWidget {
  final ListItem item;
  final VoidCallback onToggle;
  final VoidCallback? onDelete;

  const ListItemTile({
    super.key,
    required this.item,
    required this.onToggle,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: theme.colorScheme.error,
        child: Icon(
          Icons.delete,
          color: theme.colorScheme.onError,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                // Checkbox
                Checkbox(
                  value: item.isChecked,
                  onChanged: (_) => onToggle(),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),

                // Item details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quantity and name
                      Text(
                        item.displayString,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          decoration: item.isChecked
                              ? TextDecoration.lineThrough
                              : null,
                          color: item.isChecked
                              ? theme.colorScheme.onSurfaceVariant
                              : theme.colorScheme.onSurface,
                        ),
                      ),

                      // Source recipes indicator (if from multiple recipes)
                      if (item.sourceRecipeIds.length > 1)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'From ${item.sourceRecipeIds.length} recipes',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Delete button (optional, since we have swipe)
                if (onDelete != null)
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: onDelete,
                    tooltip: 'Remove',
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
