import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/recipe.dart';
import '../providers/recipe_provider.dart';
import '../services/recipe_url_parser_service.dart';
import 'review_ingredients_screen.dart';

/// Screen for importing a recipe from a URL
class AddRecipeUrlScreen extends StatefulWidget {
  const AddRecipeUrlScreen({super.key});

  @override
  State<AddRecipeUrlScreen> createState() => _AddRecipeUrlScreenState();
}

class _AddRecipeUrlScreenState extends State<AddRecipeUrlScreen> {
  final _urlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      _urlController.text = data!.text!;
      setState(() => _error = null);
    }
  }

  Future<void> _fetchRecipe() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await RecipeUrlParserService.parseUrl(_urlController.text.trim());

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result.isSuccess) {
      // Set up the recipe provider with parsed data
      final provider = context.read<RecipeProvider>();
      provider.startNewRecipe(
        source: RecipeSource.url,
        sourceUrl: _urlController.text.trim(),
        rawText: result.rawText,
      );
      provider.setPendingIngredients(result.ingredients);
      if (result.title != null) {
        provider.setPendingTitle(result.title!);
      }

      // Navigate to review screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ReviewIngredientsScreen()),
        );
      }
    } else {
      setState(() => _error = result.error);
    }
  }

  String? _validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a URL';
    }
    final url = value.trim();
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return 'URL must start with http:// or https://';
    }
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasAuthority) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Import from URL'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info card
              Card(
                color: theme.colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Paste a recipe URL from popular recipe sites. We\'ll automatically extract the ingredients.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // URL input
              TextFormField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: 'Recipe URL',
                  hintText: 'https://example.com/recipe/...',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.link),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.content_paste),
                    tooltip: 'Paste from clipboard',
                    onPressed: _pasteFromClipboard,
                  ),
                ),
                keyboardType: TextInputType.url,
                autocorrect: false,
                validator: _validateUrl,
                onChanged: (_) {
                  if (_error != null) {
                    setState(() => _error = null);
                  }
                },
              ),

              const SizedBox(height: 16),

              // Error message
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _error!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Fetch button
              FilledButton.icon(
                onPressed: _isLoading ? null : _fetchRecipe,
                icon: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.onPrimary,
                        ),
                      )
                    : const Icon(Icons.download),
                label: Text(_isLoading ? 'Fetching...' : 'Fetch Recipe'),
              ),

              const SizedBox(height: 32),

              // Supported sites info
              Text(
                'Supported Sites',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Works best with sites that use structured recipe data (schema.org), including:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildSiteChip('AllRecipes'),
                  _buildSiteChip('Food Network'),
                  _buildSiteChip('Bon Appetit'),
                  _buildSiteChip('Serious Eats'),
                  _buildSiteChip('Epicurious'),
                  _buildSiteChip('NYT Cooking'),
                  _buildSiteChip('Tasty'),
                  _buildSiteChip('& more'),
                ],
              ),

              const SizedBox(height: 24),

              // Manual fallback
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.edit_note),
                label: const Text('Enter Manually Instead'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSiteChip(String name) {
    return Chip(
      label: Text(name),
      visualDensity: VisualDensity.compact,
    );
  }
}
