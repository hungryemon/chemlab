import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/app_localizations.dart';

/// Widget for displaying the featured compounds section header
class FeaturedSectionHeader extends StatelessWidget {
  /// Constructor
  const FeaturedSectionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppColors.paddingLarge,
        vertical: AppColors.paddingMedium,
      ),
      child: Row(
        children: [
          Icon(
            Icons.star,
            color: AppColors.featuredGold,
            size: 24,
          ),
          const SizedBox(width: AppColors.paddingSmall),
          Text(
            localizations.featuredCompounds,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}