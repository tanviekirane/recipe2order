import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/shopping_list.dart';

/// Card widget for displaying a shopping list in the grid
class ShoppingListCard extends StatelessWidget {
  final ShoppingList shoppingList;
  final VoidCallback? onTap;

  const ShoppingListCard({
    super.key,
    required this.shoppingList,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = shoppingList.progress;
    final isComplete = shoppingList.isComplete;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isComplete
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      isComplete ? Icons.check : Icons.shopping_cart,
                      color: isComplete
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  if (isComplete)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Done',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Title
              Text(
                shoppingList.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const Spacer(),

              // Item count
              Text(
                '${shoppingList.totalCount} item${shoppingList.totalCount == 1 ? '' : 's'}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 8),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),

              const SizedBox(height: 8),

              // Date
              Text(
                _formatDate(shoppingList.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat.MMMd().format(date);
    }
  }
}
