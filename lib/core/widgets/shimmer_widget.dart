import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/constants.dart';

/// Shimmer loading widget for better loading states
class ShimmerWidget extends StatefulWidget {
  /// Width of the shimmer widget
  final double? width;
  
  /// Height of the shimmer widget
  final double? height;
  
  /// Border radius
  final double borderRadius;
  
  /// Child widget to apply shimmer effect to
  final Widget? child;
  
  /// Constructor
  const ShimmerWidget({
    super.key,
    this.width,
    this.height,
    this.borderRadius = AppColors.radiusSmall,
    this.child,
  });
  
  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.shimmerDuration,
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.repeat();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [
                (_animation.value - 1).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 1).clamp(0.0, 1.0),
              ],
              colors: [
                colorScheme.surfaceVariant,
                colorScheme.surfaceVariant.withOpacity(0.5),
                colorScheme.surfaceVariant,
              ],
            ),
          ),
          child: widget.child,
        );
      },
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
      margin: const EdgeInsets.symmetric(
        horizontal: AppColors.paddingLarge,
        vertical: AppColors.paddingSmall,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppColors.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title shimmer
            Row(
              children: [
                Expanded(
                  child: ShimmerWidget(
                    height: 20,
                    width: double.infinity,
                    borderRadius: AppColors.radiusSmall,
                  ),
                ),
                const SizedBox(width: AppColors.paddingMedium),
                const ShimmerWidget(
                  height: 20,
                  width: 20,
                  borderRadius: AppColors.radiusSmall,
                ),
              ],
            ),
            
            const SizedBox(height: AppColors.paddingMedium),
            
            // Formula shimmer
            Row(
              children: [
                const ShimmerWidget(
                  height: 16,
                  width: 16,
                  borderRadius: AppColors.radiusSmall,
                ),
                const SizedBox(width: AppColors.paddingSmall),
                ShimmerWidget(
                  height: 16,
                  width: 80,
                  borderRadius: AppColors.radiusSmall,
                ),
              ],
            ),
            
            const SizedBox(height: AppColors.paddingSmall),
            
            // Weight shimmer
            Row(
              children: [
                const ShimmerWidget(
                  height: 16,
                  width: 16,
                  borderRadius: AppColors.radiusSmall,
                ),
                const SizedBox(width: AppColors.paddingSmall),
                ShimmerWidget(
                  height: 16,
                  width: 100,
                  borderRadius: AppColors.radiusSmall,
                ),
              ],
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
      child: ShimmerWidget(
        height: 56,
        width: double.infinity,
        borderRadius: AppColors.radiusMedium,
      ),
    );
  }
}