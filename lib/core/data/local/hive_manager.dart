import 'package:hive_flutter/hive_flutter.dart';
import '../../utils/constants.dart';

/// Manager class for handling all Hive database operations
class HiveManager {
  static HiveManager? _instance;
  static HiveManager get instance => _instance ??= HiveManager._();
  
  HiveManager._();
  
  // Box references
  Box<Map>? _cacheBox;
  Box<String>? _preferencesBox;
  Box<String>? _searchHistoryBox;
  
  /// Get cache box for compound data
  Box<Map> get cacheBox {
    if (_cacheBox == null || !_cacheBox!.isOpen) {
      throw StateError('Cache box is not initialized. Call initialize() first.');
    }
    return _cacheBox!;
  }
  
  /// Get preferences box for app settings
  Box<String> get preferencesBox {
    if (_preferencesBox == null || !_preferencesBox!.isOpen) {
      throw StateError('Preferences box is not initialized. Call initialize() first.');
    }
    return _preferencesBox!;
  }
  
  /// Get search history box
  Box<String> get searchHistoryBox {
    if (_searchHistoryBox == null || !_searchHistoryBox!.isOpen) {
      throw StateError('Search history box is not initialized. Call initialize() first.');
    }
    return _searchHistoryBox!;
  }
  
  /// Initialize Hive and open all required boxes
  static Future<void> initialize() async {
    // Initialize Hive Flutter
    await Hive.initFlutter();
    
    // Open all required boxes
    final instance = HiveManager.instance;
    
    instance._cacheBox = await Hive.openBox<Map>(AppConstants.cacheBoxName);
    instance._preferencesBox = await Hive.openBox<String>(AppConstants.preferencesBoxName);
    instance._searchHistoryBox = await Hive.openBox<String>(AppConstants.searchHistoryBoxName);
  }
  
  /// Close all boxes and dispose resources
  Future<void> dispose() async {
    await _cacheBox?.close();
    await _preferencesBox?.close();
    await _searchHistoryBox?.close();
    
    _cacheBox = null;
    _preferencesBox = null;
    _searchHistoryBox = null;
  }
  
  /// Check if all boxes are initialized
  bool get isInitialized {
    return _cacheBox?.isOpen == true &&
           _preferencesBox?.isOpen == true &&
           _searchHistoryBox?.isOpen == true;
  }
}