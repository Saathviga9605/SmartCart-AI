import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Category Detail Screen - Shows items in a specific category
class CategoryDetailScreen extends StatelessWidget {
  final dynamic category;

  const CategoryDetailScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with category header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: category.color,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                category.name,
                style: AppTextStyles.titleLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      category.color,
                      category.color.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -50,
                      bottom: -50,
                      child: Icon(
                        category.icon,
                        size: 200,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    Positioned(
                      bottom: 60,
                      left: 20,
                      child: Text(
                        '${category.itemCount} items available',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Items Grid
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childCount: category.itemCount,
              itemBuilder: (context, index) {
                return _buildItemCard(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(int index) {
    final items = _getItemsForCategory(category.name);
    final item = items[index % items.length];
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: category.color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: index.isEven ? 120 : 100,
            decoration: BoxDecoration(
              color: category.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                category.icon,
                size: 48,
                color: category.color,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            item.$1,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.$2,
                style: AppTextStyles.titleSmall.copyWith(
                  color: category.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: category.color,
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
    ).animate().fadeIn(delay: Duration(milliseconds: index * 50))
      .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
  }

  List<(String, String)> _getItemsForCategory(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'fruits':
        return [
          ('Fresh Apples', '₹120/kg'),
          ('Organic Bananas', '₹60/dozen'),
          ('Sweet Oranges', '₹80/kg'),
          ('Red Grapes', '₹150/kg'),
          ('Fresh Strawberries', '₹250/pack'),
          ('Blueberries', '₹350/pack'),
          ('Watermelon', '₹40/kg'),
          ('Mango (Seasonal)', '₹180/kg'),
          ('Papaya', '₹35/kg'),
          ('Pineapple', '₹50/piece'),
          ('Pomegranate', '₹140/kg'),
          ('Dragon Fruit', '₹200/kg'),
        ];
      case 'vegetables':
        return [
          ('Fresh Tomatoes', '₹30/kg'),
          ('Green Capsicum', '₹60/kg'),
          ('Onions', '₹40/kg'),
          ('Potatoes', '₹25/kg'),
          ('Fresh Carrots', '₹45/kg'),
          ('Green Beans', '₹70/kg'),
          ('Broccoli', '₹80/kg'),
          ('Cauliflower', '₹35/piece'),
          ('Spinach', '₹25/bunch'),
          ('Cabbage', '₹30/piece'),
          ('Cucumber', '₹35/kg'),
          ('Lady Finger', '₹50/kg'),
        ];
      case 'dairy':
        return [
          ('Milk (1L)', '₹58/ltr'),
          ('Paneer', '₹280/kg'),
          ('Curd/Yogurt', '₹60/500g'),
          ('Butter', '₹450/500g'),
          ('Cheese Slices', '₹180/200g'),
          ('Ghee', '₹550/500ml'),
          ('Cream', '₹120/200ml'),
          ('Buttermilk', '₹35/500ml'),
          ('Mozzarella', '₹320/200g'),
          ('Cottage Cheese', '₹290/kg'),
        ];
      case 'meat':
        return [
          ('Chicken Breast', '₹220/kg'),
          ('Chicken Curry Cut', '₹180/kg'),
          ('Mutton', '₹650/kg'),
          ('Fish (Rohu)', '₹350/kg'),
          ('Prawns', '₹550/kg'),
          ('Chicken Wings', '₹200/kg'),
          ('Minced Meat', '₹240/kg'),
          ('Chicken Legs', '₹180/kg'),
          ('Fish Fillet', '₹380/kg'),
          ('Eggs (12pc)', '₹84/dozen'),
        ];
      case 'bakery':
        return [
          ('White Bread', '₹35/loaf'),
          ('Brown Bread', '₹45/loaf'),
          ('Buns (6pc)', '₹30/pack'),
          ('Croissants', '₹120/pack'),
          ('Cookies', '₹80/pack'),
          ('Muffins', '₹150/pack'),
          ('Cake (500g)', '₹350/piece'),
          ('Pastries', '₹50/piece'),
          ('Pizza Base', '₹40/piece'),
          ('Garlic Bread', '₹120/pack'),
        ];
      case 'beverages':
        return [
          ('Coffee Powder', '₹320/200g'),
          ('Tea Leaves', '₹180/250g'),
          ('Fruit Juice', '₹120/1L'),
          ('Cola', '₹80/1.5L'),
          ('Mineral Water', '₹20/1L'),
          ('Energy Drink', '₹100/250ml'),
          ('Green Tea', '₹250/100g'),
          ('Coconut Water', '₹35/300ml'),
          ('Milk Shake Mix', '₹150/pack'),
          ('Smoothie Mix', '₹200/pack'),
        ];
      case 'snacks':
        return [
          ('Potato Chips', '₹60/100g'),
          ('Namkeen Mix', '₹80/200g'),
          ('Biscuits', '₹35/pack'),
          ('Popcorn', '₹120/pack'),
          ('Nachos', '₹150/pack'),
          ('Peanuts', '₹140/500g'),
          ('Cashews', '₹680/500g'),
          ('Almonds', '₹750/500g'),
          ('Trail Mix', '₹320/pack'),
          ('Protein Bars', '₹450/pack'),
        ];
      default: // other
        return [
          ('Rice (5kg)', '₹350/pack'),
          ('Wheat Flour', '₹280/5kg'),
          ('Cooking Oil', '₹180/1L'),
          ('Sugar', '₹45/kg'),
          ('Salt', '₹22/kg'),
          ('Pasta', '₹120/500g'),
          ('Noodles', '₹80/pack'),
          ('Spices Mix', '₹150/pack'),
          ('Pickles', '₹180/500g'),
          ('Jam', '₹150/450g'),
        ];
    }
  }
}
