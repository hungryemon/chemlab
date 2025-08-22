import 'package:flutter/material.dart';
import '../../localization/app_localizations.dart';
import '../../theme/app_colors.dart';

/// Custom search bar widget for compound search
class CompoundSearchBar extends StatefulWidget {
  /// Search query controller
  final TextEditingController controller;
  
  /// Callback when search query changes
  final ValueChanged<String>? onChanged;
  
  /// Callback when search is submitted
  final ValueChanged<String>? onSubmitted;
  
  /// Callback when clear button is pressed
  final VoidCallback? onClear;
  
  /// Hint text
  final String? hintText;
  
  /// Whether the search bar is enabled
  final bool enabled;
  
  /// Whether to show loading indicator
  final bool isLoading;
  
  /// Whether to show clear button
  final bool showClearButton;
  
  /// Focus node
  final FocusNode? focusNode;

  
  
  /// Constructor
  const CompoundSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.hintText,
    this.enabled = true,
    this.isLoading = false,
    this.showClearButton = true,
    this.focusNode,
  });
  
  @override
  State<CompoundSearchBar> createState() => _CompoundSearchBarState();
}

class _CompoundSearchBarState extends State<CompoundSearchBar> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  
  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }
  
  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }
  
  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }
  
  void _handleClear() {
    widget.controller.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppColors.paddingLarge,
        vertical: AppColors.paddingMedium,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppColors.radiusMedium),
        boxShadow: [
          if (_isFocused)
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        enabled: widget.enabled,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: widget.hintText ?? 'Search compounds...',
          prefixIcon: Icon(
            Icons.search,
            color: _isFocused
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          ),
          suffixIcon: _buildSuffixIcon(),
          filled: true,
          fillColor: colorScheme.surfaceVariant.withOpacity(0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppColors.radiusMedium),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppColors.radiusMedium),
            borderSide: BorderSide(
              color: colorScheme.primary,
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppColors.radiusMedium),
            borderSide: BorderSide(
              color: colorScheme.outline.withOpacity(0.3),
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppColors.radiusMedium),
            borderSide: BorderSide(
              color: colorScheme.outline.withOpacity(0.1),
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppColors.paddingLarge,
            vertical: AppColors.paddingMedium,
          ),
        ),
      ),
    );
  }
  
  Widget? _buildSuffixIcon() {
    if (widget.isLoading) {
      return Container(
        padding: const EdgeInsets.all(AppColors.paddingMedium),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      );
    }
    
    if (widget.showClearButton && widget.controller.text.isNotEmpty) {
      return IconButton(
        onPressed: _handleClear,
        icon: Icon(
          Icons.clear,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }
    
    return null;
  }
}

/// Search suggestions widget
class SearchSuggestions extends StatelessWidget {
  /// List of suggestions
  final List<String> suggestions;
  
  /// Callback when suggestion is tapped
  final ValueChanged<String>? onSuggestionTap;
  
  /// Whether to show loading indicator
  final bool isLoading;
  
  /// Constructor
  const SearchSuggestions({
    super.key,
    required this.suggestions,
    this.onSuggestionTap,
    this.isLoading = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    if (isLoading) {
      return Container(
        padding: const EdgeInsets.all(AppColors.paddingLarge),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
        ),
      );
    }
    
    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppColors.paddingLarge,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppColors.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: suggestions.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: colorScheme.outline.withOpacity(0.2),
        ),
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return ListTile(
            leading: Icon(
              Icons.search,
              color: colorScheme.onSurfaceVariant,
              size: 20,
            ),
            title: Text(
              suggestion,
              style: theme.textTheme.bodyMedium,
            ),
            trailing: Icon(
              Icons.north_west,
              color: colorScheme.onSurfaceVariant,
              size: 16,
            ),
            onTap: () => onSuggestionTap?.call(suggestion),
            dense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppColors.paddingLarge,
              vertical: AppColors.paddingSmall,
            ),
          );
        },
      ),
    );
  }
}

/// Search history widget
class SearchHistory extends StatelessWidget {
  /// List of search history items
  final List<String> history;
  
  /// Callback when history item is tapped
  final ValueChanged<String>? onHistoryTap;
  
  /// Callback when history item is removed
  final ValueChanged<String>? onHistoryRemove;
  
  /// Callback when clear all is pressed
  final VoidCallback? onClearAll;
  
  /// Constructor
  const SearchHistory({
    super.key,
    required this.history,
    this.onHistoryTap,
    this.onHistoryRemove,
    this.onClearAll,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localizations = AppLocalizations.of(context)!;
    
    if (history.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppColors.paddingLarge,
            vertical: AppColors.paddingMedium,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                localizations.recentSearches,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              if (onClearAll != null)
                TextButton(
                  onPressed: onClearAll,
                  child: Text(
                    'Clear all',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        // History items
        ...history.map((item) => ListTile(
          leading: Icon(
            Icons.history,
            color: colorScheme.onSurfaceVariant,
            size: 20,
          ),
          title: Text(
            item,
            style: theme.textTheme.bodyMedium,
          ),
          trailing: IconButton(
            onPressed: () => onHistoryRemove?.call(item),
            icon: Icon(
              Icons.close,
              color: colorScheme.onSurfaceVariant,
              size: 16,
            ),
          ),
          onTap: () => onHistoryTap?.call(item),
          dense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppColors.paddingLarge,
            vertical: AppColors.paddingSmall,
          ),
        )),
      ],
    );
  }
}