import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/compound_provider.dart';
import '../../core/widgets/bar/search_bar.dart';
import '../../core/utils/helpers.dart';
import '../../core/localization/app_localizations.dart';
import 'widgets/search_history_section.dart';
import 'widgets/search_results_section.dart';

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
        automaticallyImplyLeading: true,
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
                ? SearchHistorySection(
                    onHistoryTap: _onHistoryTap,
                    onHistoryRemove: _onHistoryRemove,
                    onClearAllHistory: _onClearAllHistory,
                  )
                : SearchResultsSection(
                    currentQuery: _currentQuery,
                    onRetrySearch: _performSearch,
                  ),
          ),
        ],
      ),
    );
  }
  

}