import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/providers/compound_provider.dart';
import '../../core/models/compound.dart';
import '../../core/widgets/loader/app_shimmer.dart';
import '../../core/widgets/misc/error_widget.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../core/localization/app_localizations.dart';
import 'widgets/compound_header_section.dart';
import 'widgets/basic_info_section.dart';
import 'widgets/chemical_properties_section.dart';
import 'widgets/identifiers_section.dart';
import 'widgets/synonyms_section.dart';
import 'widgets/hazards_section.dart';
import 'widgets/description_section.dart';
import 'widgets/structure_image_section.dart';

/// Compound detail screen displaying comprehensive compound information
class CompoundDetailScreen extends StatefulWidget {
  /// Compound CID
  final int cid;
  
  /// Constructor
  const CompoundDetailScreen({super.key, required this.cid});
  
  @override
  State<CompoundDetailScreen> createState() => _CompoundDetailScreenState();
}

class _CompoundDetailScreenState extends State<CompoundDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    // Clear any previous compound data to ensure fresh state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CompoundProvider>();
      provider.clearCurrentCompound();
      _loadCompoundDetails();
    });
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  /// Load compound details
  Future<void> _loadCompoundDetails() async {
    final provider = context.read<CompoundProvider>();
    await provider.getCompoundDetails(widget.cid);
  }
  
  /// Copy text to clipboard
  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    AppHelpers.showSnackBar(
      context,
      '$label copied to clipboard',
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.detailsTitle ?? 'Compound Details'),
        centerTitle: true,
        automaticallyImplyLeading: true,
        actions: [
          Consumer<CompoundProvider>(
            builder: (context, provider, child) {
              final compound = provider.currentCompound;
              if (compound != null) {
                return IconButton(
                  onPressed: () => _showShareDialog(compound),
                  icon: const Icon(Icons.share),
                  tooltip: 'Share compound',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<CompoundProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingDetails) {
            return _buildLoadingContent();
          }
          
          if (provider.detailsError != null) {
            return AppErrorWidget(
              message: provider.detailsError!,
              onRetry: _loadCompoundDetails,
            );
          }
          
          final compound = provider.currentCompound;
          if (compound == null) {
            return AppErrorWidget.notFound(
              customMessage: 'Compound not found',
              onRetry: _loadCompoundDetails,
            );
          }
          
          return _buildCompoundDetails(compound, localizations!);
        },
      ),
    );
  }
  
  /// Build loading content
  Widget _buildLoadingContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppColors.paddingLarge),
      child: Column(
        children: [
          // Header shimmer
          const ShimmerPlaceholder(height: 40, width: double.infinity),
          const SizedBox(height: AppColors.paddingLarge),
          
          // Info cards shimmer
          ...List.generate(
            4,
            (index) => Container(
              margin: const EdgeInsets.only(bottom: AppColors.paddingMedium),
              child: const ShimmerPlaceholder(height: 120, width: double.infinity),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build compound details content
  Widget _buildCompoundDetails(Compound compound, AppLocalizations localizations) {
    return RefreshIndicator(
      onRefresh: _loadCompoundDetails,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppColors.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            CompoundHeaderSection(compound: compound),
            const SizedBox(height: AppColors.paddingLarge),
            
            // Structure image
             ...[
            StructureImageSection(
              cid: widget.cid
            ),
            const SizedBox(height: AppColors.paddingLarge),
            ],
            
            // Basic information
            BasicInfoSection(
              compound: compound,
              onCopyToClipboard: _copyToClipboard,
            ),
            const SizedBox(height: AppColors.paddingLarge),
            
            // Chemical properties
            ChemicalPropertiesSection(
              compound: compound,
              onCopyToClipboard: _copyToClipboard,
            ),
            const SizedBox(height: AppColors.paddingLarge),
            
            // Identifiers
            if(compound.casNumber != null && compound.casNumber!.isNotEmpty) ...[
            IdentifiersSection(
              compound: compound,
              onCopyToClipboard: _copyToClipboard,
            ),
            const SizedBox(height: AppColors.paddingLarge),
            ],
            
            // Synonyms
            if (compound.synonyms.isNotEmpty) ...[
              SynonymsSection(
                compound: compound,
                onCopyToClipboard: _copyToClipboard,
              ),
              const SizedBox(height: AppColors.paddingLarge),
            ],

             // Description
            if (compound.description != null && compound.description!.isNotEmpty) ...[
              DescriptionSection(compound: compound),
              const SizedBox(height: AppColors.paddingLarge),
            ],
            
            // Hazards
            if (compound.hasHazards) ...[
              HazardsSection(
                compound: compound,
                onCopyToClipboard: _copyToClipboard,
              ),
              const SizedBox(height: AppColors.paddingLarge),
            ],
            
           
          ],
        ),
      ),
    );
  }
  
  
  /// Show share dialog
  void _showShareDialog(Compound compound) {
    final shareText = 'Check out ${compound.displayName}\n'
        'Formula: ${compound.molecularFormula ?? 'N/A'}\n'
        'CID: ${compound.cid}\n'
        'Molecular Weight: ${AppHelpers.formatMolecularWeight(compound.molecularWeight)}';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Compound'),
        content: Text(shareText),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _copyToClipboard(shareText, 'Compound information');
              Navigator.of(context).pop();
            },
            child: const Text('Copy'),
          ),
        ],
      ),
    );
  }
}