import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'recipes_screen.dart';
import 'settings_screen.dart';
import 'shopping_lists_screen.dart';

/// Main app shell with bottom navigation
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Recipes',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'Lists',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return HomeScreen(
          onNavigateToRecipes: () => _onDestinationSelected(1),
          onNavigateToShoppingLists: () => _onDestinationSelected(2),
        );
      case 1:
        return const RecipesScreen();
      case 2:
        return const ShoppingListsScreen();
      case 3:
        return const SettingsScreen();
      default:
        return HomeScreen(
          onNavigateToRecipes: () => _onDestinationSelected(1),
          onNavigateToShoppingLists: () => _onDestinationSelected(2),
        );
    }
  }
}
