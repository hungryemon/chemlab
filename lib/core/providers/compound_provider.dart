import 'package:chemlab/core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import '../data/remote/pubchem_api.dart';
import '../data/local/local_data.dart';
import '../models/compound.dart';
import '../utils/constants.dart';

/// Provider for managing compound data and API interactions
class CompoundProvider extends ChangeNotifier {
  final PubChemApi _api = PubChemApi();
  final CacheService _cacheService = CacheService();
  final SearchHistoryService _searchHistoryService = SearchHistoryService();

  // State variables
  bool _isLoading = false;
  String? _error;
  String? _detailsError;
  Compound? _searchResults;
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
  Compound? get searchedCompound => _searchResults;
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
      await _loadSearchHistory();
      await _loadFeaturedCompounds();
    } catch (e) {
      _setError('Failed to initialize compound provider: $e');
    }
  }

  /// Load search history from storage
  Future<void> _loadSearchHistory() async {
    try {
      _searchHistory = _searchHistoryService.getSearchHistory();
      notifyListeners();
    } catch (e) {
      print('Error loading search history: $e');
    }
  }

  /// Load featured compounds for home screen
  Future<void> _loadFeaturedCompounds() async {
    _setFeaturedLoading(true);

    try {
      // Featured compound names from constants
      const featuredNames = AppConstants.featuredCompoundNames;

      final loadedCompounds = <Compound>[];

      for (final name in featuredNames) {
        try {
          // Search for compound by name to get CID
          final searchedCompound = await _api.searchCompounds(name);

          if (searchedCompound != null) {
            // Get the first CID (most relevant result)
            final int cid = searchedCompound.cid;

            // Try to get from cache first
            Compound? compound = _cacheService.getCompound(cid);

            if (compound == null) {
              // Fetch from API
              compound = await _api.getCompoundDetails(cid);
              await _cacheService.saveCompound(compound);
            }
            AppLogger.info("Featured Compound loaded: ${compound.title}");
            loadedCompounds.add(compound);
          }
        } catch (e) {
          print('Error loading featured compound $name: $e');
          // Continue with other compounds even if one fails
        }
      }

      _featuredCompounds = loadedCompounds;
      _clearFeaturedError();
    } catch (e) {
      _setFeaturedError('Failed to load featured compounds: $e');
    } finally {
      _setFeaturedLoading(false);
    }
  }

  /// Search compounds by name
  Future<void> searchCompounds(String searchTerm) async {
    if (searchTerm.trim().isEmpty) {
      _searchResults = null;
      notifyListeners();
      return;
    }

    _setLoading(true);

    try {
      // Add to search history
      await _searchHistoryService.addSearchTerm(searchTerm.trim());
      await _updateSearchHistory();

      // Search for compound CIDs
      final searchedCompound = await _api.searchCompounds(searchTerm);

      if (searchedCompound == null) {
        _searchResults = null;
        _clearError();
      } else {
        // Sort by original CID order
        _searchResults = searchedCompound;

        _clearError();
      }
    } catch (e) {
      _setError('Search failed: $e');
      _searchResults = null;
    } finally {
      _setLoading(false);
    }
  }

  /// Get compound details by CID
  Future<Compound?> getCompoundDetails(int cid) async {
    _setLoading(true);

    try {
      // Try cache first
      Compound? compound = _cacheService.getCompound(cid);

      if (compound == null) {
        // Fetch from API
        compound = await _api.getCompoundDetails(cid);
        await _cacheService.saveCompound(compound);
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

  /// Update local search history from service
  Future<void> _updateSearchHistory() async {
    try {
      _searchHistory = _searchHistoryService.getSearchHistory();
      notifyListeners();
    } catch (e) {
      print('Error updating search history: $e');
    }
  }

  /// Clear search history
  Future<void> clearSearchHistory() async {
    try {
      await _searchHistoryService.clearSearchHistory();
      _searchHistory.clear();
      notifyListeners();
    } catch (e) {
      print('Error clearing search history: $e');
    }
  }

  /// Load featured compounds
  Future<void> loadFeaturedCompounds() async {
    await _loadFeaturedCompounds();
  }

  /// Load search history from storage
  Future<void> loadSearchHistory() async {
    try {
      _searchHistory = _searchHistoryService.getSearchHistory();
      notifyListeners();
    } catch (e) {
      print('Error loading search history: $e');
    }
  }

  /// Add to search history
  Future<void> addToSearchHistory(String query) async {
    try {
      if (query.isNotEmpty) {
        await _searchHistoryService.addSearchTerm(query);
        await _updateSearchHistory();
      }
    } catch (e) {
      print('Error adding to search history: $e');
    }
  }

  /// Remove from search history
  Future<void> removeFromSearchHistory(String query) async {
    try {
      await _searchHistoryService.removeSearchTerm(query);
      await _updateSearchHistory();
    } catch (e) {
      print('Error removing from search history: $e');
    }
  }

  /// Clear search results
  void clearSearchResults() {
    _searchResults = null;
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

  /// Set featured loading state
  void _setFeaturedLoading(bool loading) {
    _isLoadingFeatured = loading;
    notifyListeners();
  }

  /// Set featured error message
  void _setFeaturedError(String error) {
    _featuredError = error;
    notifyListeners();
  }

  /// Clear featured error
  void _clearFeaturedError() {
    _featuredError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    // Local data services are managed by HiveManager
    super.dispose();
  }
}
