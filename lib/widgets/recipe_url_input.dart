import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/recipe.dart';
import '../providers/recipe_provider.dart';
import '../screens/review_ingredients_screen.dart';
import '../services/recipe_url_parser_service.dart';
import '../utils/input_validator.dart';

/// URL input widget for entering recipe URLs
class RecipeUrlInput extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFetch;
  final bool enabled;
  final bool isLoading;

  const RecipeUrlInput({
    super.key,
    required this.controller,
    this.onChanged,
    this.onFetch,
    this.enabled = true,
    this.isLoading = false,
  });

  @override
  State<RecipeUrlInput> createState() => _RecipeUrlInputState();
}

class _RecipeUrlInputState extends State<RecipeUrlInput> {
  String? _errorText;
  bool _isFetching = false;
  String? _fetchError;

  @override
  void initState() {
    super.initState();
    _validateUrl(widget.controller.text);
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    _validateUrl(widget.controller.text);
    widget.onChanged?.call(widget.controller.text);
    // Clear fetch error when URL changes
    if (_fetchError != null) {
      setState(() => _fetchError = null);
    }
  }

  void _validateUrl(String text) {
    final result = InputValidator.validateUrl(text);
    setState(() {
      // Only show error after user has typed something
      _errorText = text.isNotEmpty && !result.isValid ? result.errorMessage : null;
    });
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      widget.controller.text = data!.text!.trim();
      widget.controller.selection = TextSelection.fromPosition(
        TextPosition(offset: widget.controller.text.length),
      );
    }
  }

  void _clearText() {
    widget.controller.clear();
    setState(() {
      _errorText = null;
      _fetchError = null;
    });
  }

  Future<void> _fetchRecipe() async {
    final url = widget.controller.text.trim();
    if (url.isEmpty) return;

    final validation = InputValidator.validateUrl(url);
    if (!validation.isValid) {
      setState(() => _errorText = validation.errorMessage);
      return;
    }

    setState(() {
      _isFetching = true;
      _fetchError = null;
    });

    final result = await RecipeUrlParserService.parseUrl(url);

    if (!mounted) return;

    setState(() => _isFetching = false);

    if (result.isSuccess) {
      // Set up the recipe provider with parsed data
      final provider = context.read<RecipeProvider>();
      provider.startNewRecipe(
        source: RecipeSource.url,
        sourceUrl: url,
        rawText: result.rawText,
      );
      provider.setPendingIngredients(result.ingredients);
      if (result.title != null) {
        provider.setPendingTitle(result.title!);
      }

      // Navigate to review screen
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ReviewIngredientsScreen()),
        );
      }
    } else {
      setState(() => _fetchError = result.error);
    }
  }

  bool get _canFetch =>
      widget.enabled &&
      !_isFetching &&
      !widget.isLoading &&
      widget.controller.text.trim().isNotEmpty &&
      _errorText == null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = _isFetching || widget.isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Info card
        Card(
          elevation: 0,
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Paste a recipe URL from popular cooking websites. '
                    'We\'ll extract the ingredients automatically.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // URL input field
        TextField(
          controller: widget.controller,
          enabled: widget.enabled && !isLoading,
          keyboardType: TextInputType.url,
          autocorrect: false,
          decoration: InputDecoration(
            labelText: 'Recipe URL',
            hintText: 'https://example.com/recipe',
            prefixIcon: const Icon(Icons.link),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.controller.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: widget.enabled && !isLoading ? _clearText : null,
                    tooltip: 'Clear',
                  ),
                IconButton(
                  icon: const Icon(Icons.paste),
                  onPressed: widget.enabled && !isLoading ? _pasteFromClipboard : null,
                  tooltip: 'Paste',
                ),
              ],
            ),
            border: const OutlineInputBorder(),
            errorText: _errorText,
          ),
          onSubmitted: (_) {
            if (_canFetch) _fetchRecipe();
          },
        ),
        const SizedBox(height: 16),

        // Fetch error message
        if (_fetchError != null)
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
                    _fetchError!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),

        if (_fetchError != null) const SizedBox(height: 16),

        // Supported sites hint
        Text(
          'Works with most recipe sites including AllRecipes, Food Network, Epicurious, BBC Good Food, and more',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
        const Spacer(),

        // Fetch button
        FilledButton.icon(
          onPressed: _canFetch ? _fetchRecipe : null,
          icon: isLoading
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.onPrimary,
                  ),
                )
              : const Icon(Icons.download),
          label: Text(isLoading ? 'Fetching...' : 'Fetch Recipe'),
        ),
      ],
    );
  }
}
