import 'package:flutter/material.dart';
import '../../../core/models/compound.dart';
import '../../../core/theme/app_colors.dart';
import 'detail_info_card.dart';

/// Widget for displaying compound description
class DescriptionSection extends StatelessWidget {
  /// The compound to display
  final Compound compound;

  /// Constructor
  const DescriptionSection({
    super.key,
    required this.compound,
  });

  @override
  Widget build(BuildContext context) {
    return DetailInfoCard(
      title: 'Description',
      icon: Icons.description,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppColors.paddingSmall),
          child: Text(
            compound.description!,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}