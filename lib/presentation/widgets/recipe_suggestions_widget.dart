import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../providers/recipe_provider.dart';
import '../../data/models/recipe_match_model.dart';
import '../screens/recipe_detail_screen.dart';

class RecipeSuggestionsWidget extends StatelessWidget {
  const RecipeSuggestionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RecipeProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.recommendations.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Top Recipe Matches',
                style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary),
              ),
            ),
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: provider.recommendations.length,
                itemBuilder: (context, index) {
                  final recipe = provider.recommendations[index];
                  return Container(
                    width: 200,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primaryMain.withOpacity(0.3)),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecipeDetailScreen(
                              recipe: RecipeMatchModel.fromJson(Map<String, dynamic>.from(recipe)),
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recipe['name'] ?? 'Unknown',
                            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Match: ${recipe['match']}',
                            style: AppTextStyles.labelMedium.copyWith(color: AppColors.success),
                          ),
                          const Spacer(),
                          if (recipe['missing'] != null && (recipe['missing'] as List).isNotEmpty)
                            Text(
                              'Missing: ${recipe['missing'].length} items',
                              style: AppTextStyles.caption.copyWith(color: AppColors.error),
                            )
                          else
                            Text(
                              'Ready to cook!',
                              style: AppTextStyles.caption.copyWith(color: AppColors.success),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (provider.smartSuggestions.isNotEmpty) ...[
               const SizedBox(height: 16),
               Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Smart Suggestions',
                  style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...(provider.smartSuggestions['extra_suggestions'] as List? ?? []).map<Widget>((e) {
                      return Chip(
                        label: Text(e.toString()),
                        backgroundColor: AppColors.accentMain.withOpacity(0.1),
                        labelStyle: const TextStyle(color: AppColors.accentMain),
                      );
                    }).toList(),
                  ],
                ),
              )
            ]
          ],
        );
      },
    );
  }
}
