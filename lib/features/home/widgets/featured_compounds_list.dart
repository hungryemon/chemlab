import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/compound_provider.dart';
import '../../../core/widgets/loader/app_shimmer.dart';
import '../../../core/widgets/misc/error_widget.dart';
import '../../../core/widgets/card/home_compound_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/constants.dart';
import '../../../core/widgets/misc/sliver_delegate_with_fixed_cross_axis_count_and_fixed_height.dart';

/// Widget for displaying the featured compounds list with loading and error states
class FeaturedCompoundsList extends StatelessWidget {
  /// Callback function to load featured compounds
  final VoidCallback onLoadFeaturedCompounds;
  
  /// Constructor
  const FeaturedCompoundsList({
    super.key,
    required this.onLoadFeaturedCompounds,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CompoundProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingFeatured) {
          return _buildLoadingList(context);
        }

        if (provider.featuredError != null) {
          return SliverToBoxAdapter(
            child: AppErrorWidget(
              message: provider.featuredError!,
              onRetry: onLoadFeaturedCompounds,
            ),
          );
        }

        if (provider.featuredCompounds.isEmpty) {
          return SliverToBoxAdapter(
            child: AppErrorWidget.notFound(
              customMessage: 'No featured compounds available',
              onRetry: onLoadFeaturedCompounds,
            ),
          );
        }

        // Display compounds in a responsive grid layout
        return SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppColors.paddingLarge,
          ),
          sliver: SliverGrid(
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                  crossAxisCount: _getCrossAxisCount(context),
                  height: 160,
                  crossAxisSpacing: AppColors.paddingMedium,
                  mainAxisSpacing: AppColors.paddingMedium,
                ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final compound = provider.featuredCompounds[index];
              return HomeCompoundCard(compound: compound);
            }, childCount: provider.featuredCompounds.length),
          ),
        );
      },
    );
  }

  /// Get cross axis count based on screen width
  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 3;
    if (width > 800) return 2;
    return 1;
  }

  /// Build loading shimmer list
  Widget _buildLoadingList(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppColors.paddingLarge),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
          crossAxisCount: _getCrossAxisCount(context),
          height: 160,
          crossAxisSpacing: AppColors.paddingMedium,
          mainAxisSpacing: AppColors.paddingMedium,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => const ShimmerCompoundCard(),
          childCount: AppConstants.featuredCompoundNames.length,
        ),
      ),
    );
  }
}