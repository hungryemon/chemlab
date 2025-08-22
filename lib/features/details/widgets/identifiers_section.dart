import 'package:flutter/material.dart';
import '../../../core/models/compound.dart';
import 'detail_info_card.dart';
import 'detail_info_row.dart';

/// Widget for displaying compound identifiers
class IdentifiersSection extends StatelessWidget {
  /// The compound to display
  final Compound compound;
  
  /// Callback for copying text to clipboard
  final Function(String text, String label) onCopyToClipboard;

  /// Constructor
  const IdentifiersSection({
    super.key,
    required this.compound,
    required this.onCopyToClipboard,
  });

  @override
  Widget build(BuildContext context) {
    return DetailInfoCard(
      title: 'Identifiers',
      icon: Icons.fingerprint,
      children: [
        if (compound.casNumber != null)
          DetailInfoRow(
            label: 'CAS Number',
            value: compound.casNumber!,
            icon: Icons.numbers,
            onTap: () => onCopyToClipboard(
              compound.casNumber!,
              'CAS number',
            ),
          ),
      ],
    );
  }
}