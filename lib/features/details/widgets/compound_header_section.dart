import 'package:flutter/material.dart';
import '../../../core/models/compound.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/helpers.dart';

/// Widget for displaying compound header with name, formula and hazard indicator
class CompoundHeaderSection extends StatelessWidget {
  /// The compound to display
  final Compound compound;

  /// Constructor
  const CompoundHeaderSection({
    super.key,
    required this.compound,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppColors.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compound name
            Row(
              children: [
                Expanded(
                  child: Text(
                    compound.displayName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (compound.hasHazards)
                  Icon(
                    AppHelpers.getHazardIcon(compound.hazards),
                    color: AppHelpers.getHazardColor(compound.hazards),
                    size: 28,
                  ),
              ],
            ),
            
            const SizedBox(height: AppColors.paddingMedium),
            
            // Molecular formula
            if (compound.molecularFormula != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppColors.paddingMedium,
                  vertical: AppColors.paddingSmall,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(AppColors.radiusSmall),
                ),
                child: Text(
                  AppHelpers.formatMolecularFormula(compound.molecularFormula),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontFamily: 'monospace',
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}