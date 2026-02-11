import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../providers/grocery_provider.dart';

import '../widgets/floating_mic_button.dart';
import '../widgets/category_card.dart';
import '../widgets/animated_grocery_item.dart';
import 'voice_input_overlay.dart';
import 'add_edit_item_screen.dart';
import 'settings_screen.dart';
import '../providers/recipe_provider.dart';
import 'history_screen.dart';
import '../widgets/recipe_suggestions_widget.dart';

/// Home Screen - The core UI of SmartCart AI
/// Premium design with smooth animations and delightful interactions
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fabAnimationController;

  @override
  void initState() {
    super.initState();
    
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Load grocery items and listen for changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final grocery = context.read<GroceryProvider>();
      grocery.loadItems();
      
      // Auto-refresh recipes when list changes
      grocery.addListener(_refreshRecommendations);
    });
  }

  void _refreshRecommendations() {
    if (!mounted) return;
    final grocery = context.read<GroceryProvider>();
    final ingredients = grocery.activeItems.map((e) => e.name).toList();
    context.read<RecipeProvider>().fetchRecommendations(ingredients);
  }

  @override
  void dispose() {
    context.read<GroceryProvider>().removeListener(_refreshRecommendations);
    _fabAnimationController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    List<String> greetings;

    if (hour < 12) {
      greetings = AppConstants.morningGreetings;
    } else if (hour < 17) {
      greetings = AppConstants.afternoonGreetings;
    } else if (hour < 21) {
      greetings = AppConstants.eveningGreetings;
    } else {
      greetings = AppConstants.nightGreetings;
    }

    return greetings[0];
  }

  void _openVoiceInput() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) =>
            const VoiceInputOverlay(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  void _openAddItemScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddEditItemScreen(),
      ),
    );
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Recipe Suggestions
            const RecipeSuggestionsWidget(),

            // Grocery List
            Expanded(
              child: Consumer<GroceryProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (provider.activeItems.isEmpty) {
                    return _buildEmptyState();
                  }

                  return _buildGroceryList(provider);
                },
              ),
            ),
          ],
        ),
      ),
      
      // Floating Mic Button
      floatingActionButton: FloatingMicButton(
        onPressed: _openVoiceInput,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: AppTextStyles.greeting.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Consumer<GroceryProvider>(
                  builder: (context, provider, child) {
                    final activeCount = provider.activeItemsCount;
                    return Text(
                      activeCount == 0
                          ? 'No items yet'
                          : '$activeCount ${activeCount == 1 ? 'item' : 'items'} to buy',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          // Add Button
          IconButton(
            onPressed: _openAddItemScreen,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryMain.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.add,
                color: AppColors.primaryMain,
              ),
            ),
          ),
          
          // History Button
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.history,
                color: AppColors.info,
              ),
            ),
          ),
          
          // Settings Button
          IconButton(
            onPressed: _openSettings,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.settings,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroceryList(GroceryProvider provider) {
    final itemsByCategory = provider.itemsByCategory;

    return RefreshIndicator(
      onRefresh: () async {
        await provider.loadItems();
      },
      color: AppColors.primaryMain,
      backgroundColor: AppColors.backgroundCard,
      child: ListView(
        padding: const EdgeInsets.only(
          left: AppTheme.spacingMedium,
          right: AppTheme.spacingMedium,
          bottom: 100, // Space for FAB
        ),
        children: [
          // Category Cards
          ...itemsByCategory.entries.map((entry) {
            final category = entry.key;
            final items = entry.value;

            return CategoryCard(
              category: category,
              itemCount: items.length,
              children: items.map((item) {
                return AnimatedGroceryItem(
                  item: item,
                  onToggle: () => provider.toggleItemStatus(item.id),
                  onDelete: () => provider.deleteItem(item.id),
                  onEdit: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddEditItemScreen(item: item),
                      ),
                    );
                  },
                );
              }).toList(),
            );
          }),
          
          // Completed Items Section
          if (provider.completedItems.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildCompletedSection(provider),
          ],
        ],
      ),
    );
  }

  Widget _buildCompletedSection(GroceryProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Completed (${provider.completedItems.length})',
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.success,
                ),
              ),
              TextButton(
                onPressed: () => provider.checkout(),
                child: Text(
                  'Checkout',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primaryMain,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...provider.completedItems.map((item) {
            return AnimatedGroceryItem(
              item: item,
              onToggle: () => provider.toggleItemStatus(item.id),
              onDelete: () => provider.deleteItem(item.id),
              onEdit: () {},
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty State Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primaryMain.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 60,
                color: AppColors.primaryMain.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            
            Text(
              AppConstants.emptyListTitle,
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            Text(
              AppConstants.emptyListSubtitle,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Hint
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: AppColors.accentMain.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.accentMain.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.mic,
                    color: AppColors.accentMain,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tap the mic button below',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.accentMain,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
