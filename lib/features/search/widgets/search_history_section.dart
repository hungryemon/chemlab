import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/compound_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import 'search_tips_section.dart';

/// Widget that displays search history and tips
class SearchHistorySection extends StatelessWidget {
  /// Callback when a history item is tapped
  final Function(String) onHistoryTap;
  
  /// Callback when a history item is removed
  final Function(String) onHistoryRemove;
  
  /// Callback when all history is cleared
  final VoidCallback onClearAllHistory;
  
  /// Constructor
  const SearchHistorySection({
    super.key,
    required this.onHistoryTap,
    required this.onHistoryRemove,
    required this.onClearAllHistory,
  });

  @override
  Widget build(BuildContext context) {
    
    return Consumer<CompoundProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search tips
              const SearchTipsSection(),
              
              // Search history
              if (provider.searchHistory.isNotEmpty)
                SearchHistory(
                  history: provider.searchHistory,
                  onHistoryTap: onHistoryTap,
                  onHistoryRemove: onHistoryRemove,
                  onClearAll: onClearAllHistory,
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Widget that displays the search history list
class SearchHistory extends StatelessWidget {
  /// List of search history items
  final List<String> history;
  
  /// Callback when a history item is tapped
  final Function(String) onHistoryTap;
  
  /// Callback when a history item is removed
  final Function(String) onHistoryRemove;
  
  /// Callback when all history is cleared
  final VoidCallback onClearAll;
  
  /// Constructor
  const SearchHistory({
    super.key,
    required this.history,
    required this.onHistoryTap,
    required this.onHistoryRemove,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localizations = AppLocalizations.of(context)!;
    
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppColors.paddingLarge,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                localizations.recentSearches,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: onClearAll,
                child: Text(
                  localizations.clearHistory,
                  style: TextStyle(
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppColors.paddingSmall),
          
          // History items
          ...history.map((query) => _buildHistoryItem(
            context,
            query,
            onHistoryTap,
            onHistoryRemove,
          )),
        ],
      ),
    );
  }
  
  /// Build individual history item
  Widget _buildHistoryItem(
    BuildContext context,
    String query,
    Function(String) onTap,
    Function(String) onRemove,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppColors.paddingSmall),
      decoration: BoxDecoration(
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
        borderRadius: BorderRadius.circular(AppColors.radiusSmall),
      ),
      child: ListTile(
        leading: Icon(
          Icons.history,
          color: colorScheme.onSurfaceVariant,
          size: 20,
        ),
        title: Text(
          query,
          style: theme.textTheme.bodyMedium,
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.close,
            color: colorScheme.onSurfaceVariant,
            size: 18,
          ),
          onPressed: () => onRemove(query),
          tooltip: 'Remove from history',
        ),
        onTap: () => onTap(query),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppColors.paddingMedium,
          vertical: AppColors.paddingSmall,
        ),
      ),
    );
  }
}