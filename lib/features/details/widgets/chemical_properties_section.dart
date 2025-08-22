import 'package:flutter/material.dart';
import '../../../core/models/compound.dart';
import '../../../core/utils/helpers.dart';
import 'detail_info_card.dart';
import 'detail_info_row.dart';

/// Widget for displaying chemical properties of a compound
class ChemicalPropertiesSection extends StatelessWidget {
  /// The compound to display
  final Compound compound;
  
  /// Callback for copying text to clipboard
  final Function(String text, String label) onCopyToClipboard;

  /// Constructor
  const ChemicalPropertiesSection({
    super.key,
    required this.compound,
    required this.onCopyToClipboard,
  });

  @override
  Widget build(BuildContext context) {
    return DetailInfoCard(
      title: 'Chemical Properties',
      icon: Icons.science,
      children: [
        if (compound.molecularFormula != null)
          DetailInfoRow(
            label: 'Molecular Formula',
            value: AppHelpers.formatMolecularFormula(compound.molecularFormula),
            icon: Icons.functions,
            onTap: () => onCopyToClipboard(
              compound.molecularFormula!,
              'Molecular formula',
            ),
          ),
      ],
    );
  }
}