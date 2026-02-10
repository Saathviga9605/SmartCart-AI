import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'discover_screen.dart';
import 'my_list_screen.dart';
import 'deals_screen.dart';
import 'profile_screen.dart';
import '../widgets/floating_mic_button.dart';
import 'voice_input_overlay.dart';

/// Main navigation screen with modern bottom nav bar
/// Inspired by modern delivery apps but with unique innovations
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const DiscoverScreen(),
    const MyListScreen(),
    const DealsScreen(),
    const ProfileScreen(),
  ];

  final List<_NavItem> _navItems = [
    _NavItem(
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore,
      label: 'Discover',
    ),
    _NavItem(
      icon: Icons.shopping_cart_outlined,
      activeIcon: Icons.shopping_cart,
      label: 'My List',
    ),
    _NavItem(
      icon: Icons.local_offer_outlined,
      activeIcon: Icons.local_offer,
      label: 'Deals',
    ),
    _NavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
    ),
  ];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingMicButton(
        onPressed: _openVoiceInput,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.backgroundCard.withValues(alpha: 0.95),
                AppColors.backgroundDark.withValues(alpha: 0.98),
              ],
            ),
          ),
          child: SizedBox(
            height: 70, // Explicit height for the bar content
            child: BottomAppBar(
              color: Colors.transparent,
              elevation: 0,
              notchMargin: 8,
              shape: const CircularNotchedRectangle(),
              padding: EdgeInsets.zero, // Remove default padding
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ..._navItems.take(2).map((item) {
                    final index = _navItems.indexOf(item);
                    return _buildNavItem(item, index);
                  }),
                  const SizedBox(width: 48), // Space for FAB
                  ..._navItems.skip(2).map((item) {
                    final index = _navItems.indexOf(item);
                    return _buildNavItem(item, index);
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(_NavItem item, int index) {
    final isActive = _currentIndex == index;
    
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? item.activeIcon : item.icon,
              color: isActive ? AppColors.primaryMain : AppColors.textSecondary,
              size: 22, // Smaller icon
            ),
            if (isActive) ...[
              const SizedBox(height: 2),
              Flexible(
                child: Text(
                  item.label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primaryMain,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
