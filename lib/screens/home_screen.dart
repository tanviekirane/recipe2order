import 'package:flutter/material.dart';

import '../widgets/quick_action_card.dart';

/// Home screen with welcome message and quick actions
class HomeScreen extends StatelessWidget {
  final VoidCallback onNavigateToRecipes;
  final VoidCallback onNavigateToShoppingLists;

  const HomeScreen({
    super.key,
    required this.onNavigateToRecipes,
    required this.onNavigateToShoppingLists,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Welcome section
              Text(
                'Welcome to',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              Text(
                'Recipe2Order',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Plan your recipes and generate shopping lists with ease.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 32),

              // Quick actions section
              Text(
                'Quick Actions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Action cards grid
              Row(
                children: [
                  Expanded(
                    child: QuickActionCard(
                      icon: Icons.restaurant_menu,
                      title: 'Add Recipe',
                      subtitle: 'Enter a new recipe to parse',
                      onTap: onNavigateToRecipes,
                      backgroundColor: theme.colorScheme.primaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: QuickActionCard(
                      icon: Icons.shopping_cart,
                      title: 'Shopping Lists',
                      subtitle: 'View your shopping lists',
                      onTap: onNavigateToShoppingLists,
                      backgroundColor: theme.colorScheme.secondaryContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // How it works section
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'How it works',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildStep(context, '1', 'Add recipes via text or URL'),
                      const SizedBox(height: 12),
                      _buildStep(context, '2', 'Review extracted ingredients'),
                      const SizedBox(height: 12),
                      _buildStep(context, '3', 'Generate a consolidated shopping list'),
                      const SizedBox(height: 12),
                      _buildStep(context, '4', 'Share or copy your list for shopping'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, String number, String text) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
