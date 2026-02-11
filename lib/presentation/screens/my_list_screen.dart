import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../providers/grocery_provider.dart';
import '../widgets/animated_grocery_item.dart';
import '../widgets/category_card.dart';
import 'add_edit_item_screen.dart';

/// My List Screen - Enhanced grocery list with smart organization
class MyListScreen extends StatefulWidget {
  const MyListScreen({super.key});

  @override
  State<MyListScreen> createState() => _MyListScreenState();
}

class _MyListScreenState extends State<MyListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroceryProvider>().loadItems();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openAddItemScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddEditItemScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with Statistics
            _buildHeader(),
            
            // Tab Bar
            _buildTabBar(),
            
            // List Content
            Expanded(
              child: Consumer<GroceryProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildActiveList(provider),
                      _buildCompletedList(provider),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: FloatingActionButton.extended(
          onPressed: _openAddItemScreen,
          backgroundColor: AppColors.primaryMain,
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            'Add Item',
            style: AppTextStyles.labelLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ).animate().fadeIn(delay: const Duration(milliseconds: 300))
        .slideY(begin: 0.5, end: 0),
    );
  }

  Widget _buildHeader() {
    return Consumer<GroceryProvider>(
      builder: (context, provider, child) {
        final totalItems = provider.activeItemsCount;
        final completedItems = provider.completedItems.length;
        final progressPercent = totalItems > 0
            ? (completedItems / (totalItems + completedItems) * 100).toInt()
            : 0;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryMain.withValues(alpha: 0.1),
                AppColors.accentMain.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(24),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Shopping List',
                        style: AppTextStyles.displaySmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        totalItems == 0
                            ? 'Your list is empty'
                            : '$totalItems ${totalItems == 1 ? 'item' : 'items'} to buy',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryMain.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      color: AppColors.primaryMain,
                      size: 32,
                    ),
                  ),
                ],
              ),
              
              if (totalItems > 0 || completedItems > 0) ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildStatCard(
                      'Active',
                      totalItems.toString(),
                      Icons.shopping_cart,
                      AppColors.info,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      'Done',
                      completedItems.toString(),
                      Icons.check_circle,
                      AppColors.success,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      'Progress',
                      '$progressPercent%',
                      Icons.trending_up,
                      AppColors.accentMain,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryMain.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Projected Total:', style: AppTextStyles.bodySmall),
                      Text(
                        '₹${provider.projectedCost.toStringAsFixed(0)}',
                        style: AppTextStyles.titleMedium.copyWith(color: AppColors.primaryMain, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ).animate().fadeIn().slideY(begin: -0.2, end: 0);
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.titleMedium.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primaryMain,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTextStyles.labelLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'Active Items'),
          Tab(text: 'Completed'),
        ],
      ),
    );
  }

  Widget _buildActiveList(GroceryProvider provider) {
    if (provider.activeItems.isEmpty) {
      return _buildEmptyState();
    }

    final itemsByCategory = provider.itemsByCategory;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: itemsByCategory.length,
      itemBuilder: (context, index) {
        final entry = itemsByCategory.entries.elementAt(index);
        final category = entry.key;
        final items = entry.value;

        return CategoryCard(
          category: category,
          itemCount: items.length,
          children: items.map((item) {
            return Slidable(
              key: ValueKey(item.id),
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (_) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AddEditItemScreen(item: item),
                        ),
                      );
                    },
                    backgroundColor: AppColors.info,
                    foregroundColor: Colors.white,
                    icon: Icons.edit,
                    label: 'Edit',
                    borderRadius: BorderRadius.circular(12),
                  ),
                  SlidableAction(
                    onPressed: (_) => provider.deleteItem(item.id),
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Delete',
                    borderRadius: BorderRadius.circular(12),
                  ),
                ],
              ),
              child: AnimatedGroceryItem(
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
              ),
            );
          }).toList(),
        ).animate().fadeIn(delay: Duration(milliseconds: index * 100))
          .slideX(begin: -0.2, end: 0);
      },
    );
  }

  Widget _buildCompletedList(GroceryProvider provider) {
    if (provider.completedItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline,
                size: 80,
                color: AppColors.success.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No completed items yet',
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Check off items to see them here',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${provider.completedItems.length} completed',
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.success,
                ),
              ),
              TextButton.icon(
                onPressed: () async {
                  await provider.checkout();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Purchase completed and saved to history!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.shopping_cart_checkout, size: 20),
                label: const Text('Checkout'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryMain,
                ),
              ),
              TextButton.icon(
                onPressed: () => provider.clearCompletedItems(),
                icon: const Icon(Icons.delete_sweep, size: 20),
                label: const Text('Clear All'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            itemCount: provider.completedItems.length,
            itemBuilder: (context, index) {
              final item = provider.completedItems[index];
              return Slidable(
                key: ValueKey(item.id),
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (_) => provider.deleteItem(item.id),
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ],
                ),
                child: AnimatedGroceryItem(
                  item: item,
                  onToggle: () => provider.toggleItemStatus(item.id),
                  onDelete: () => provider.deleteItem(item.id),
                  onEdit: () {},
                ),
              ).animate().fadeIn(delay: Duration(milliseconds: index * 50))
                .slideX(begin: 0.2, end: 0);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryMain.withValues(alpha: 0.2),
                      AppColors.accentMain.withValues(alpha: 0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shopping_cart_outlined,
                  size: 60,
                  color: AppColors.primaryMain.withValues(alpha: 0.5),
                ),
              ).animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: const Duration(seconds: 2)),
              const SizedBox(height: 32),
              Text(
                'Your cart is empty',
                style: AppTextStyles.displaySmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start adding items to your shopping list',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildActionHint(
                    Icons.add,
                    'Tap + button',
                    AppColors.primaryMain,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'or',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildActionHint(
                    Icons.mic,
                    'Use voice',
                    AppColors.accentMain,
                  ),
                ],
              ),
            ],
          ),
        ),
      ).animate().fadeIn(delay: const Duration(milliseconds: 200)),
    );
  }

  Widget _buildActionHint(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTextStyles.labelMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
