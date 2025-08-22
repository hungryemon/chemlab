import 'package:flutter/material.dart';
import '../../../core/widgets/bar/search_bar.dart';
import '../../../core/localization/app_localizations.dart';

/// Widget for the home screen search section
class HomeSearchSection extends StatelessWidget {
  /// Search controller
  final TextEditingController controller;
  
  /// Callback when search is submitted
  final VoidCallback onSubmitted;
  
  /// Callback when search text changes
  final ValueChanged<String>? onChanged;
  
  /// Constructor
  const HomeSearchSection({
    super.key,
    required this.controller,
    required this.onSubmitted,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return GestureDetector(
      onTap: onSubmitted,
      child: CompoundSearchBar(
        controller: controller,
        hintText: localizations.searchHint,
        enabled: false,
        onChanged: onChanged ?? (query) {
          // Optional: Add real-time search suggestions here
        },
      ),
    );
  }
}