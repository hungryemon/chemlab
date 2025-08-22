import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Widget for displaying individual pieces of compound information
class DetailInfoRow extends StatelessWidget {
  /// The label for the information
  final String label;
  
  /// The value to display
  final String value;
  
  /// The icon to display
  final IconData icon;
  
  /// Callback when the row is tapped
  final VoidCallback? onTap;
  
  /// Whether to show the leading label text
  final bool showLeadingText;
  
  /// Color for the icon
  final Color? iconColor;

  /// Constructor
  const DetailInfoRow({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.onTap,
    this.showLeadingText = true,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppColors.radiusSmall),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppColors.paddingSmall,
          horizontal: AppColors.paddingSmall,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 16,
              color: iconColor ?? Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: AppColors.paddingSmall),
            Expanded(
              child: showLeadingText
                  ? Row(
                      children: [
                        Text(
                          '$label: ',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            value,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      value,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
            ),
            if (onTap != null)
              Icon(
                Icons.copy,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }
}