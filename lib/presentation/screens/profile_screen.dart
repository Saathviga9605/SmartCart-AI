import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../providers/grocery_provider.dart';
import '../../data/datasources/hive_service.dart';
import 'settings_screen.dart';
import 'history_screen.dart';
import 'barcode_scanner_screen.dart';
import 'recipe_generator_screen.dart';
import 'store_locator_screen.dart';

/// Profile Screen - User insights, statistics, and achievements
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late HiveService _hiveService;
  List<Map<String, dynamic>> _history = [];
  
  @override
  void initState() {
    super.initState();
    _hiveService = context.read<HiveService>();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _history = _hiveService.getHistory();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _loadData(),
          child: CustomScrollView(
            slivers: [
              // Profile Header
              SliverToBoxAdapter(
                child: _buildProfileHeader(context),
              ),
              
              // Quick Actions Bar
              SliverToBoxAdapter(
                child: _buildQuickActionsBar(context),
              ),
              
              // Statistics Cards
              SliverToBoxAdapter(
                child: _buildStatistics(context),
              ),
              
              // Budget Tracker
              SliverToBoxAdapter(
                child: _buildBudgetTracker(context),
              ),
              
              // Shopping Insights
              SliverToBoxAdapter(
                child: _buildInsightsSection(),
              ),
              
              // Achievements
              SliverToBoxAdapter(
                child: _buildAchievements(),
              ),
              
              // Quick Settings
              SliverToBoxAdapter(
                child: _buildQuickSettings(context),
              ),
              
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  // Calculate statistics from real history data
  Map<String, dynamic> _calculateStats() {
    int totalSessions = _history.length;
    int totalItemsPurchased = 0;
    double estimatedSpent = 0;
    Map<String, int> categoryCount = {};
    
    for (var session in _history) {
      List items = session['items'] ?? [];
      for (var item in items) {
        totalItemsPurchased += (item['quantity'] ?? 1) as int;
        
        // Count categories
        String category = item['category'] ?? 'other';
        categoryCount[category] = (categoryCount[category] ?? 0) + 1;
        
        // Estimate cost based on category
        double itemPrice = _getEstimatedPrice(category);
        estimatedSpent += itemPrice * (item['quantity'] ?? 1);
      }
    }
    
    return {
      'totalSessions': totalSessions,
      'totalItems': totalItemsPurchased,
      'estimatedSpent': estimatedSpent,
      'categoryCount': categoryCount,
      'avgItemsPerSession': totalSessions > 0 ? totalItemsPurchased / totalSessions : 0,
    };
  }

  double _getEstimatedPrice(String category) {
    switch (category.toLowerCase()) {
      case 'fruits': return 100;
      case 'vegetables': return 40;
      case 'dairy': return 150;
      case 'meat': return 250;
      case 'bakery': return 60;
      case 'beverages': return 80;
      case 'snacks': return 90;
      default: return 120;
    }
  }

  Widget _buildProfileHeader(BuildContext context) {
    final stats = _calculateStats();
    final level = (stats['totalSessions'] / 5).floor() + 1;
    final levelName = _getLevelName(level);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryMain.withValues(alpha: 0.2),
            AppColors.accentMain.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Profile',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 3,
              ),
            ),
            child: const Icon(
              Icons.person,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Smart Shopper',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, size: 16, color: AppColors.success),
                const SizedBox(width: 4),
                Text(
                  'Level $level - $levelName',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2, end: 0);
  }

  String _getLevelName(int level) {
    if (level >= 20) return 'Legendary';
    if (level >= 15) return 'Master';
    if (level >= 10) return 'Expert';
    if (level >= 5) return 'Pro';
    return 'Beginner';
  }

  Widget _buildQuickActionsBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  'History',
                  Icons.history,
                  AppColors.info,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HistoryScreen()),
                    ).then((_) => _loadData());
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  'Recipes',
                  Icons.restaurant_menu,
                  AppColors.accentMain,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RecipeGeneratorScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  'Scan',
                  Icons.qr_code_scanner,
                  AppColors.warning,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  'Stores',
                  Icons.store,
                  AppColors.success,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StoreLocatorScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  'Share',
                  Icons.share,
                  AppColors.primaryMain,
                  () => _shareShoppingList(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  'Favorites',
                  Icons.favorite,
                  AppColors.error,
                  () => _showFavorites(context),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: const Duration(milliseconds: 100))
      .slideX(begin: -0.2, end: 0);
  }

  Widget _buildQuickActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareShoppingList(BuildContext context) async {
    final provider = context.read<GroceryProvider>();
    final items = provider.activeItems;
    
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No items to share')),
      );
      return;
    }
    
    final String listText = items.map((item) => 
      '• ${item.quantity}x ${item.name}'
    ).join('\n');
    
    await Share.share(
      'My Shopping List:\n\n$listText\n\nShared from SmartPantry',
      subject: 'Shopping List',
    );
  }

  void _showFavorites(BuildContext context) {
    final stats = _calculateStats();
    final categoryCount = stats['categoryCount'] as Map<String, int>;
    final favorites = categoryCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Most Bought Categories',
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (favorites.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No purchase history yet'),
                ),
              )
            else
              ...favorites.take(5).map((entry) => ListTile(
                leading: Icon(
                  _getCategoryIcon(entry.key),
                  color: _getCategoryColor(entry.key),
                ),
                title: Text(entry.key),
                trailing: Text(
                  '${entry.value} items',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'fruits': return Icons.apple;
      case 'vegetables': return Icons.eco;
      case 'dairy': return Icons.water_drop;
      case 'meat': return Icons.set_meal;
      case 'bakery': return Icons.bakery_dining;
      case 'beverages': return Icons.local_drink;
      case 'snacks': return Icons.cookie;
      default: return Icons.shopping_basket;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'fruits': return AppColors.categoryFruits;
      case 'vegetables': return AppColors.categoryVegetables;
      case 'dairy': return AppColors.categoryDairy;
      case 'meat': return AppColors.categoryMeat;
      case 'bakery': return AppColors.categoryBakery;
      case 'beverages': return AppColors.categoryBeverages;
      case 'snacks': return AppColors.categorySnacks;
      default: return AppColors.categoryOther;
    }
  }

  Widget _buildStatistics(BuildContext context) {
    return Consumer<GroceryProvider>(
      builder: (context, provider, child) {
        final stats = _calculateStats();
        final totalItems = provider.activeItemsCount + provider.completedItems.length;
        
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Shopping Statistics',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HistoryScreen()),
                      ).then((_) => _loadData());
                    },
                    icon: const Icon(Icons.history, size: 16),
                    label: const Text('View All'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryMain,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildStatCard(
                    'Total Trips',
                    stats['totalSessions'].toString(),
                    Icons.shopping_bag,
                    AppColors.info,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    'Items Bought',
                    stats['totalItems'].toString(),
                    Icons.shopping_cart,
                    AppColors.success,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatCard(
                    'This Week',
                    totalItems.toString(),
                    Icons.calendar_today,
                    AppColors.warning,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    'Avg/Trip',
                    stats['avgItemsPerSession'].toStringAsFixed(1),
                    Icons.trending_up,
                    AppColors.accentMain,
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(delay: const Duration(milliseconds: 200))
          .slideX(begin: -0.2, end: 0);
      },
    );
  }

  Widget _buildBudgetTracker(BuildContext context) {
    final stats = _calculateStats();
    final estimatedSpent = stats['estimatedSpent'] as double;
    final monthlyBudget = 15000.0; // This could be user-configurable (INR)
    final percentUsed = (estimatedSpent / monthlyBudget * 100).clamp(0, 100);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryMain.withValues(alpha: 0.1),
              AppColors.accentMain.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primaryMain.withValues(alpha: 0.2),
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
                      'Monthly Budget',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Track your spending',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.account_balance_wallet, 
                    color: AppColors.success, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '₹${estimatedSpent.toStringAsFixed(0)}',
                      style: AppTextStyles.displaySmall.copyWith(
                        color: AppColors.primaryMain,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'spent this month',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${monthlyBudget.toStringAsFixed(0)}',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'budget',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percentUsed / 100,
                minHeight: 12,
                backgroundColor: AppColors.surfaceDark,
                valueColor: AlwaysStoppedAnimation<Color>(
                  percentUsed > 90 
                    ? AppColors.error 
                    : percentUsed > 70 
                      ? AppColors.warning 
                      : AppColors.success,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${percentUsed.toStringAsFixed(0)}% used',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '₹${(monthlyBudget - estimatedSpent).toStringAsFixed(0)} left',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: percentUsed > 90 ? AppColors.error : AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: const Duration(milliseconds: 250))
      .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: AppTextStyles.titleLarge.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsSection() {
    final stats = _calculateStats();
    final categoryCount = stats['categoryCount'] as Map<String, int>;
    
    if (categoryCount.isEmpty) {
      return const SizedBox.shrink();
    }

    // Convert to list and sort by count
    final sortedCategories = categoryCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Take top 5 categories
    final topCategories = sortedCategories.take(5).toList();
    final total = topCategories.fold<int>(0, (sum, entry) => sum + entry.value);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shopping Insights',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Most Bought Categories',
                      style: AppTextStyles.titleSmall,
                    ),
                    Text(
                      'All time',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (topCategories.length >= 3)
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 50,
                        sections: topCategories.map((entry) {
                          final percentage = (entry.value / total * 100);
                          return PieChartSectionData(
                            color: _getCategoryColor(entry.key),
                            value: entry.value.toDouble(),
                            title: '${percentage.toStringAsFixed(0)}%',
                            radius: 60,
                            titleStyle: AppTextStyles.labelMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Shop more to see insights',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: topCategories.map((entry) {
                    return _buildLegendItem(
                      entry.key,
                      _getCategoryColor(entry.key),
                      entry.value,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: const Duration(milliseconds: 300))
      .slideY(begin: 0.2, end: 0);
  }

  Widget _buildLegendItem(String label, Color color, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label ($count)',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievements() {
    final stats = _calculateStats();
    final totalSessions = stats['totalSessions'] as int;
    final totalItems = stats['totalItems'] as int;
    
    final achievements = [
      _Achievement('First Steps', Icons.flag, AppColors.info, totalSessions >= 1),
      _Achievement('Voice Master', Icons.mic, AppColors.accentMain, totalItems >= 5),
      _Achievement('Savings Pro', Icons.savings, AppColors.warning, totalItems >= 20),
      _Achievement('100 Items', Icons.shopping_bag, AppColors.success, totalItems >= 100),
      _Achievement('10 Trips', Icons.shopping_cart, AppColors.categoryFruits, totalSessions >= 10),
      _Achievement('Budget King', Icons.trending_up, AppColors.primaryMain, totalItems >= 50),
    ];

    final unlockedCount = achievements.where((a) => a.unlocked).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Achievements',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unlockedCount/${achievements.length} Unlocked',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              return GestureDetector(
                onTap: () => _showAchievementDetails(achievement, index),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: achievement.unlocked
                        ? achievement.color.withValues(alpha: 0.2)
                        : AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: achievement.unlocked
                          ? achievement.color.withValues(alpha: 0.3)
                          : AppColors.textDisabled.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        achievement.icon,
                        color: achievement.unlocked
                            ? achievement.color
                            : AppColors.textDisabled,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        achievement.title,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: achievement.unlocked
                              ? achievement.color
                              : AppColors.textDisabled,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: Duration(milliseconds: index * 100))
                  .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(delay: const Duration(milliseconds: 400))
      .slideX(begin: 0.2, end: 0);
  }

  void _showAchievementDetails(_Achievement achievement, int index) {
    final descriptions = [
      'Complete your first shopping trip',
      'Use voice input 5 times',
      'Purchase 20 items total',
      'Reach 100 items purchased',
      'Complete 10 shopping trips',
      'Purchase 50 items total',
    ];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: Row(
          children: [
            Icon(achievement.icon, color: achievement.color),
            const SizedBox(width: 8),
            Text(achievement.title),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              descriptions[index],
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 12),
            if (achievement.unlocked)
              Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Unlocked!',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  const Icon(Icons.lock, color: AppColors.textDisabled, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Keep going!',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textDisabled,
                    ),
                  ),
                ],
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSettings(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryMain.withOpacity(0.1), AppColors.accentMain.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryMain.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Settings',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingTile(
            'Barcode Scanner',
            Icons.qr_code_scanner,
            AppColors.info,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
              );
            },
          ),
          _buildSettingTile(
            'Store Locator',
            Icons.location_on,
            AppColors.success,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StoreLocatorScreen()),
              );
            },
          ),
          _buildSettingTile(
            'Recipe Generator',
            Icons.restaurant,
            AppColors.accentMain,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RecipeGeneratorScreen()),
              );
            },
          ),
          _buildSettingTile(
            'Shopping Templates',
            Icons.content_copy,
            AppColors.warning,
            () => _showTemplates(context),
          ),
          _buildSettingTile(
            'Export Shopping Data',
            Icons.file_download,
            AppColors.primaryMain,
            () => _exportData(context),
          ),
          _buildSettingTile(
            'Price Comparison',
            Icons.compare_arrows,
            AppColors.info,
            () => _showPriceComparison(context),
          ),
          _buildSettingTile(
            'Notification Settings',
            Icons.notifications,
            AppColors.warning,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          _buildSettingTile(
            'Help & Support',
            Icons.help,
            AppColors.textSecondary,
            () => _showHelp(context),
          ),
        ],
      ),
    ).animate().fadeIn(delay: const Duration(milliseconds: 500))
      .slideY(begin: 0.2, end: 0);
  }

  void _showTemplates(BuildContext context) {
    final templates = [
      {'name': 'Weekly Groceries', 'icon': Icons.calendar_view_week, 'items': ['Milk', 'Bread', 'Eggs', 'Vegetables']},
      {'name': 'Breakfast Essentials', 'icon': Icons.breakfast_dining, 'items': ['Cereal', 'Milk', 'Fruits', 'Yogurt']},
      {'name': 'Party Supplies', 'icon': Icons.celebration, 'items': ['Chips', 'Drinks', 'Snacks', 'Napkins']},
    ];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shopping Templates',
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...templates.map((template) => ListTile(
              leading: Icon(template['icon'] as IconData, color: AppColors.primaryMain),
              title: Text(template['name'] as String),
              subtitle: Text('${(template['items'] as List).length} items'),
              trailing: const Icon(Icons.add_circle_outline),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${template['name']} template coming soon!')),
                );
              },
            )),
          ],
        ),
      ),
    );
  }

  void _exportData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('Export Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.description, color: AppColors.info),
              title: const Text('Export as CSV'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('CSV export coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.code, color: AppColors.warning),
              title: const Text('Export as JSON'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('JSON export coming soon!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPriceComparison(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: Row(
          children: [
            const Icon(Icons.compare_arrows, color: AppColors.warning),
            const SizedBox(width: 8),
            const Text('Price Comparison'),
          ],
        ),
        content: const Text(
          'Compare prices across different stores to find the best deals. This feature will help you save money on your shopping!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Price comparison coming soon!')),
              );
            },
            child: const Text('Learn More'),
          ),
        ],
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Help & Support',
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.book, color: AppColors.info),
              title: const Text('User Guide'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User guide coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library, color: AppColors.warning),
              title: const Text('Tutorial Videos'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tutorials coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_support, color: AppColors.error),
              title: const Text('Contact Support'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('support@smartpantry.com')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyMedium,
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _Achievement {
  final String title;
  final IconData icon;
  final Color color;
  final bool unlocked;

  _Achievement(this.title, this.icon, this.color, this.unlocked);
}
