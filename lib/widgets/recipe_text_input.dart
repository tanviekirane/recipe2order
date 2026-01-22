import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/constants.dart';
import '../utils/input_validator.dart';

/// Text input widget for entering recipe text
class RecipeTextInput extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onParse;
  final bool enabled;

  const RecipeTextInput({
    super.key,
    required this.controller,
    this.onChanged,
    this.onParse,
    this.enabled = true,
  });

  @override
  State<RecipeTextInput> createState() => _RecipeTextInputState();
}

class _RecipeTextInputState extends State<RecipeTextInput> {
  String? _errorText;
  int _characterCount = 0;

  @override
  void initState() {
    super.initState();
    _characterCount = widget.controller.text.length;
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _characterCount = widget.controller.text.length;
      // Clear error when user starts typing
      if (_errorText != null && widget.controller.text.isNotEmpty) {
        _errorText = null;
      }
    });
    widget.onChanged?.call(widget.controller.text);
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      widget.controller.text = data!.text!;
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

  void _validateAndParse() {
    final result = InputValidator.validateRecipeText(widget.controller.text);
    if (result.isValid) {
      widget.onParse?.call();
    } else {
      setState(() {
        _errorText = result.errorMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isValid = _characterCount >= InputValidator.minTextLength;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Toolbar
        Row(
          children: [
            TextButton.icon(
              onPressed: widget.enabled ? _pasteFromClipboard : null,
              icon: const Icon(Icons.paste, size: 18),
              label: const Text('Paste'),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: widget.enabled && _characterCount > 0 ? _clearText : null,
              icon: const Icon(Icons.clear, size: 18),
              label: const Text('Clear'),
            ),
            const Spacer(),
            Text(
              '$_characterCount / ${AppConstants.maxTextInputLength}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: _characterCount > AppConstants.maxTextInputLength
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Text input
        Expanded(
          child: TextField(
            controller: widget.controller,
            enabled: widget.enabled,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            decoration: InputDecoration(
              hintText: 'Paste or type your recipe ingredients here...\n\n'
                  'Example:\n'
                  '2 cups all-purpose flour\n'
                  '1 cup sugar\n'
                  '3 large eggs\n'
                  '1/2 tsp vanilla extract\n'
                  '1 cup milk',
              hintMaxLines: 10,
              border: const OutlineInputBorder(),
              errorText: _errorText,
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerLow,
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Parse button
        FilledButton.icon(
          onPressed: widget.enabled && isValid ? _validateAndParse : null,
          icon: const Icon(Icons.auto_fix_high),
          label: const Text('Parse Ingredients'),
        ),
      ],
    );
  }
}
