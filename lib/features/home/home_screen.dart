import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/compound_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../app.dart';
import 'widgets/home_app_bar.dart';
import 'widgets/home_search_section.dart';
import 'widgets/featured_section_header.dart';
import 'widgets/featured_compounds_list.dart';

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
  bool alreadyLoaded = false;

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //     _loadFeaturedCompounds(); 
    // });
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
  void _handleSearch() {
      context.pushSearch();
    
  }

  /// Handle refresh
  Future<void> _handleRefresh() async {
    await _loadFeaturedCompounds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HomeAppBar(),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Search bar
            SliverToBoxAdapter(
              child: HomeSearchSection(
                controller: _searchController,
                onSubmitted: _handleSearch,
              ),
            ),

            // Featured compounds section
            const SliverToBoxAdapter(child: FeaturedSectionHeader()),

            // Featured compounds list
            FeaturedCompoundsList(
              onLoadFeaturedCompounds: _loadFeaturedCompounds,
            ),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: AppColors.paddingLarge),
            ),
          ],
        ),
      ),
    );
  }


}
