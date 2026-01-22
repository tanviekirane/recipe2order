import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          enabled: widget.enabled && !widget.isLoading,
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
                    onPressed: widget.enabled ? _clearText : null,
                    tooltip: 'Clear',
                  ),
                IconButton(
                  icon: const Icon(Icons.paste),
                  onPressed: widget.enabled && !widget.isLoading ? _pasteFromClipboard : null,
                  tooltip: 'Paste',
                ),
              ],
            ),
            border: const OutlineInputBorder(),
            errorText: _errorText,
          ),
        ),
        const SizedBox(height: 16),

        // Supported sites hint
        Text(
          'Supported: AllRecipes, Food Network, Epicurious, BBC Good Food, and most recipe sites',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Coming soon notice
        Card(
          elevation: 0,
          color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.construction,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'URL Parsing Coming Soon',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'For now, please copy the ingredients from the recipe page and use the "Enter Text" tab.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),

        // Fetch button (disabled for now)
        FilledButton.icon(
          onPressed: null, // Disabled until URL parsing is implemented
          icon: widget.isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download),
          label: Text(widget.isLoading ? 'Fetching...' : 'Fetch Recipe'),
        ),
      ],
    );
  }
}
