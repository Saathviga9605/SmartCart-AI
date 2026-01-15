import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/datasources/hive_service.dart';
import '../../core/constants/app_constants.dart';

/// Provider for theme management
/// Handles dark/light mode switching and persistence
class ThemeProvider with ChangeNotifier {
  final HiveService _hiveService;
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeProvider(this._hiveService) {
    _loadThemeMode();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Load theme mode from storage
  Future<void> _loadThemeMode() async {
    try {
      final savedMode = _hiveService.getSetting<String>(
        AppConstants.keyThemeMode,
        defaultValue: 'dark',
      );

      _themeMode = savedMode == 'light' ? ThemeMode.light : ThemeMode.dark;
      _updateSystemUI();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme mode: $e');
    }
  }

  /// Toggle between dark and light mode
  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    
    await _hiveService.saveSetting(
      AppConstants.keyThemeMode,
      _themeMode == ThemeMode.dark ? 'dark' : 'light',
    );

    _updateSystemUI();
    
    // Haptic feedback
    HapticFeedback.lightImpact();
    
    notifyListeners();
  }

  /// Set specific theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    
    await _hiveService.saveSetting(
      AppConstants.keyThemeMode,
      mode == ThemeMode.dark ? 'dark' : 'light',
    );

    _updateSystemUI();
    notifyListeners();
  }

  /// Update system UI overlay style based on theme
  void _updateSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            _themeMode == ThemeMode.dark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor:
            _themeMode == ThemeMode.dark ? Colors.black : Colors.white,
        systemNavigationBarIconBrightness:
            _themeMode == ThemeMode.dark ? Brightness.light : Brightness.dark,
      ),
    );
  }
}
