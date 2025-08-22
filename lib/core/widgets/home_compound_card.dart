import 'package:flutter/material.dart';
import '../models/compound.dart';
import '../theme/app_colors.dart';
import '../utils/helpers.dart';
import '../../app.dart';

/// A reusable card widget for displaying compound information on the home screen
class HomeCompoundCard extends StatelessWidget {
  /// The compound data to display
  final Compound compound;
  
  /// Constructor
  const HomeCompoundCard({
    super.key,
    required this.compound,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => context.pushCompoundDetails(compound.cid),
        borderRadius: BorderRadius.circular(AppColors.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppColors.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Compound name with hazard indicator
              Row(
                children: [
                  Expanded(
                    child: Text(
                      compound.displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (compound.hasHazards)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppHelpers.getHazardColor(compound.hazards).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppColors.radiusSmall),
                      ),
                      child: Icon(
                        AppHelpers.getHazardIcon(compound.hazards),
                        size: 16,
                        color: AppHelpers.getHazardColor(compound.hazards),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.safeCompound.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppColors.radiusSmall),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: AppColors.safeCompound,
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: AppColors.paddingSmall),
              
              // Molecular formula
              if (compound.molecularFormula != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.science,
                      size: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        compound.molecularFormula!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontFamily: 'monospace',
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
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
                      size: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        AppHelpers.formatMolecularWeight(compound.molecularWeight),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppColors.paddingSmall),
              ],
              
              const Spacer(),
              
              // Hazard status text
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppColors.paddingSmall,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: compound.hasHazards
                      ? AppHelpers.getHazardColor(compound.hazards).withOpacity(0.1)
                      : AppColors.safeCompound.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppColors.radiusSmall),
                ),
                child: Text(
                  compound.hasHazards ? 'Hazardous' : 'Safe',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: compound.hasHazards
                        ? AppHelpers.getHazardColor(compound.hazards)
                        : AppColors.safeCompound,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}