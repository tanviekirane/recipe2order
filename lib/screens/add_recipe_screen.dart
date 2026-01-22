import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recipe.dart';
import '../providers/recipe_provider.dart';
import '../services/ingredient_parser_service.dart';
import '../utils/input_validator.dart';
import '../widgets/recipe_text_input.dart';
import '../widgets/recipe_url_input.dart';
import 'review_ingredients_screen.dart';

/// Screen for adding a new recipe via text or URL input
class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _textController = TextEditingController();
  final _urlController = TextEditingController();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _parseTextRecipe() {
    final text = _textController.text;
    final validation = InputValidator.validateRecipeText(text);

    if (!validation.isValid) {
      _showError(validation.errorMessage ?? 'Invalid input');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Parse ingredients from text
      final sanitizedText = InputValidator.sanitizeText(text);
      final ingredients = IngredientParserService.parseText(sanitizedText);

      if (ingredients.isEmpty) {
        _showError('No ingredients found. Please check your input format.');
        setState(() => _isProcessing = false);
        return;
      }

      // Try to extract a title
      final suggestedTitle = IngredientParserService.extractTitle(sanitizedText);

      // Set up the recipe provider with pending data
      final recipeProvider = context.read<RecipeProvider>();
      recipeProvider.startNewRecipe(
        source: RecipeSource.text,
        rawText: sanitizedText,
      );
      recipeProvider.setPendingIngredients(ingredients);
      if (suggestedTitle != null) {
        recipeProvider.setPendingTitle(suggestedTitle);
      }

      setState(() => _isProcessing = false);

      // Navigate to review screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const ReviewIngredientsScreen(),
        ),
      );
    } catch (e) {
      setState(() => _isProcessing = false);
      _showError('Error parsing ingredients: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Recipe'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.edit_note),
              text: 'Enter Text',
            ),
            Tab(
              icon: Icon(Icons.link),
              text: 'From URL',
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              // Text input tab
              Padding(
                padding: const EdgeInsets.all(16),
                child: RecipeTextInput(
                  controller: _textController,
                  enabled: !_isProcessing,
                  onParse: _parseTextRecipe,
                ),
              ),

              // URL input tab
              Padding(
                padding: const EdgeInsets.all(16),
                child: RecipeUrlInput(
                  controller: _urlController,
                  enabled: !_isProcessing,
                  isLoading: _isProcessing,
                ),
              ),
            ],
          ),

          // Loading overlay
          if (_isProcessing)
            Container(
              color: Colors.black26,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Parsing ingredients...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
