import 'package:flutter/material.dart';
import '../data/local/local_data.dart';

/// Provider for managing app theme state (light/dark mode)
class ThemeProvider extends ChangeNotifier {
  final PreferencesService _preferencesService = PreferencesService();
  ThemeMode _themeMode = ThemeMode.system;
  
  /// Current theme mode
  ThemeMode get themeMode => _themeMode;
  
  /// Check if dark mode is active
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  /// Check if light mode is active
  bool get isLightMode => _themeMode == ThemeMode.light;
  
  /// Check if system mode is active
  bool get isSystemMode => _themeMode == ThemeMode.system;
  
  /// Initialize theme provider
  Future<void> initialize() async {
    try {
      await _loadThemeMode();
    } catch (e) {
      print('Error initializing theme provider: $e');
      // Use default theme mode if initialization fails
      _themeMode = ThemeMode.system;
    }
  }
  
  /// Load theme mode from storage
  Future<void> _loadThemeMode() async {
    try {
      _themeMode = _preferencesService.getThemeMode();
    } catch (e) {
      print('Error loading theme mode: $e');
      _themeMode = ThemeMode.system;
    }
  }
  
  /// Set theme mode
  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (_themeMode == themeMode) return;
    
    _themeMode = themeMode;
    notifyListeners();
    
    try {
      await _preferencesService.setThemeMode(themeMode);
    } catch (e) {
      print('Error saving theme mode: $e');
    }
  }
  
  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    final newThemeMode = _themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    await setThemeMode(newThemeMode);
  }
  
  /// Set light theme
  Future<void> setLightTheme() async {
    await setThemeMode(ThemeMode.light);
  }
  
  /// Set dark theme
  Future<void> setDarkTheme() async {
    await setThemeMode(ThemeMode.dark);
  }
  
  /// Set system theme
  Future<void> setSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }
  
  /// Get theme mode display name
  String getThemeModeDisplayName(BuildContext context) {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }
  
  /// Get current brightness based on theme mode and system brightness
  Brightness getCurrentBrightness(BuildContext context) {
    switch (_themeMode) {
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.system:
        return MediaQuery.of(context).platformBrightness;
    }
  }
  
  @override
  void dispose() {
    // Preferences service is managed by HiveManager
    super.dispose();
  }
}