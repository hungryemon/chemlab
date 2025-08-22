import 'package:hive_flutter/hive_flutter.dart';
import '../../models/compound.dart';
import 'hive_manager.dart';

/// Service for managing compound cache operations
class CacheService {
  static const int _maxCacheSize = 50;
  
  final HiveManager _hiveManager = HiveManager.instance;
  
  /// Get compound from cache by CID
  Compound? getCompound(int cid) {
    try {
      final data = _hiveManager.cacheBox.get(cid.toString());
      if (data != null) {
        return Compound.fromJson(Map<String, dynamic>.from(data));
      }
    } catch (e) {
      print('Error getting compound from cache: $e');
    }
    return null;
  }
  
  /// Save compound to cache
  Future<void> saveCompound(Compound compound) async {
    try {
      await _hiveManager.cacheBox.put(compound.cid.toString(), compound.toJson());
      
      // Manage cache size - remove oldest entries if cache is too large
      await _manageCacheSize();
    } catch (e) {
      print('Error saving compound to cache: $e');
    }
  }
  
  /// Save multiple compounds to cache
  Future<void> saveCompounds(List<Compound> compounds) async {
    try {
      final Map<String, Map<String, dynamic>> batch = {};
      
      for (final compound in compounds) {
        batch[compound.cid.toString()] = compound.toJson();
      }
      
      await _hiveManager.cacheBox.putAll(batch);
      await _manageCacheSize();
    } catch (e) {
      print('Error saving compounds to cache: $e');
    }
  }
  
  /// Check if compound exists in cache
  bool hasCompound(int cid) {
    try {
      return _hiveManager.cacheBox.containsKey(cid.toString());
    } catch (e) {
      print('Error checking compound in cache: $e');
      return false;
    }
  }
  
  /// Remove compound from cache
  Future<void> removeCompound(int cid) async {
    try {
      await _hiveManager.cacheBox.delete(cid.toString());
    } catch (e) {
      print('Error removing compound from cache: $e');
    }
  }
  
  /// Clear all cached compounds
  Future<void> clearCache() async {
    try {
      await _hiveManager.cacheBox.clear();
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }
  
  /// Get cache size
  int get cacheSize {
    try {
      return _hiveManager.cacheBox.length;
    } catch (e) {
      print('Error getting cache size: $e');
      return 0;
    }
  }
  
  /// Get all cached compound CIDs
  List<int> getCachedCids() {
    try {
      return _hiveManager.cacheBox.keys
          .map((key) => int.tryParse(key.toString()))
          .where((cid) => cid != null)
          .cast<int>()
          .toList();
    } catch (e) {
      print('Error getting cached CIDs: $e');
      return [];
    }
  }
  
  /// Manage cache size by removing oldest entries
  Future<void> _manageCacheSize() async {
    try {
      if (_hiveManager.cacheBox.length > _maxCacheSize) {
        final keys = _hiveManager.cacheBox.keys.toList();
        final keysToRemove = keys.take(keys.length - _maxCacheSize);
        
        for (final key in keysToRemove) {
          await _hiveManager.cacheBox.delete(key);
        }
      }
    } catch (e) {
      print('Error managing cache size: $e');
    }
  }
}