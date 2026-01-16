import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Smart Suggestion Card - AI-powered item recommendations
class SmartSuggestionCard extends StatelessWidget {
  final int index;

  const SmartSuggestionCard({
    super.key,
    required this.index,
  });

  static final List<_Suggestion> _suggestions = [
    _Suggestion(
      name: 'Organic Bananas',
      category: 'Fruits',
      price: '\$3.99',
      icon: Icons.set_meal,
      color: AppColors.categoryFruits,
      confidence: 95,
    ),
    _Suggestion(
      name: 'Fresh Milk',
      category: 'Dairy',
      price: '\$4.50',
      icon: Icons.icecream,
      color: AppColors.categoryDairy,
      confidence: 90,
    ),
    _Suggestion(
      name: 'Whole Wheat Bread',
      category: 'Bakery',
      price: '\$2.99',
      icon: Icons.bakery_dining,
      color: AppColors.categoryBakery,
      confidence: 88,
    ),
    _Suggestion(
      name: 'Greek Yogurt',
      category: 'Dairy',
      price: '\$5.99',
      icon: Icons.breakfast_dining,
      color: AppColors.categoryDairy,
      confidence: 85,
    ),
    _Suggestion(
      name: 'Cherry Tomatoes',
      category: 'Vegetables',
      price: '\$4.25',
      icon: Icons.eco,
      color: AppColors.categoryVegetables,
      confidence: 82,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final suggestion = _suggestions[index % _suggestions.length];
    
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: suggestion.color.withValues(alpha: 0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
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
                        color: suggestion.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        suggestion.icon,
                        color: suggestion.color,
                        size: 24,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                            '${suggestion.confidence}%',
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
                  suggestion.name,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  suggestion.category,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      suggestion.price,
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
}

class _Suggestion {
  final String name;
  final String category;
  final String price;
  final IconData icon;
  final Color color;
  final int confidence;

  _Suggestion({
    required this.name,
    required this.category,
    required this.price,
    required this.icon,
    required this.color,
    required this.confidence,
  });
}
