import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../providers/grocery_provider.dart';
import 'settings_screen.dart';

/// Profile Screen - User insights, statistics, and achievements
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Profile Header
            SliverToBoxAdapter(
              child: _buildProfileHeader(context),
            ),
            
            // Statistics Cards
            SliverToBoxAdapter(
              child: _buildStatistics(context),
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
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
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
                  'Level 5 - Expert',
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

  Widget _buildStatistics(BuildContext context) {
    return Consumer<GroceryProvider>(
      builder: (context, provider, child) {
        final totalItems = provider.activeItemsCount + provider.completedItems.length;
        
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This Week',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildStatCard(
                    'Items Added',
                    totalItems.toString(),
                    Icons.add_shopping_cart,
                    AppColors.info,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    'Completed',
                    provider.completedItems.length.toString(),
                    Icons.check_circle,
                    AppColors.success,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatCard(
                    'Money Saved',
                    '\$${(totalItems * 3.5).toStringAsFixed(0)}',
                    Icons.savings,
                    AppColors.warning,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    'Voice Orders',
                    '12',
                    Icons.mic,
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
                      'Last 30 days',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 50,
                      sections: [
                        PieChartSectionData(
                          color: AppColors.categoryVegetables,
                          value: 30,
                          title: '30%',
                          radius: 60,
                          titleStyle: AppTextStyles.labelMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        PieChartSectionData(
                          color: AppColors.categoryFruits,
                          value: 25,
                          title: '25%',
                          radius: 60,
                          titleStyle: AppTextStyles.labelMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        PieChartSectionData(
                          color: AppColors.categoryDairy,
                          value: 20,
                          title: '20%',
                          radius: 60,
                          titleStyle: AppTextStyles.labelMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        PieChartSectionData(
                          color: AppColors.categoryMeat,
                          value: 15,
                          title: '15%',
                          radius: 60,
                          titleStyle: AppTextStyles.labelMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        PieChartSectionData(
                          color: AppColors.categoryOther,
                          value: 10,
                          title: '10%',
                          radius: 60,
                          titleStyle: AppTextStyles.labelMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _buildLegendItem('Vegetables', AppColors.categoryVegetables),
                    _buildLegendItem('Fruits', AppColors.categoryFruits),
                    _buildLegendItem('Dairy', AppColors.categoryDairy),
                    _buildLegendItem('Meat', AppColors.categoryMeat),
                    _buildLegendItem('Other', AppColors.categoryOther),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: const Duration(milliseconds: 300))
      .slideY(begin: 0.2, end: 0);
  }

  Widget _buildLegendItem(String label, Color color) {
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
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievements() {
    final achievements = [
      _Achievement('First Steps', Icons.flag, AppColors.info, true),
      _Achievement('Voice Master', Icons.mic, AppColors.accentMain, true),
      _Achievement('Savings Pro', Icons.savings, AppColors.warning, true),
      _Achievement('100 Items', Icons.shopping_bag, AppColors.success, false),
      _Achievement('Recipe Chef', Icons.restaurant, AppColors.categoryFruits, false),
      _Achievement('Budget King', Icons.trending_up, AppColors.primaryMain, false),
    ];

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
              Text(
                '3/6 Unlocked',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.success,
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
              return Container(
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
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
            },
          ),
        ],
      ),
    ).animate().fadeIn(delay: const Duration(milliseconds: 400))
      .slideX(begin: 0.2, end: 0);
  }

  Widget _buildQuickSettings(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingTile(
            'Edit Profile',
            Icons.edit,
            AppColors.info,
            () {},
          ),
          _buildSettingTile(
            'Notification Settings',
            Icons.notifications,
            AppColors.warning,
            () {},
          ),
          _buildSettingTile(
            'Help & Support',
            Icons.help,
            AppColors.accentMain,
            () {},
          ),
          _buildSettingTile(
            'About App',
            Icons.info,
            AppColors.textSecondary,
            () {},
          ),
        ],
      ),
    ).animate().fadeIn(delay: const Duration(milliseconds: 500))
      .slideY(begin: 0.2, end: 0);
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
