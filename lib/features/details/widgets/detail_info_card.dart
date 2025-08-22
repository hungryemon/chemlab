import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Reusable card widget for compound detail sections
class DetailInfoCard extends StatelessWidget {
  /// The title of the section
  final String title;
  
  /// The icon for the section
  final IconData icon;
  
  /// The child widgets to display
  final List<Widget> children;
  
  /// Color for the icon
  final Color? iconColor;

  /// Constructor
  const DetailInfoCard({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppColors.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: iconColor ?? Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppColors.paddingMedium),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppColors.paddingMedium),
            
            // Section content
            ...children,
          ],
        ),
      ),
    );
  }
}