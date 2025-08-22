import 'package:flutter/material.dart';
import 'hive_manager.dart';

/// Service for managing app preferences and settings
class PreferencesService {
  static const String _themeModeKey = 'theme_mode';
  static const String _languageKey = 'language';
  static const String _firstLaunchKey = 'first_launch';
  
  final HiveManager _hiveManager = HiveManager.instance;
  
  /// Get theme mode from preferences
  ThemeMode getThemeMode() {
    try {
      final themeModeIndex = _hiveManager.preferencesBox.get(_themeModeKey);
      if (themeModeIndex != null) {
        final index = int.tryParse(themeModeIndex);
        if (index != null && index >= 0 && index < ThemeMode.values.length) {
          return ThemeMode.values[index];
        }
      }
    } catch (e) {
      print('Error getting theme mode: $e');
    }
    return ThemeMode.system; // Default theme mode
  }
  
  /// Save theme mode to preferences
  Future<void> setThemeMode(ThemeMode themeMode) async {
    try {
      await _hiveManager.preferencesBox.put(_themeModeKey, themeMode.index.toString());
    } catch (e) {
      print('Error saving theme mode: $e');
    }
  }
  
  /// Get app language from preferences
  String? getLanguage() {
    try {
      return _hiveManager.preferencesBox.get(_languageKey);
    } catch (e) {
      print('Error getting language: $e');
      return null;
    }
  }
  
  /// Save app language to preferences
  Future<void> setLanguage(String languageCode) async {
    try {
      await _hiveManager.preferencesBox.put(_languageKey, languageCode);
    } catch (e) {
      print('Error saving language: $e');
    }
  }
  
  /// Check if this is the first app launch
  bool isFirstLaunch() {
    try {
      final firstLaunch = _hiveManager.preferencesBox.get(_firstLaunchKey);
      return firstLaunch == null || firstLaunch == 'true';
    } catch (e) {
      print('Error checking first launch: $e');
      return true;
    }
  }
  
  /// Mark that the app has been launched
  Future<void> setFirstLaunchComplete() async {
    try {
      await _hiveManager.preferencesBox.put(_firstLaunchKey, 'false');
    } catch (e) {
      print('Error setting first launch complete: $e');
    }
  }
  
  /// Get a custom preference value
  String? getCustomPreference(String key) {
    try {
      return _hiveManager.preferencesBox.get(key);
    } catch (e) {
      print('Error getting custom preference $key: $e');
      return null;
    }
  }
  
  /// Set a custom preference value
  Future<void> setCustomPreference(String key, String value) async {
    try {
      await _hiveManager.preferencesBox.put(key, value);
    } catch (e) {
      print('Error setting custom preference $key: $e');
    }
  }
  
  /// Remove a preference
  Future<void> removePreference(String key) async {
    try {
      await _hiveManager.preferencesBox.delete(key);
    } catch (e) {
      print('Error removing preference $key: $e');
    }
  }
  
  /// Clear all preferences
  Future<void> clearAllPreferences() async {
    try {
      await _hiveManager.preferencesBox.clear();
    } catch (e) {
      print('Error clearing all preferences: $e');
    }
  }
  
  /// Get all preference keys
  List<String> getAllPreferenceKeys() {
    try {
      return _hiveManager.preferencesBox.keys.cast<String>().toList();
    } catch (e) {
      print('Error getting all preference keys: $e');
      return [];
    }
  }
}