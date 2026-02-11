import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/category_model.dart';
import '../../data/models/suggestion_model.dart';
import '../providers/grocery_provider.dart';
import '../providers/ml_inference_provider.dart';
import '../providers/smartpantry_provider.dart';

/// Smart Suggestion Card - AI-powered item recommendations
class SmartSuggestionCard extends StatelessWidget {
  final SuggestionModel suggestion;

  const SmartSuggestionCard({
    super.key,
    required this.suggestion,
  });

  @override
  Widget build(BuildContext context) {
    final color = _colorForCategory(suggestion.category);
    final icon = _iconForCategory(suggestion.category);
    final confidence = (suggestion.confidence * 100).round().clamp(0, 100);

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            try {
              final grocery = context.read<GroceryProvider>();
              final ml = context.read<MLInferenceProvider>();
              final pantry = context.read<SmartPantryProvider>();
              final category = await ml.predictCategory(suggestion.itemName);
              await grocery.addItem(
                  name: suggestion.itemName, category: category);
              await pantry.refreshFromIngredients(
                  grocery.activeItems.map((e) => e.name).toList());
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${suggestion.itemName} added to your list!'),
                    backgroundColor: AppColors.success,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to add ${suggestion.itemName}'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 24,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.psychology,
                            size: 12,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '$confidence%',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  suggestion.itemName,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  suggestion.reason.isNotEmpty
                      ? suggestion.reason
                      : suggestion.category.name,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      suggestion.category.name,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.accentMain,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryMain,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _colorForCategory(GroceryCategory category) {
    switch (category) {
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

  IconData _iconForCategory(GroceryCategory category) {
    switch (category) {
      case GroceryCategory.fruits:
        return Icons.apple;
      case GroceryCategory.vegetables:
        return Icons.eco;
      case GroceryCategory.dairy:
        return Icons.icecream;
      case GroceryCategory.meat:
        return Icons.set_meal;
      case GroceryCategory.bakery:
        return Icons.bakery_dining;
      case GroceryCategory.beverages:
        return Icons.local_cafe;
      case GroceryCategory.snacks:
        return Icons.cookie;
      case GroceryCategory.other:
        return Icons.category;
    }
  }
}
