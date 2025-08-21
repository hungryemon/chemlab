import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/compound_provider.dart';
import '../../core/widgets/compound_card.dart';
import '../../core/widgets/shimmer_widget.dart';
import '../../core/widgets/error_widget.dart';
import '../../core/widgets/search_bar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/constants.dart';
import '../../core/utils/helpers.dart';
import '../../core/localization/app_localizations.dart';
import '../../app.dart';

/// Search screen for finding compounds
class SearchScreen extends StatefulWidget {
  /// Initial search query
  final String? initialQuery;
  
  /// Constructor
  const SearchScreen({super.key, this.initialQuery});
  
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();
  
  String _currentQuery = '';
  bool _showHistory = true;
  
  @override
  void initState() {
    super.initState();
    
    // Set initial query if provided
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      _currentQuery = widget.initialQuery!;
      _showHistory = false;
      
      // Perform initial search
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch(widget.initialQuery!);
      });
    } else {
      // Focus search bar if no initial query
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchFocusNode.requestFocus();
      });
    }
    
    // Load search history
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompoundProvider>().loadSearchHistory();
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
  
  /// Perform search with validation
  Future<void> _performSearch(String query) async {
    final trimmedQuery = query.trim();
    
    if (trimmedQuery.isEmpty) {
      setState(() {
        _showHistory = true;
      });
      return;
    }
    
    // Validate search query
    final validationError = AppHelpers.validateSearchTerm(trimmedQuery);
    if (validationError != null) {
      if (mounted) {
        AppHelpers.showSnackBar(
          context,
          validationError,
          isError: true,
        );
      }
      return;
    }
    
    setState(() {
      _currentQuery = trimmedQuery;
      _showHistory = false;
    });
    
    final provider = context.read<CompoundProvider>();
    await provider.searchCompounds(trimmedQuery);
    
    // Add to search history
    provider.addToSearchHistory(trimmedQuery);
  }
  
  /// Handle search query changes
  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _showHistory = true;
      });
    }
  }
  
  /// Handle search submission
  void _onSearchSubmitted(String query) {
    _performSearch(query);
  }
  
  /// Handle search clear
  void _onSearchClear() {
    setState(() {
      _currentQuery = '';
      _showHistory = true;
    });
    context.read<CompoundProvider>().clearSearchResults();
  }
  
  /// Handle history item tap
  void _onHistoryTap(String query) {
    _searchController.text = query;
    _performSearch(query);
  }
  
  /// Handle history item removal
  void _onHistoryRemove(String query) {
    context.read<CompoundProvider>().removeFromSearchHistory(query);
  }
  
  /// Handle clear all history
  void _onClearAllHistory() {
    context.read<CompoundProvider>().clearSearchHistory();
  }
  
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.searchTitle ?? 'Search'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search bar
          Consumer<CompoundProvider>(
            builder: (context, provider, child) {
              return CompoundSearchBar(
                controller: _searchController,
                focusNode: _searchFocusNode,
                hintText: localizations?.searchHint ?? 'Search compound',
                onChanged: _onSearchChanged,
                onSubmitted: _onSearchSubmitted,
                onClear: _onSearchClear,
                isLoading: provider.isSearching,
              );
            },
          ),
          
          // Content area
          Expanded(
            child: _showHistory
                ? _buildHistorySection(localizations!)
                : _buildSearchResults(localizations!),
          ),
        ],
      ),
    );
  }
  
  /// Build search history section
  Widget _buildHistorySection(AppLocalizations localizations) {
    return Consumer<CompoundProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search tips
              _buildSearchTips(localizations),
              
              // Search history
              if (provider.searchHistory.isNotEmpty)
                SearchHistory(
                  history: provider.searchHistory,
                  onHistoryTap: _onHistoryTap,
                  onHistoryRemove: _onHistoryRemove,
                  onClearAll: _onClearAllHistory,
                ),
            ],
          ),
        );
      },
    );
  }
  
  /// Build search tips section
  Widget _buildSearchTips(AppLocalizations localizations) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      margin: const EdgeInsets.all(AppColors.paddingLarge),
      padding: const EdgeInsets.all(AppColors.paddingLarge),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppColors.radiusMedium),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: AppColors.paddingSmall),
              Text(
                localizations.searchTips,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppColors.paddingMedium),
          Text(
            '• Search by compound name (e.g., "water", "caffeine")\n'
            '• Use chemical formulas (e.g., "H2O", "C8H10N4O2")\n'
            '• Try CAS numbers (e.g., "7732-18-5")\n'
            '• Search for IUPAC names',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build search results section
  Widget _buildSearchResults(AppLocalizations localizations) {
    return Consumer<CompoundProvider>(
      builder: (context, provider, child) {
        if (provider.isSearching) {
          return _buildLoadingResults();
        }
        
        if (provider.searchError != null) {
          return AppErrorWidget(
            message: provider.searchError!,
            onRetry: () => _performSearch(_currentQuery),
          );
        }
        
        if (provider.searchResults.isEmpty && _currentQuery.isNotEmpty) {
          return AppErrorWidget.notFound(
            customMessage: localizations.noResultsFound,
            onRetry: () => _performSearch(_currentQuery),
          );
        }
        
        return _buildResultsList(localizations);
      },
    );
  }
  
  /// Build loading results
  Widget _buildLoadingResults() {
    return ShimmerList(
      itemCount: 5,
      itemBuilder: (context, index) => const ShimmerCompoundCard(),
    );
  }
  
  /// Build search results list
  Widget _buildResultsList(AppLocalizations localizations) {
    return Consumer<CompoundProvider>(
      builder: (context, provider, child) {
        if (provider.searchResults.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Results header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppColors.paddingLarge,
                vertical: AppColors.paddingMedium,
              ),
              child: Text(
                '${provider.searchResults.length} ${localizations.resultsFound}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            // Results list
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: provider.searchResults.length,
                itemBuilder: (context, index) {
                  final compound = provider.searchResults[index];
                  return CompoundCard(
                    compound: compound,
                    showDetails: true,
                    onTap: () => context.goCompoundDetails(compound.cid),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}