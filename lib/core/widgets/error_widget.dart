import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

/// Reusable error widget for displaying error states
class AppErrorWidget extends StatelessWidget {
  /// Error message to display
  final String message;
  
  /// Optional error details
  final String? details;
  
  /// Retry callback
  final VoidCallback? onRetry;
  
  /// Error icon
  final IconData? icon;
  
  /// Whether to show retry button
  final bool showRetry;
  
  /// Custom action button
  final Widget? customAction;
  
  /// Constructor
  const AppErrorWidget({
    super.key,
    required this.message,
    this.details,
    this.onRetry,
    this.icon,
    this.showRetry = true,
    this.customAction,
  });
  
  /// Factory constructor for network errors
  factory AppErrorWidget.network({
    VoidCallback? onRetry,
    String? customMessage,
  }) {
    return AppErrorWidget(
      message: customMessage ?? AppConstants.errorNetworkMessage,
      icon: Icons.wifi_off,
      onRetry: onRetry,
    );
  }
  
  /// Factory constructor for server errors
  factory AppErrorWidget.server({
    VoidCallback? onRetry,
    String? customMessage,
  }) {
    return AppErrorWidget(
      message: customMessage ?? AppConstants.errorServerMessage,
      icon: Icons.error_outline,
      onRetry: onRetry,
    );
  }
  
  /// Factory constructor for timeout errors
  factory AppErrorWidget.timeout({
    VoidCallback? onRetry,
    String? customMessage,
  }) {
    return AppErrorWidget(
      message: customMessage ?? AppConstants.errorTimeoutMessage,
      icon: Icons.access_time,
      onRetry: onRetry,
    );
  }
  
  /// Factory constructor for not found errors
  factory AppErrorWidget.notFound({
    VoidCallback? onRetry,
    String? customMessage,
  }) {
    return AppErrorWidget(
      message: customMessage ?? 'No compounds found',
      icon: Icons.search_off,
      onRetry: onRetry,
      showRetry: false,
    );
  }
  
  /// Factory constructor for validation errors
  factory AppErrorWidget.validation({
    required String message,
    VoidCallback? onRetry,
  }) {
    return AppErrorWidget(
      message: message,
      icon: Icons.warning_amber,
      onRetry: onRetry,
      showRetry: false,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppColors.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
            
            const SizedBox(height: AppColors.paddingLarge),
            
            // Error message
            Text(
              message,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Error details
            if (details != null) ...[
              const SizedBox(height: AppColors.paddingMedium),
              Text(
                details!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            const SizedBox(height: AppColors.paddingLarge),
            
            // Action buttons
            if (customAction != null)
              customAction!
            else if (showRetry && onRetry != null)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppColors.paddingLarge,
                    vertical: AppColors.paddingMedium,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Compact error widget for inline errors
class CompactErrorWidget extends StatelessWidget {
  /// Error message to display
  final String message;
  
  /// Retry callback
  final VoidCallback? onRetry;
  
  /// Constructor
  const CompactErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(AppColors.paddingMedium),
      margin: const EdgeInsets.symmetric(
        horizontal: AppColors.paddingLarge,
        vertical: AppColors.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(AppColors.radiusMedium),
        border: Border.all(
          color: colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: AppColors.paddingMedium),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: AppColors.paddingMedium),
            IconButton(
              onPressed: onRetry,
              icon: Icon(
                Icons.refresh,
                color: colorScheme.error,
              ),
              iconSize: 20,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Error snackbar helper
class ErrorSnackBar {
  /// Show error snackbar
  static void show(
    BuildContext context,
    String message, {
    VoidCallback? onRetry,
    Duration duration = const Duration(seconds: 4),
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: colorScheme.onError,
              size: 20,
            ),
            const SizedBox(width: AppColors.paddingMedium),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: colorScheme.onError,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: colorScheme.error,
        duration: duration,
        action: onRetry != null
            ? SnackBarAction(
                label: 'Retry',
                textColor: colorScheme.onError,
                onPressed: onRetry,
              )
            : null,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppColors.paddingLarge),
      ),
    );
  }
}