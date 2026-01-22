import 'package:uuid/uuid.dart';

import 'ingredient.dart';

/// Source type for how the recipe was added
enum RecipeSource {
  text,
  url,
  manual,
}

/// Represents a recipe with its ingredients
class Recipe {
  final String id;
  final String title;
  final RecipeSource source;
  final String? sourceUrl;
  final String? rawText;
  final List<Ingredient> ingredients;
  final DateTime createdAt;
  final DateTime updatedAt;

  Recipe({
    String? id,
    required this.title,
    required this.source,
    this.sourceUrl,
    this.rawText,
    List<Ingredient>? ingredients,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        ingredients = ingredients ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Create a copy with updated fields
  Recipe copyWith({
    String? id,
    String? title,
    RecipeSource? source,
    String? sourceUrl,
    String? rawText,
    List<Ingredient>? ingredients,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      source: source ?? this.source,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      rawText: rawText ?? this.rawText,
      ingredients: ingredients ?? this.ingredients,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Get ingredient count
  int get ingredientCount => ingredients.length;

  /// Get source label for display
  String get sourceLabel {
    switch (source) {
      case RecipeSource.text:
        return 'Text input';
      case RecipeSource.url:
        return sourceUrl ?? 'URL';
      case RecipeSource.manual:
        return 'Manual entry';
    }
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as String?,
      title: json['title'] as String,
      source: RecipeSource.values.firstWhere(
        (e) => e.name == json['source'],
        orElse: () => RecipeSource.text,
      ),
      sourceUrl: json['sourceUrl'] as String?,
      rawText: json['rawText'] as String?,
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'source': source.name,
      'sourceUrl': sourceUrl,
      'rawText': rawText,
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'Recipe($title, ${ingredients.length} ingredients)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Recipe && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
