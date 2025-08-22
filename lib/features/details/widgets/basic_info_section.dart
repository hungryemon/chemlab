import 'package:flutter/material.dart';
import '../../../core/models/compound.dart';
import '../../../core/utils/helpers.dart';
import 'detail_info_card.dart';
import 'detail_info_row.dart';

/// Widget for displaying basic compound information
class BasicInfoSection extends StatelessWidget {
  /// The compound to display
  final Compound compound;
  
  /// Callback for copying text to clipboard
  final Function(String text, String label) onCopyToClipboard;

  /// Constructor
  const BasicInfoSection({
    super.key,
    required this.compound,
    required this.onCopyToClipboard,
  });

  @override
  Widget build(BuildContext context) {
    return DetailInfoCard(
      title: 'Basic Information',
      icon: Icons.info_outline,
      children: [
        if (compound.molecularWeight != null)
          DetailInfoRow(
            label: 'Molecular Weight',
            value: AppHelpers.formatMolecularWeight(compound.molecularWeight),
            icon: Icons.scale,
            onTap: () => onCopyToClipboard(
              compound.molecularWeight.toString(),
              'Molecular weight',
            ),
          ),
        
        if (compound.iupacName != null)
          DetailInfoRow(
            label: 'IUPAC Name',
            value: compound.iupacName!,
            icon: Icons.science,
            onTap: () => onCopyToClipboard(
              compound.iupacName!,
              'IUPAC name',
            ),
          ),
        
        DetailInfoRow(
          label: 'PubChem CID',
          value: compound.cid.toString(),
          icon: Icons.tag,
          onTap: () => onCopyToClipboard(
            compound.cid.toString(),
            'CID',
          ),
        ),
      ],
    );
  }
}