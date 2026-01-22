import 'package:uuid/uuid.dart';

import 'list_item.dart';

/// Represents a shopping list containing items from one or more recipes
class ShoppingList {
  final String id;
  final String name;
  final List<ListItem> items;
  final List<String> recipeIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  ShoppingList({
    String? id,
    required this.name,
    this.items = const [],
    this.recipeIds = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Create a copy with updated fields
  ShoppingList copyWith({
    String? id,
    String? name,
    List<ListItem>? items,
    List<String>? recipeIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShoppingList(
      id: id ?? this.id,
      name: name ?? this.name,
      items: items ?? this.items,
      recipeIds: recipeIds ?? this.recipeIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Convert to JSON map for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'items': items.map((e) => e.toJson()).toList(),
      'recipeIds': recipeIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON map
  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    return ShoppingList(
      id: json['id'] as String,
      name: json['name'] as String,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => ListItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      recipeIds: (json['recipeIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Get count of checked items
  int get checkedCount => items.where((item) => item.isChecked).length;

  /// Get count of unchecked items
  int get uncheckedCount => items.where((item) => !item.isChecked).length;

  /// Get total item count
  int get totalCount => items.length;

  /// Get progress as a percentage (0.0 to 1.0)
  double get progress => totalCount == 0 ? 0 : checkedCount / totalCount;

  /// Check if all items are checked
  bool get isComplete => totalCount > 0 && checkedCount == totalCount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShoppingList &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
