import 'package:uuid/uuid.dart';

/// Represents a single ingredient with quantity, unit, and name
class Ingredient {
  final String id;
  final String name;
  final double? quantity;
  final String? unit;
  final String? notes;
  final String? rawText;

  Ingredient({
    String? id,
    required this.name,
    this.quantity,
    this.unit,
    this.notes,
    this.rawText,
  }) : id = id ?? const Uuid().v4();

  /// Create a copy with updated fields
  Ingredient copyWith({
    String? id,
    String? name,
    double? quantity,
    String? unit,
    String? notes,
    String? rawText,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      notes: notes ?? this.notes,
      rawText: rawText ?? this.rawText,
    );
  }

  /// Format ingredient as display string (e.g., "2 cups flour")
  String get displayString {
    final parts = <String>[];

    if (quantity != null) {
      // Format quantity nicely (remove .0 for whole numbers)
      final qtyStr = quantity == quantity!.roundToDouble()
          ? quantity!.toInt().toString()
          : quantity!.toString();
      parts.add(qtyStr);
    }

    if (unit != null && unit!.isNotEmpty) {
      parts.add(unit!);
    }

    parts.add(name);

    if (notes != null && notes!.isNotEmpty) {
      parts.add('($notes)');
    }

    return parts.join(' ');
  }

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'] as String?,
      name: json['name'] as String,
      quantity: json['quantity'] != null
          ? (json['quantity'] as num).toDouble()
          : null,
      unit: json['unit'] as String?,
      notes: json['notes'] as String?,
      rawText: json['rawText'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'notes': notes,
      'rawText': rawText,
    };
  }

  @override
  String toString() => 'Ingredient($displayString)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Ingredient && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
