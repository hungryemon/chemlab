import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/compound_provider.dart';
import '../../../core/widgets/card/compound_card.dart';
import '../../../core/widgets/misc/error_widget.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../app.dart';

/// Widget that displays search results with loading and error states
class SearchResultsSection extends StatelessWidget {
  /// Current search query
  final String currentQuery;
  
  /// Callback to retry search
  final Function(String) onRetrySearch;
  
  /// Constructor
  const SearchResultsSection({
    super.key,
    required this.currentQuery,
    required this.onRetrySearch,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Consumer<CompoundProvider>(
      builder: (context, provider, child) {
        if (provider.isSearching) {
          return const SearchLoadingResults();
        }
        
        if (provider.searchError != null) {
          return AppErrorWidget(
            message: provider.searchError!,
            onRetry: () => onRetrySearch(currentQuery),
          );
        }
        
        if (provider.searchedCompound == null && currentQuery.isNotEmpty) {
          return AppErrorWidget.notFound(
            customMessage: localizations.noResultsFound,
            onRetry: () => onRetrySearch(currentQuery),
          );
        }
        
        return SearchResultsList(
          compound: provider.searchedCompound,
        );
      },
    );
  }
}

/// Widget that displays loading shimmer for search results
class SearchLoadingResults extends StatelessWidget {
  /// Constructor
  const SearchLoadingResults({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Loading indicator with text
          Container(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Searching compounds...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
        ],
      ),
    );
  }
}

/// Widget that displays the actual search results
class SearchResultsList extends StatelessWidget {
  /// The compound to display
  final dynamic compound;
  
  /// Constructor
  const SearchResultsList({
    super.key,
    required this.compound,
  });

  @override
  Widget build(BuildContext context) {
    if (compound == null) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CompoundCard(
          compound: compound!,
          showDetails: true,
          onTap: () => context.pushCompoundDetails(compound!.cid),
        ),
      ],
    );
  }
}