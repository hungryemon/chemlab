import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../api/pubchem_api.dart';
import '../models/compound.dart';
import '../utils/constants.dart';

/// Provider for managing compound data and API interactions
class CompoundProvider extends ChangeNotifier {
  static const int _maxCacheSize = 50;
  static const int _maxSearchHistory = 20;
  
  final PubChemApi _api = PubChemApi();
  late Box<Map> _compoundBox;
  late Box<String> _searchHistoryBox;
  
  // State variables
  bool _isLoading = false;
  String? _error;
  String? _detailsError;
  List<Compound> _searchResults = [];
  List<Compound> _featuredCompounds = [];
  List<String> _searchHistory = [];
  Compound? _selectedCompound;
  Compound? _currentCompound;
  bool _isSearching = false;
  String? _searchError;
  bool _isLoadingDetails = false;
  
  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get detailsError => _detailsError;
  List<Compound> get searchResults => _searchResults;
  List<Compound> get featuredCompounds => _featuredCompounds;
  List<String> get searchHistory => _searchHistory;
  Compound? get selectedCompound => _selectedCompound;
  Compound? get currentCompound => _currentCompound;
  bool get isSearching => _isSearching;
  String? get searchError => _searchError;
  bool get isLoadingDetails => _isLoadingDetails;

  // Featured compounds state
  bool _isLoadingFeatured = false;
  String? _featuredError;
  bool get isLoadingFeatured => _isLoadingFeatured;
  String? get featuredError => _featuredError;





  /// Initialize provider
  Future<void> initialize() async {
    try {
      _compoundBox = Hive.box('cache');
      _searchHistoryBox = Hive.box('search_history');
      await _loadSearchHistory();
      await _loadFeaturedCompounds();
    } catch (e) {
      _setError('Failed to initialize compound provider: $e');
    }
  }
  
  /// Load search history from storage
  Future<void> _loadSearchHistory() async {
    try {
      _searchHistory = _searchHistoryBox.values.toList();
      notifyListeners();
    } catch (e) {
      print('Error loading search history: $e');
    }
  }
  
  /// Load featured compounds for home screen
  Future<void> _loadFeaturedCompounds() async {
    _setLoading(true);
    
    try {
      // Featured compound CIDs (common compounds)
      const featuredCids = [962, 5793, 6324, 887, 5460341]; // Water, Glucose, Caffeine, Methanol, Aspirin
      
      // Try to load from cache first
      final cachedCompounds = <Compound>[];
      final missingCids = <int>[];
      
      for (final cid in featuredCids) {
        final cached = _getFromCache(cid);
        if (cached != null) {
          cachedCompounds.add(cached);
        } else {
          missingCids.add(cid);
        }
      }
      
      // Fetch missing compounds from API
      if (missingCids.isNotEmpty) {
        final fetchedCompounds = await _api.getMultipleCompounds(missingCids);
        
        // Cache fetched compounds
        for (final compound in fetchedCompounds) {
          await _saveToCache(compound);
        }
        
        cachedCompounds.addAll(fetchedCompounds);
      }
      
      // Sort by original order
      _featuredCompounds = featuredCids
          .map((cid) => cachedCompounds.firstWhere(
                (compound) => compound.cid == cid,
                orElse: () => Compound(
                  cid: cid,
                  title: 'Unknown Compound',
                  fetchedAt: DateTime.now(),
                ),
              ))
          .toList();
      
      _clearError();
    } catch (e) {
      _setError('Failed to load featured compounds: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Search compounds by name
  Future<void> searchCompounds(String searchTerm) async {
    if (searchTerm.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }
    
    _setLoading(true);
    
    try {
      // Add to search history
      await _addToSearchHistory(searchTerm.trim());
      
      // Search for compound CIDs
      final cids = await _api.searchCompounds(searchTerm);
      
      if (cids.isEmpty) {
        _searchResults = [];
        _clearError();
      } else {
        // Limit results to first 10 compounds
        final limitedCids = cids.take(10).toList();
        
        // Try to get from cache first
        final compounds = <Compound>[];
        final missingCids = <int>[];
        
        for (final cid in limitedCids) {
          final cached = _getFromCache(cid);
          if (cached != null) {
            compounds.add(cached);
          } else {
            missingCids.add(cid);
          }
        }
        
        // Fetch missing compounds
        if (missingCids.isNotEmpty) {
          final fetchedCompounds = await _api.getMultipleCompounds(missingCids);
          
          // Cache fetched compounds
          for (final compound in fetchedCompounds) {
            await _saveToCache(compound);
          }
          
          compounds.addAll(fetchedCompounds);
        }
        
        // Sort by original CID order
        _searchResults = limitedCids
            .map((cid) => compounds.firstWhere(
                  (compound) => compound.cid == cid,
                  orElse: () => Compound(
                    cid: cid,
                    title: 'Unknown Compound',
                    fetchedAt: DateTime.now(),
                  ),
                ))
            .toList();
        
        _clearError();
      }
    } catch (e) {
      _setError('Search failed: $e');
      _searchResults = [];
    } finally {
      _setLoading(false);
    }
  }
  
  /// Get compound details by CID
  Future<Compound?> getCompoundDetails(int cid) async {
    _setLoading(true);
    
    try {
      // Try cache first
      Compound? compound = _getFromCache(cid);
      
      if (compound == null) {
        // Fetch from API
        compound = await _api.getCompoundDetails(cid);
        if (compound != null) {
          await _saveToCache(compound);
        }
      }
      
      _selectedCompound = compound;
      _clearError();
      return compound;
    } catch (e) {
      _setError('Failed to load compound details: $e');
      _selectedCompound = null;
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Add search term to history
  Future<void> _addToSearchHistory(String searchTerm) async {
    try {
      // Remove if already exists
      _searchHistory.remove(searchTerm);
      
      // Add to beginning
      _searchHistory.insert(0, searchTerm);
      
      // Limit history size
      if (_searchHistory.length > _maxSearchHistory) {
        _searchHistory = _searchHistory.take(_maxSearchHistory).toList();
      }
      
      // Save to storage
      await _searchHistoryBox.clear();
      for (int i = 0; i < _searchHistory.length; i++) {
        await _searchHistoryBox.put(i, _searchHistory[i]);
      }
      
      notifyListeners();
    } catch (e) {
      print('Error adding to search history: $e');
    }
  }
  
  /// Clear search history
  Future<void> clearSearchHistory() async {
    try {
      await _searchHistoryBox.clear();
      _searchHistory.clear();
      notifyListeners();
    } catch (e) {
      print('Error clearing search history: $e');
    }
  }

  /// Load featured compounds
  Future<void> loadFeaturedCompounds() async {
    _isLoadingFeatured = true;
    _featuredError = null;
    notifyListeners();

    try {
      _featuredCompounds.clear();
      
      for (final cid in AppConstants.featuredCompoundCids) {
        try {
          final compound = await getCompoundDetails(cid);
          if (compound != null) {
            _featuredCompounds.add(compound);
          }
        } catch (e) {
          print('Error loading featured compound $cid: $e');
        }
      }
      
      _isLoadingFeatured = false;
      notifyListeners();
    } catch (e) {
      _isLoadingFeatured = false;
      _featuredError = 'Failed to load featured compounds';
      notifyListeners();
      print('Error loading featured compounds: $e');
    }
  }

  /// Load search history from storage
  Future<void> loadSearchHistory() async {
    try {
      final keys = _searchHistoryBox.keys.toList();
      _searchHistory = keys.cast<String>().toList();
      notifyListeners();
    } catch (e) {
      print('Error loading search history: $e');
    }
  }

  /// Add to search history
  Future<void> addToSearchHistory(String query) async {
    try {
      if (query.isNotEmpty && !_searchHistory.contains(query)) {
        _searchHistory.insert(0, query);
        // Keep only last 10 searches
        if (_searchHistory.length > 10) {
          _searchHistory = _searchHistory.take(10).toList();
        }
        await _searchHistoryBox.put(query, query);
        notifyListeners();
      }
    } catch (e) {
      print('Error adding to search history: $e');
    }
  }

  /// Remove from search history
  void removeFromSearchHistory(String query) {
    _searchHistory.remove(query);
    notifyListeners();
  }
  
  /// Get compound from cache
  Compound? _getFromCache(int cid) {
    try {
      final data = _compoundBox.get(cid.toString());
      if (data != null) {
        return Compound.fromJson(Map<String, dynamic>.from(data));
      }
    } catch (e) {
      print('Error getting from cache: $e');
    }
    return null;
  }
  
  /// Save compound to cache
  Future<void> _saveToCache(Compound compound) async {
    try {
      await _compoundBox.put(compound.cid.toString(), compound.toJson());
      
      // Manage cache size
      if (_compoundBox.length > _maxCacheSize) {
        final keys = _compoundBox.keys.toList();
        final oldestKey = keys.first;
        await _compoundBox.delete(oldestKey);
      }
    } catch (e) {
      print('Error saving to cache: $e');
    }
  }
  
  /// Clear search results
  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }
  
  /// Clear selected compound
  void clearSelectedCompound() {
    _selectedCompound = null;
    notifyListeners();
  }
  
  /// Refresh featured compounds
  Future<void> refreshFeaturedCompounds() async {
    await _loadFeaturedCompounds();
  }
  
  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  /// Set error message
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
  
  /// Clear error
  void _clearError() {
    _error = null;
    notifyListeners();
  }
  
  @override
  void dispose() {
    _compoundBox.close();
    _searchHistoryBox.close();
    super.dispose();
  }
}