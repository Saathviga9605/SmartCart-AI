import 'package:hive/hive.dart';
import 'category_model.dart';

part 'grocery_item_model.g.dart';

/// Grocery item data model with Hive persistence
/// Represents a single item in the shopping list
@HiveType(typeId: 0)
class GroceryItemModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  GroceryCategory category;

  @HiveField(3)
  int quantity;

  @HiveField(4)
  bool isDone;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime? completedAt;

  @HiveField(7)
  String? notes;

  GroceryItemModel({
    required this.id,
    required this.name,
    required this.category,
    this.quantity = 1,
    this.isDone = false,
    required this.createdAt,
    this.completedAt,
    this.notes,
  });

  /// Create a copy with modified fields
  GroceryItemModel copyWith({
    String? id,
    String? name,
    GroceryCategory? category,
    int? quantity,
    bool? isDone,
    DateTime? createdAt,
    DateTime? completedAt,
    String? notes,
  }) {
    return GroceryItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
    );
  }

  /// Convert to JSON for potential API sync
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.name,
      'quantity': quantity,
      'isDone': isDone,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'notes': notes,
    };
  }

  /// Create from JSON
  factory GroceryItemModel.fromJson(Map<String, dynamic> json) {
    return GroceryItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: GroceryCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => GroceryCategory.other,
      ),
      quantity: json['quantity'] as int? ?? 1,
      isDone: json['isDone'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }

  @override
  String toString() {
    return 'GroceryItemModel(id: $id, name: $name, category: ${category.displayName}, quantity: $quantity, isDone: $isDone)';
  }
}
