import 'package:uuid/uuid.dart';

/// Represents an item in a shopping list
class ListItem {
  final String id;
  final String ingredientName;
  final double? quantity;
  final String? unit;
  final bool isChecked;
  final List<String> sourceRecipeIds;

  ListItem({
    String? id,
    required this.ingredientName,
    this.quantity,
    this.unit,
    this.isChecked = false,
    this.sourceRecipeIds = const [],
  }) : id = id ?? const Uuid().v4();

  /// Create a copy with updated fields
  ListItem copyWith({
    String? id,
    String? ingredientName,
    double? quantity,
    String? unit,
    bool? isChecked,
    List<String>? sourceRecipeIds,
  }) {
    return ListItem(
      id: id ?? this.id,
      ingredientName: ingredientName ?? this.ingredientName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      isChecked: isChecked ?? this.isChecked,
      sourceRecipeIds: sourceRecipeIds ?? this.sourceRecipeIds,
    );
  }

  /// Convert to JSON map for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ingredientName': ingredientName,
      'quantity': quantity,
      'unit': unit,
      'isChecked': isChecked,
      'sourceRecipeIds': sourceRecipeIds,
    };
  }

  /// Create from JSON map
  factory ListItem.fromJson(Map<String, dynamic> json) {
    return ListItem(
      id: json['id'] as String,
      ingredientName: json['ingredientName'] as String,
      quantity: json['quantity'] as double?,
      unit: json['unit'] as String?,
      isChecked: json['isChecked'] as bool? ?? false,
      sourceRecipeIds: (json['sourceRecipeIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  /// Get display string for the item
  String get displayString {
    final parts = <String>[];
    if (quantity != null) {
      // Format quantity nicely (remove trailing zeros)
      final qtyStr = quantity! == quantity!.toInt()
          ? quantity!.toInt().toString()
          : quantity!.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
      parts.add(qtyStr);
    }
    if (unit != null && unit!.isNotEmpty) {
      parts.add(unit!);
    }
    parts.add(ingredientName);
    return parts.join(' ');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
