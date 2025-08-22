import 'package:flutter/material.dart';
import '../../../core/models/compound.dart';
import 'detail_info_card.dart';
import 'detail_info_row.dart';

/// Widget for displaying compound synonyms
class SynonymsSection extends StatelessWidget {
  /// The compound to display
  final Compound compound;
  
  /// Callback for copying text to clipboard
  final Function(String text, String label) onCopyToClipboard;

  /// Constructor
  const SynonymsSection({
    super.key,
    required this.compound,
    required this.onCopyToClipboard,
  });

  @override
  Widget build(BuildContext context) {
    return DetailInfoCard(
      title: 'Synonyms',
      icon: Icons.label,
      children: compound.synonyms.map((synonym) => 
        DetailInfoRow(
          label: '',
          value: synonym,
          icon: Icons.label_outline,
          showLeadingText: false,
          onTap: () => onCopyToClipboard(synonym, 'Synonym'),
        ),
      ).toList(),
    );
  }
}