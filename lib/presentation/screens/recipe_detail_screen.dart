import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/recipe_match_model.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RecipeDetailScreen extends StatelessWidget {
  final RecipeMatchModel recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildIngredientsList(),
                  const SizedBox(height: 32),
                  _buildCookingInstructions(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Add missing ingredients to cart logic could go here
        },
        backgroundColor: AppColors.primaryMain,
        icon: const Icon(Icons.shopping_cart, color: Colors.white),
        label: const Text('Add Missing Items', style: TextStyle(color: Colors.white)),
      ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.5, end: 0),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: AppColors.backgroundDark,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.backgroundDark.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
            Center(
              child: Icon(
                Icons.restaurant_menu,
                size: 100,
                color: AppColors.primaryMain.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                recipe.name,
                style: AppTextStyles.displaySmall.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.orange, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '4.5',
                    style: AppTextStyles.labelMedium.copyWith(color: AppColors.success),
                  ),
                ],
              ),
            ),
          ],
        ).animate().fadeIn().slideX(begin: -0.1, end: 0),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.timer_outlined, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text('25 mins', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
            const SizedBox(width: 16),
            const Icon(Icons.local_fire_department_outlined, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text('320 kcal', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
          ],
        ).animate().fadeIn(delay: 200.ms),
      ],
    );
  }

  Widget _buildIngredientsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ingredients Needed', style: AppTextStyles.titleLarge),
        const SizedBox(height: 12),
        if (recipe.missing.isEmpty)
          Text('You have everything you need!', 
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.success))
        else
          ...recipe.missing.map((ing) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 8, color: AppColors.primaryMain),
                    const SizedBox(width: 12),
                    Text(ing, style: AppTextStyles.bodyMedium),
                  ],
                ),
              )),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildCookingInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cooking Steps', style: AppTextStyles.titleLarge),
        const SizedBox(height: 12),
        _buildStep(1, "Prepare all your ingredients and wash the vegetables."),
        _buildStep(2, "Mix the ingredients in a large bowl and season to taste."),
        _buildStep(3, "Cook on medium heat for 15-20 minutes until golden brown."),
        _buildStep(4, "Serve hot with your favorite side dish."),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: AppColors.primaryMain,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}
