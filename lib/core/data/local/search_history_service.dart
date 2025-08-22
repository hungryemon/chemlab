import 'hive_manager.dart';

/// Service for managing search history operations
class SearchHistoryService {
  static const int _maxHistorySize = 20;
  
  final HiveManager _hiveManager = HiveManager.instance;
  
  /// Add a search term to history
  Future<void> addSearchTerm(String searchTerm) async {
    if (searchTerm.trim().isEmpty) return;
    
    try {
      final trimmedTerm = searchTerm.trim().toLowerCase();
      
      // Remove if already exists to avoid duplicates
      await removeSearchTerm(trimmedTerm);
      
      // Add to the beginning of the list
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      await _hiveManager.searchHistoryBox.put(timestamp, trimmedTerm);
      
      // Manage history size
      await _manageHistorySize();
    } catch (e) {
      print('Error adding search term: $e');
    }
  }
  
  /// Get all search history terms (most recent first)
  List<String> getSearchHistory() {
    try {
      final entries = _hiveManager.searchHistoryBox.toMap().entries.toList();
      
      // Sort by timestamp (key) in descending order
      entries.sort((a, b) => b.key.compareTo(a.key));
      
      return entries.map((entry) => entry.value).toList();
    } catch (e) {
      print('Error getting search history: $e');
      return [];
    }
  }
  
  /// Remove a specific search term from history
  Future<void> removeSearchTerm(String searchTerm) async {
    try {
      final trimmedTerm = searchTerm.trim().toLowerCase();
      final entries = _hiveManager.searchHistoryBox.toMap().entries.toList();
      
      for (final entry in entries) {
        if (entry.value == trimmedTerm) {
          await _hiveManager.searchHistoryBox.delete(entry.key);
        }
      }
    } catch (e) {
      print('Error removing search term: $e');
    }
  }
  
  /// Clear all search history
  Future<void> clearSearchHistory() async {
    try {
      await _hiveManager.searchHistoryBox.clear();
    } catch (e) {
      print('Error clearing search history: $e');
    }
  }
  
  /// Get search suggestions based on input
  List<String> getSearchSuggestions(String input) {
    if (input.trim().isEmpty) return getSearchHistory();
    
    try {
      final history = getSearchHistory();
      final lowerInput = input.toLowerCase();
      
      return history
          .where((term) => term.toLowerCase().contains(lowerInput))
          .take(10)
          .toList();
    } catch (e) {
      print('Error getting search suggestions: $e');
      return [];
    }
  }
  
  /// Check if a search term exists in history
  bool hasSearchTerm(String searchTerm) {
    try {
      final trimmedTerm = searchTerm.trim().toLowerCase();
      return getSearchHistory().contains(trimmedTerm);
    } catch (e) {
      print('Error checking search term: $e');
      return false;
    }
  }
  
  /// Get search history size
  int get historySize {
    try {
      return _hiveManager.searchHistoryBox.length;
    } catch (e) {
      print('Error getting history size: $e');
      return 0;
    }
  }
  
  /// Manage history size by removing oldest entries
  Future<void> _manageHistorySize() async {
    try {
      if (_hiveManager.searchHistoryBox.length > _maxHistorySize) {
        final entries = _hiveManager.searchHistoryBox.toMap().entries.toList();
        
        // Sort by timestamp (key) in ascending order to get oldest first
        entries.sort((a, b) => a.key.compareTo(b.key));
        
        // Remove oldest entries
        final entriesToRemove = entries.take(entries.length - _maxHistorySize);
        
        for (final entry in entriesToRemove) {
          await _hiveManager.searchHistoryBox.delete(entry.key);
        }
      }
    } catch (e) {
      print('Error managing history size: $e');
    }
  }
}