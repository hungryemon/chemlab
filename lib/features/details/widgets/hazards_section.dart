import 'package:flutter/material.dart';
import '../../../core/models/compound.dart';
import '../../../core/utils/helpers.dart';
import 'detail_info_card.dart';
import 'detail_info_row.dart';

/// Widget for displaying compound safety hazards
class HazardsSection extends StatelessWidget {
  /// The compound to display
  final Compound compound;
  
  /// Callback for copying text to clipboard
  final Function(String text, String label) onCopyToClipboard;

  /// Constructor
  const HazardsSection({
    super.key,
    required this.compound,
    required this.onCopyToClipboard,
  });

  @override
  Widget build(BuildContext context) {
    return DetailInfoCard(
      title: 'Safety Hazards',
      icon: Icons.warning,
      iconColor: AppHelpers.getHazardColor(compound.hazards),
      children: compound.hazards.map((hazard) => 
        DetailInfoRow(
          label: '',
          value: hazard,
          icon: Icons.warning_amber,
          showLeadingText: false,
          iconColor: AppHelpers.getHazardColor(compound.hazards),
          onTap: () => onCopyToClipboard(hazard, 'Hazard'),
        ),
      ).toList(),
    );
  }
}