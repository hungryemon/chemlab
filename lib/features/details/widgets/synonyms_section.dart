import 'package:flutter/material.dart';
import '../../../core/models/compound.dart';
import 'detail_info_card.dart';
import 'detail_info_row.dart';

/// Widget for displaying compound synonyms with expandable functionality
class SynonymsSection extends StatefulWidget {
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
  State<SynonymsSection> createState() => _SynonymsSectionState();
}

class _SynonymsSectionState extends State<SynonymsSection> {
  /// Whether the synonyms list is expanded
  bool _isExpanded = false;
  
  /// Maximum number of synonyms to show when collapsed
  static const int _maxCollapsedItems = 3;

  @override
  Widget build(BuildContext context) {
    final synonyms = widget.compound.synonyms;
    final hasMoreThanMax = synonyms.length > _maxCollapsedItems;
    final displayedSynonyms = _isExpanded || !hasMoreThanMax 
        ? synonyms 
        : synonyms.take(_maxCollapsedItems).toList();

    final children = <Widget>[
      // Display synonym rows
      ...displayedSynonyms.map((synonym) => 
        DetailInfoRow(
          label: '',
          value: synonym,
          icon: Icons.label_outline,
          showLeadingText: false,
          onTap: () => widget.onCopyToClipboard(synonym, 'Synonym'),
        ),
      ),
      
      // Show expand/collapse button if there are more than max items
      if (hasMoreThanMax)
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isExpanded 
                        ? 'Show less' 
                        : 'Show ${synonyms.length - _maxCollapsedItems} more',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    ];

    return DetailInfoCard(
      title: 'Synonyms',
      icon: Icons.label,
      children: children,
    );
  }
}