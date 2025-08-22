import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import '../../theme/app_colors.dart';

/// Reusable shimmer component using shimmer_animation package
class AppShimmer extends StatelessWidget {
  /// Child widget to apply shimmer effect to
  final Widget child;
  
  /// Duration of the shimmer animation
  final Duration duration;
  
  /// Interval between shimmer animations
  final Duration interval;
  
  /// Color of the shimmer overlay
  final Color? color;
  
  /// Opacity of the shimmer color
  final double colorOpacity;
  
  /// Whether shimmer is enabled
  final bool enabled;
  
  /// Direction of the shimmer animation
  final ShimmerDirection direction;
  
  /// Constructor
  const AppShimmer({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 2),
    this.interval = const Duration(milliseconds: 500),
    this.color,
    this.colorOpacity = 0.3,
    this.enabled = true,
    this.direction = const ShimmerDirection.fromLTRB(),
  });
  
  @override
  Widget build(BuildContext context) {
    final shimmerColor = color ?? Theme.of(context).colorScheme.onSurface.withOpacity(0.1);
    
    return Shimmer(
      duration: duration,
      interval: interval,
      color: shimmerColor,
      colorOpacity: colorOpacity,
      enabled: enabled,
      direction: direction,
      child: child,
    );
  }
}

/// Shimmer placeholder widget for basic shapes
class ShimmerPlaceholder extends StatelessWidget {
  /// Width of the placeholder
  final double? width;
  
  /// Height of the placeholder
  final double height;
  
  /// Border radius of the placeholder
  final double borderRadius;
  
  /// Background color of the placeholder
  final Color? backgroundColor;
  
  /// Constructor
  const ShimmerPlaceholder({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = AppColors.radiusSmall,
    this.backgroundColor,
  });
  
  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? 
        Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3);
    
    return AppShimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Shimmer compound card for loading states
class ShimmerCompoundCard extends StatelessWidget {
  /// Constructor
  const ShimmerCompoundCard({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppColors.paddingMedium),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title shimmer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerPlaceholder(
                      height: 18,
                      width: 100,
                      borderRadius: AppColors.radiusSmall,
                    ),
                    const SizedBox(width: AppColors.paddingSmall),
                    const ShimmerPlaceholder(
                      height: 20,
                      width: 20,
                      borderRadius: AppColors.radiusSmall,
                    ),
                  ],
                ),
                
                const SizedBox(height: AppColors.paddingLarge),
                
                // Formula shimmer
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const ShimmerPlaceholder(
                      height: 16,
                      width: 16,
                      borderRadius: AppColors.radiusSmall,
                    ),
                    const SizedBox(width: AppColors.paddingSmall),
                    ShimmerPlaceholder(
                      height: 16,
                      width: 60,
                      borderRadius: AppColors.radiusSmall,
                    ),
                  ],
                ),
                
                const SizedBox(height: AppColors.paddingSmall),
                
                // Weight shimmer
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const ShimmerPlaceholder(
                      height: 16,
                      width: 16,
                      borderRadius: AppColors.radiusSmall,
                    ),
                    const SizedBox(width: AppColors.paddingSmall),
                    ShimmerPlaceholder(
                      height: 16,
                      width: 100,
                      borderRadius: AppColors.radiusSmall,
                    ),
                  ],
                ),
                
                const SizedBox(height: AppColors.paddingMedium),
                
               
              ],
            ),
             // Hazard status shimmer
                ShimmerPlaceholder(
                  height: 14,
                  width: double.infinity,
                  borderRadius: AppColors.radiusSmall,
                ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer list widget for multiple loading items
class ShimmerList extends StatelessWidget {
  /// Number of shimmer items to show
  final int itemCount;
  
  /// Item builder for shimmer items
  final Widget Function(BuildContext context, int index) itemBuilder;
  
  /// Constructor
  const ShimmerList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
  });
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}

/// Shimmer search bar for loading states
class ShimmerSearchBar extends StatelessWidget {
  /// Constructor
  const ShimmerSearchBar({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppColors.paddingLarge),
      child: ShimmerPlaceholder(
        height: 56,
        width: double.infinity,
        borderRadius: AppColors.radiusMedium,
      ),
    );
  }
}

/// Shimmer detail card for compound details loading
class ShimmerDetailCard extends StatelessWidget {
  /// Height of the shimmer card
  final double height;
  
  /// Constructor
  const ShimmerDetailCard({
    super.key,
    this.height = 120,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppColors.paddingMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppColors.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header shimmer
            Row(
              children: [
                const ShimmerPlaceholder(
                  height: 20,
                  width: 20,
                  borderRadius: AppColors.radiusSmall,
                ),
                const SizedBox(width: AppColors.paddingMedium),
                Expanded(
                  child: ShimmerPlaceholder(
                    height: 20,
                    width: double.infinity,
                    borderRadius: AppColors.radiusSmall,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppColors.paddingMedium),
            
            // Content lines
            ...List.generate(
              3,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: AppColors.paddingSmall),
                child: ShimmerPlaceholder(
                  height: 14,
                  width: index == 2 ? 150.0 : double.infinity,
                  borderRadius: AppColors.radiusSmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}