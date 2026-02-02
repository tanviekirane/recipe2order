import 'package:flutter/material.dart';

import '../models/ingredient.dart';
import '../utils/unit_converter.dart';

/// Editable card widget for displaying and editing an ingredient
class IngredientCard extends StatefulWidget {
  final Ingredient ingredient;
  final ValueChanged<Ingredient> onUpdate;
  final VoidCallback onDelete;

  const IngredientCard({
    super.key,
    required this.ingredient,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<IngredientCard> createState() => _IngredientCardState();
}

class _IngredientCardState extends State<IngredientCard> {
  late TextEditingController _quantityController;
  late TextEditingController _nameController;
  late TextEditingController _notesController;
  String? _selectedUnit;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _quantityController = TextEditingController(
      text: widget.ingredient.quantity?.toString() ?? '',
    );
    _nameController = TextEditingController(text: widget.ingredient.name);
    _notesController = TextEditingController(text: widget.ingredient.notes ?? '');
    _selectedUnit = widget.ingredient.unit;
  }

  @override
  void didUpdateWidget(IngredientCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ingredient.id != widget.ingredient.id) {
      _initializeControllers();
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _updateIngredient() {
    final quantity = double.tryParse(_quantityController.text);
    widget.onUpdate(
      widget.ingredient.copyWith(
        name: _nameController.text.trim(),
        quantity: quantity,
        unit: _selectedUnit,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      ),
    );
  }

  /// Check if this ingredient needs review (no unit and has quantity, or looks like a header)
  bool get _needsReview {
    final ing = widget.ingredient;
    // Has quantity but no unit - might be incomplete
    if (ing.quantity != null && ing.unit == null) return true;
    // Name is very short (less than 3 chars) - might be incomplete
    if (ing.name.trim().length < 3) return true;
    // Name looks like a section header (all caps or ends with colon)
    if (ing.name == ing.name.toUpperCase() && ing.name.length > 2) return true;
    if (ing.name.trim().endsWith(':')) return true;
    return false;
  }

  String _getWarningMessage() {
    final ing = widget.ingredient;
    if (ing.name.trim().endsWith(':') ||
        (ing.name == ing.name.toUpperCase() && ing.name.length > 2)) {
      return 'Looks like a section header - delete if not an ingredient';
    }
    if (ing.name.trim().length < 3) {
      return 'Name is too short - please complete or delete';
    }
    if (ing.quantity != null && ing.unit == null) {
      return 'Missing unit - tap to add or verify';
    }
    return 'Please review this item';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final needsReview = _needsReview;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: needsReview ? theme.colorScheme.errorContainer.withValues(alpha: 0.3) : null,
      child: Column(
        children: [
          // Warning banner if needs review
          if (needsReview)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getWarningMessage(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Main row - always visible
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Drag handle / expand indicator
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(width: 8),

                  // Ingredient display
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.ingredient.displayString,
                          style: theme.textTheme.bodyLarge,
                        ),
                        if (widget.ingredient.notes != null)
                          Text(
                            widget.ingredient.notes!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Delete button
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: theme.colorScheme.error,
                    ),
                    onPressed: () => _showDeleteConfirmation(context),
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ),
          ),

          // Expanded edit form
          if (_isExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(),
                  const SizedBox(height: 8),

                  // Quantity and Unit row
                  Row(
                    children: [
                      // Quantity
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _quantityController,
                          decoration: const InputDecoration(
                            labelText: 'Quantity',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (_) => _updateIngredient(),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Unit dropdown
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedUnit,
                          decoration: const InputDecoration(
                            labelText: 'Unit',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('None'),
                            ),
                            ...UnitConverter.allUnits.map(
                              (unit) => DropdownMenuItem(
                                value: unit,
                                child: Text(unit),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedUnit = value);
                            _updateIngredient();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Name
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Ingredient Name',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => _updateIngredient(),
                  ),
                  const SizedBox(height: 12),

                  // Notes
                  TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      hintText: 'e.g., diced, room temperature',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => _updateIngredient(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Ingredient'),
        content: Text(
          'Remove "${widget.ingredient.name}" from the recipe?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onDelete();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
