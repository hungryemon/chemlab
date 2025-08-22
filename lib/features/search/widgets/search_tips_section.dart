import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/app_localizations.dart';

/// Widget that displays search tips to help users understand how to search
class SearchTipsSection extends StatelessWidget {
  /// Constructor
  const SearchTipsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
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
}