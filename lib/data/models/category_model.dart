import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../core/theme/app_colors.dart';

part 'category_model.g.dart';

/// Category enumeration for grocery items
/// Each category has associated color and icon for visual distinction
@HiveType(typeId: 1)
enum GroceryCategory {
  @HiveField(0)
  fruits,
  @HiveField(1)
  vegetables,
  @HiveField(2)
  dairy,
  @HiveField(3)
  meat,
  @HiveField(4)
  bakery,
  @HiveField(5)
  beverages,
  @HiveField(6)
  snacks,
  @HiveField(7)
  other,
}

/// Extension to provide UI properties for each category
extension GroceryCategoryExtension on GroceryCategory {
  String get displayName {
    switch (this) {
      case GroceryCategory.fruits:
        return 'Fruits';
      case GroceryCategory.vegetables:
        return 'Vegetables';
      case GroceryCategory.dairy:
        return 'Dairy';
      case GroceryCategory.meat:
        return 'Meat & Seafood';
      case GroceryCategory.bakery:
        return 'Bakery';
      case GroceryCategory.beverages:
        return 'Beverages';
      case GroceryCategory.snacks:
        return 'Snacks';
      case GroceryCategory.other:
        return 'Other';
    }
  }

  Color get color {
    switch (this) {
      case GroceryCategory.fruits:
        return AppColors.categoryFruits;
      case GroceryCategory.vegetables:
        return AppColors.categoryVegetables;
      case GroceryCategory.dairy:
        return AppColors.categoryDairy;
      case GroceryCategory.meat:
        return AppColors.categoryMeat;
      case GroceryCategory.bakery:
        return AppColors.categoryBakery;
      case GroceryCategory.beverages:
        return AppColors.categoryBeverages;
      case GroceryCategory.snacks:
        return AppColors.categorySnacks;
      case GroceryCategory.other:
        return AppColors.categoryOther;
    }
  }

  IconData get icon {
    switch (this) {
      case GroceryCategory.fruits:
        return Icons.apple;
      case GroceryCategory.vegetables:
        return Icons.eco;
      case GroceryCategory.dairy:
        return Icons.water_drop;
      case GroceryCategory.meat:
        return Icons.set_meal;
      case GroceryCategory.bakery:
        return Icons.bakery_dining;
      case GroceryCategory.beverages:
        return Icons.local_cafe;
      case GroceryCategory.snacks:
        return Icons.cookie;
      case GroceryCategory.other:
        return Icons.shopping_basket;
    }
  }

  String get emoji {
    switch (this) {
      case GroceryCategory.fruits:
        return '🍎';
      case GroceryCategory.vegetables:
        return '🥬';
      case GroceryCategory.dairy:
        return '🥛';
      case GroceryCategory.meat:
        return '🥩';
      case GroceryCategory.bakery:
        return '🍞';
      case GroceryCategory.beverages:
        return '☕';
      case GroceryCategory.snacks:
        return '🍿';
      case GroceryCategory.other:
        return '🛒';
    }
  }
}
