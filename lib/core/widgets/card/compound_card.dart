import 'package:flutter/material.dart';
import '../../models/compound.dart';
import '../../theme/app_colors.dart';
import '../../utils/helpers.dart';

/// Reusable compound card widget for displaying compound information
class CompoundCard extends StatelessWidget {
  /// The compound to display
  final Compound compound;
  
  /// Callback when card is tapped
  final VoidCallback? onTap;
  
  /// Whether to show detailed information
  final bool showDetails;
  
  /// Card elevation
  final double elevation;
  
  /// Constructor
  const CompoundCard({
    super.key,
    required this.compound,
    this.onTap,
    this.showDetails = false,
    this.elevation = 2.0,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: elevation,
      margin: const EdgeInsets.symmetric(
        horizontal: AppColors.paddingLarge,
        vertical: AppColors.paddingSmall,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppColors.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppColors.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and hazard indicator
              Row(
                children: [
                  Expanded(
                    child: Text(
                      compound.displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (compound.hasHazards) ...[
                    const SizedBox(width: AppColors.paddingSmall),
                    Icon(
                      AppHelpers.getHazardIcon(compound.hazards),
                      color: AppHelpers.getHazardColor(compound.hazards),
                      size: 20,
                    ),
                  ],
                ],
              ),
              
              const SizedBox(height: AppColors.paddingSmall),
              
              // Molecular formula
              if (compound.molecularFormula != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.science,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppColors.paddingSmall),
                    Text(
                      AppHelpers.formatMolecularFormula(compound.molecularFormula),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'monospace',
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppColors.paddingSmall),
              ],
              
              // Molecular weight
              if (compound.molecularWeight != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.scale,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppColors.paddingSmall),
                    Text(
                      AppHelpers.formatMolecularWeight(compound.molecularWeight),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppColors.paddingSmall),
              ],
              
              // CAS number
              if (showDetails && compound.casNumber != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.tag,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppColors.paddingSmall),
                    Text(
                      'CAS: ${compound.casNumber}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppColors.paddingSmall),
              ],
              
              // Synonyms (first few)
              if (showDetails && compound.synonyms.isNotEmpty) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.label,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppColors.paddingSmall),
                    Expanded(
                      child: Text(
                        compound.synonyms.take(3).join(', '),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppColors.paddingSmall),
              ],
              
              // Hazards
              if (showDetails && compound.hasHazards) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning,
                      size: 16,
                      color: AppHelpers.getHazardColor(compound.hazards),
                    ),
                    const SizedBox(width: AppColors.paddingSmall),
                    Expanded(
                      child: Text(
                        compound.hazards.take(2).join(', '),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppHelpers.getHazardColor(compound.hazards),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              
              // Footer with CID
              if (showDetails) ...[
                const SizedBox(height: AppColors.paddingMedium),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CID: ${compound.cid}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (onTap != null)
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}