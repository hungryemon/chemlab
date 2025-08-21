import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/compound_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/widgets/compound_card.dart';
import '../../core/widgets/shimmer_widget.dart';
import '../../core/widgets/error_widget.dart';
import '../../core/widgets/search_bar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../app.dart';

/// Home screen displaying featured compounds and search functionality
class HomeScreen extends StatefulWidget {
  /// Constructor
  const HomeScreen({super.key});
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFeaturedCompounds();
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  /// Load featured compounds on app start
  Future<void> _loadFeaturedCompounds() async {
    final provider = context.read<CompoundProvider>();
    await provider.loadFeaturedCompounds();
  }
  
  /// Handle search submission
  void _handleSearch(String query) {
    if (query.trim().isNotEmpty) {
      context.goSearch(query.trim());
    }
  }
  
  /// Handle refresh
  Future<void> _handleRefresh() async {
    await _loadFeaturedCompounds();
  }
  
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: _buildAppBar(context, localizations!),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Search bar
            SliverToBoxAdapter(
              child: _buildSearchSection(localizations!),
            ),
            
            // Featured compounds section
            SliverToBoxAdapter(
              child: _buildFeaturedSection(localizations!),
            ),
            
            // Featured compounds list
            _buildFeaturedCompoundsList(),
            
            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: AppColors.paddingLarge),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build app bar with theme toggle
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return AppBar(
      title: Text(localizations.homeTitle),
      centerTitle: true,
      actions: [
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return IconButton(
              onPressed: themeProvider.toggleTheme,
              icon: Icon(
                themeProvider.isDarkMode
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              tooltip: themeProvider.isDarkMode
                  ? 'Switch to light mode'
                  : 'Switch to dark mode',
            );
          },
        ),
      ],
    );
  }
  
  /// Build search section
  Widget _buildSearchSection(AppLocalizations localizations) {
    return CompoundSearchBar(
      controller: _searchController,
      hintText: localizations.searchHint,
      onSubmitted: _handleSearch,
      onChanged: (query) {
        // Optional: Add real-time search suggestions here
      },
    );
  }
  
  /// Build featured section header
  Widget _buildFeaturedSection(AppLocalizations localizations) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppColors.paddingLarge,
        vertical: AppColors.paddingMedium,
      ),
      child: Row(
        children: [
          Icon(
            Icons.star,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: AppColors.paddingSmall),
          Text(
            localizations.featuredCompounds,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build featured compounds list
  Widget _buildFeaturedCompoundsList() {
    return Consumer<CompoundProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingFeatured) {
          return _buildLoadingList();
        }
        
        if (provider.featuredError != null) {
          return SliverToBoxAdapter(
            child: AppErrorWidget(
              message: provider.featuredError!,
              onRetry: _loadFeaturedCompounds,
            ),
          );
        }
        
        if (provider.featuredCompounds.isEmpty) {
          return SliverToBoxAdapter(
            child: AppErrorWidget.notFound(
              customMessage: 'No featured compounds available',
              onRetry: _loadFeaturedCompounds,
            ),
          );
        }
        
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final compound = provider.featuredCompounds[index];
              return CompoundCard(
                compound: compound,
                showDetails: true,
                onTap: () => context.goCompoundDetails(compound.cid),
              );
            },
            childCount: provider.featuredCompounds.length,
          ),
        );
      },
    );
  }
  
  /// Build loading shimmer list
  Widget _buildLoadingList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => const ShimmerCompoundCard(),
        childCount: AppConstants.featuredCompoundCids.length,
      ),
    );
  }
}