import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Recipe Suggestion Card - Beautiful recipe cards
class RecipeSuggestionCard extends StatelessWidget {
  final int index;

  const RecipeSuggestionCard({
    super.key,
    required this.index,
  });

  static final List<_Recipe> _recipes = [
    _Recipe(
      name: 'Veggie Stir Fry',
      cookTime: '15 min',
      difficulty: 'Easy',
      ingredients: 5,
      color: AppColors.categoryVegetables,
    ),
    _Recipe(
      name: 'Fresh Fruit Salad',
      cookTime: '10 min',
      difficulty: 'Easy',
      ingredients: 4,
      color: AppColors.categoryFruits,
    ),
    _Recipe(
      name: 'Cheese Omelette',
      cookTime: '12 min',
      difficulty: 'Easy',
      ingredients: 3,
      color: AppColors.categoryDairy,
    ),
    _Recipe(
      name: 'Grilled Chicken',
      cookTime: '25 min',
      difficulty: 'Medium',
      ingredients: 6,
      color: AppColors.categoryMeat,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final recipe = _recipes[index % _recipes.length];
    
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            recipe.color.withValues(alpha: 0.3),
            recipe.color.withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(
          color: recipe.color.withValues(alpha: 0.4),
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
                Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    color: recipe.color.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.restaurant_menu,
                    size: 48,
                    color: recipe.color,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  recipe.name,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.timer, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      recipe.cookTime,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.restaurant, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${recipe.ingredients} items',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: recipe.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    recipe.difficulty,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: recipe.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Recipe {
  final String name;
  final String cookTime;
  final String difficulty;
  final int ingredients;
  final Color color;

  _Recipe({
    required this.name,
    required this.cookTime,
    required this.difficulty,
    required this.ingredients,
    required this.color,
  });
}
