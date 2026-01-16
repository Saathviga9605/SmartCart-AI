import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../providers/grocery_provider.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/smart_suggestion_card.dart';
import '../widgets/category_grid_item.dart';
import '../widgets/recipe_suggestion_card.dart';
import 'search_screen.dart';
import 'category_detail_screen.dart';

/// Discover Screen - Main hub for exploring items, recommendations, and recipes
class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  int _bannerIndex = 0;
  final CarouselSliderController _carouselController = CarouselSliderController();

  final List<_BannerData> _banners = [
    _BannerData(
      title: 'Smart Shopping\nPowered by AI',
      subtitle: 'Get personalized recommendations',
      colors: [AppColors.primaryMain, AppColors.primaryDark],
      icon: Icons.psychology,
    ),
    _BannerData(
      title: 'Voice Shopping\nMade Easy',
      subtitle: 'Just speak what you need',
      colors: [AppColors.accentMain, AppColors.accentDark],
      icon: Icons.mic,
    ),
    _BannerData(
      title: 'Recipe Ideas\nFrom Your Pantry',
      subtitle: 'Cook with what you have',
      colors: [Color(0xFFEC4899), Color(0xFFDB2777)],
      icon: Icons.restaurant_menu,
    ),
    _BannerData(
      title: 'Track & Save\nSmart Budgeting',
      subtitle: 'Monitor your spending habits',
      colors: [Color(0xFF10B981), Color(0xFF059669)],
      icon: Icons.trending_down,
    ),
  ];

  final List<_CategoryData> _categories = [
    _CategoryData('Fruits', Icons.apple, AppColors.categoryFruits, 45),
    _CategoryData('Vegetables', Icons.eco, AppColors.categoryVegetables, 68),
    _CategoryData('Dairy', Icons.icecream, AppColors.categoryDairy, 32),
    _CategoryData('Meat', Icons.set_meal, AppColors.categoryMeat, 28),
    _CategoryData('Bakery', Icons.bakery_dining, AppColors.categoryBakery, 41),
    _CategoryData('Beverages', Icons.local_cafe, AppColors.categoryBeverages, 52),
    _CategoryData('Snacks', Icons.cookie, AppColors.categorySnacks, 73),
    _CategoryData('Other', Icons.category, AppColors.categoryOther, 25),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 1));
          },
          color: AppColors.primaryMain,
          child: CustomScrollView(
            slivers: [
              // App Bar
              _buildAppBar(),
              
              // Search Bar
              SliverToBoxAdapter(
                child: _buildSearchBar(),
              ),
              
              // Promotional Banners
              SliverToBoxAdapter(
                child: _buildBannerCarousel(),
              ),
              
              // Quick Actions
              SliverToBoxAdapter(
                child: _buildQuickActions(),
              ),
              
              // AI Smart Suggestions
              SliverToBoxAdapter(
                child: _buildSmartSuggestions(),
              ),
              
              // Categories Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Shop by Category',
                        style: AppTextStyles.titleLarge,
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'See all',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.primaryMain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Categories Grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return CategoryGridItem(
                        category: _categories[index],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CategoryDetailScreen(
                                category: _categories[index],
                              ),
                            ),
                          );
                        },
                      ).animate().fadeIn(delay: Duration(milliseconds: index * 50))
                        .slideY(begin: 0.2, end: 0);
                    },
                    childCount: _categories.length,
                  ),
                ),
              ),
              
              // Recipe Suggestions
              SliverToBoxAdapter(
                child: _buildRecipeSuggestions(),
              ),
              
              // Bottom Spacing
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: AppColors.backgroundDark,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getGreeting(),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            'Discover Smart Shopping',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.notifications_outlined),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Hero(
        tag: 'search_bar',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.glassBorder.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Search for products...',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryMain.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.tune,
                      size: 18,
                      color: AppColors.primaryMain,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBannerCarousel() {
    return Column(
      children: [
        CarouselSlider.builder(
          carouselController: _carouselController,
          itemCount: _banners.length,
          options: CarouselOptions(
            height: 180,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            enlargeCenterPage: true,
            viewportFraction: 0.9,
            onPageChanged: (index, reason) {
              setState(() {
                _bannerIndex = index;
              });
            },
          ),
          itemBuilder: (context, index, realIndex) {
            final banner = _banners[index];
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: banner.colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: banner.colors.first.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Background Pattern
                  Positioned(
                    right: -20,
                    bottom: -20,
                    child: Icon(
                      banner.icon,
                      size: 150,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          banner.icon,
                          color: Colors.white,
                          size: 40,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          banner.title,
                          style: AppTextStyles.titleLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          banner.subtitle,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        AnimatedSmoothIndicator(
          activeIndex: _bannerIndex,
          count: _banners.length,
          effect: WormEffect(
            dotHeight: 8,
            dotWidth: 8,
            activeDotColor: AppColors.primaryMain,
            dotColor: AppColors.textSecondary.withValues(alpha: 0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      _QuickAction(
        icon: Icons.receipt_long,
        label: 'Recipes',
        color: AppColors.categoryFruits,
        onTap: () {},
      ),
      _QuickAction(
        icon: Icons.history,
        label: 'History',
        color: AppColors.info,
        onTap: () {},
      ),
      _QuickAction(
        icon: Icons.trending_up,
        label: 'Budget',
        color: AppColors.success,
        onTap: () {},
      ),
      _QuickAction(
        icon: Icons.share,
        label: 'Share',
        color: AppColors.accentMain,
        onTap: () {},
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: actions.map((action) {
          return InkWell(
            onTap: action.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: action.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    action.icon,
                    color: action.color,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  action.label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: actions.indexOf(action) * 100))
            .slideY(begin: 0.3, end: 0);
        }).toList(),
      ),
    );
  }

  Widget _buildSmartSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Smart Picks',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Personalized for you',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              return SmartSuggestionCard(
                index: index,
              ).animate().fadeIn(delay: Duration(milliseconds: index * 100))
                .slideX(begin: 0.2, end: 0);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecipeSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.categoryFruits.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  color: AppColors.categoryFruits,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recipe Ideas',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Cook with your pantry items',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 240,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            itemBuilder: (context, index) {
              return RecipeSuggestionCard(
                index: index,
              ).animate().fadeIn(delay: Duration(milliseconds: index * 100))
                .slideX(begin: 0.2, end: 0);
            },
          ),
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    if (hour < 21) return 'Good Evening';
    return 'Good Night';
  }
}

class _BannerData {
  final String title;
  final String subtitle;
  final List<Color> colors;
  final IconData icon;

  _BannerData({
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.icon,
  });
}

class _CategoryData {
  final String name;
  final IconData icon;
  final Color color;
  final int itemCount;

  _CategoryData(this.name, this.icon, this.color, this.itemCount);
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
