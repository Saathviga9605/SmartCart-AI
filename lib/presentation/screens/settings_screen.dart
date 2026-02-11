import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../providers/theme_provider.dart';
import '../providers/grocery_provider.dart';
import '../../data/datasources/hive_service.dart';

/// Settings Screen - App configuration and preferences
/// Theme switching, ML toggles, and app information
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: AppTextStyles.titleLarge,
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        children: [
          // Appearance Section
          _buildSectionHeader('Appearance'),
          _buildSettingsCard(
            children: [
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return SwitchListTile(
                    title: Text(
                      'Dark Mode',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'Use dark theme',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    value: themeProvider.isDarkMode,
                    onChanged: (_) => themeProvider.toggleTheme(),
                    secondary: Icon(
                      themeProvider.isDarkMode
                          ? Icons.dark_mode
                          : Icons.light_mode,
                      color: AppColors.primaryMain,
                    ),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Notifications Section
          _buildSectionHeader('Notifications & Reminders'),
          _buildSettingsCard(
            children: [
              Consumer<HiveService>(
                builder: (context, hive, child) {
                  final reminderEnabled = hive.getSetting<bool>('reminder_enabled', defaultValue: true) ?? true;
                  return SwitchListTile(
                    title: Text(
                      'Shopping Reminders',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'Get reminded about pending items',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    value: reminderEnabled,
                    onChanged: (value) {
                      hive.saveSetting('reminder_enabled', value);
                    },
                    secondary: const Icon(
                      Icons.notifications_active,
                      color: AppColors.info,
                    ),
                  );
                },
              ),
              const Divider(),
              Consumer<HiveService>(
                builder: (context, hive, child) {
                  return ListTile(
                    leading: const Icon(
                      Icons.history,
                      color: AppColors.warning,
                    ),
                    title: Text(
                      'Clear History',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      '${hive.getHistory().length} shopping trips',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    onTap: () => _showClearHistoryConfirmation(context, hive),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Privacy & Storage
          _buildSectionHeader('Privacy & Storage'),
          _buildSettingsCard(
            children: [
              Consumer<HiveService>(
                builder: (context, hive, child) {
                  final analytics = hive.getSetting<bool>('analytics_enabled', defaultValue: true) ?? true;
                  return SwitchListTile(
                    title: Text(
                      'Usage Analytics',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'Help improve the app',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    value: analytics,
                    onChanged: (value) {
                      hive.saveSetting('analytics_enabled', value);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(value 
                            ? 'Analytics enabled' 
                            : 'Analytics disabled'),
                        ),
                      );
                    },
                    secondary: const Icon(
                      Icons.analytics,
                      color: AppColors.info,
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(
                  Icons.privacy_tip_outlined,
                  color: AppColors.accentMain,
                ),
                title: Text(
                  'Privacy Policy',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                trailing: const Icon(Icons.open_in_new, size: 20),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Privacy policy coming soon')),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(
                  Icons.alarm,
                  color: AppColors.warning,
                ),
                title: Text(
                  'Reminder Time',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  'Set your preferred reminder time',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showReminderTimePicker(context),
              ),
              const Divider(),
              Consumer<HiveService>(
                builder: (context, hive, child) {
                  final priceAlerts = hive.getSetting<bool>('price_alerts', defaultValue: false) ?? false;
                  return SwitchListTile(
                    title: Text(
                      'Price Alerts',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'Notify about price drops',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    value: priceAlerts,
                    onChanged: (value) {
                      hive.saveSetting('price_alerts', value);
                    },
                    secondary: const Icon(
                      Icons.trending_down,
                      color: AppColors.success,
                    ),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Data Section
          _buildSectionHeader('Data'),
          _buildSettingsCard(
            children: [
              Consumer<GroceryProvider>(
                builder: (context, provider, child) {
                  return ListTile(
                    leading: const Icon(
                      Icons.delete_sweep,
                      color: AppColors.error,
                    ),
                    title: Text(
                      'Clear All Items',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      '${provider.totalItems} items in total',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    onTap: () => _showClearConfirmation(context, provider),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // About Section
          _buildSectionHeader('About'),
          _buildSettingsCard(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.shopping_cart,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                title: Text(
                  AppConstants.appName,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  'Version ${AppConstants.appVersion}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              
              const Divider(),
              
              ListTile(
                leading: const Icon(
                  Icons.psychology,
                  color: AppColors.accentMain,
                ),
                title: Text(
                  'ML Model',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  'On-device category classification',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Active',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ),
              ),
              
              const Divider(),
              
              ListTile(
                leading: const Icon(
                  Icons.info_outline,
                  color: AppColors.info,
                ),
                title: Text(
                  'About SmartCart AI',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  AppConstants.appTagline,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Footer
          Center(
            child: Text(
              'Made with ❤️ for smart shopping',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 12),
      child: Text(
        title,
        style: AppTextStyles.titleSmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.glassBorder,
          width: 1,
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  void _showClearConfirmation(
    BuildContext context,
    GroceryProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Clear All Items?',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'This will permanently delete all ${provider.totalItems} items from your list.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.clearAllItems();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showReminderTimePicker(BuildContext context) {
    final hive = context.read<HiveService>();
    final currentHour = hive.getSetting<int>('reminder_hour', defaultValue: 18) ?? 18;
    final currentMinute = hive.getSetting<int>('reminder_minute', defaultValue: 0) ?? 0;
    
    showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: currentHour, minute: currentMinute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryMain,
              onPrimary: Colors.white,
              surface: AppColors.surfaceDark,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    ).then((time) {
      if (time != null) {
        hive.saveSetting('reminder_hour', time.hour);
        hive.saveSetting('reminder_minute', time.minute);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reminder set for ${time.format(context)}'),
          ),
        );
      }
    });
  }

  void _showClearHistoryConfirmation(BuildContext context, HiveService hive) {
    final historyCount = hive.getHistory().length;
    if (historyCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No history to clear')),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Clear Shopping History?',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'This will permanently delete all $historyCount shopping trips from your history.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await hive.clearHistory();
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('History cleared')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
