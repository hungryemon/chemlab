import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/providers/compound_provider.dart';
import '../../core/models/compound.dart';
import '../../core/widgets/app_shimmer.dart';
import '../../core/widgets/error_widget.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../core/localization/app_localizations.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
            _buildHeaderSection(compound),
            const SizedBox(height: AppColors.paddingLarge),
            
            // Basic information
            _buildBasicInfoSection(compound, localizations),
            const SizedBox(height: AppColors.paddingLarge),
            
            // Chemical properties
            _buildChemicalPropertiesSection(compound, localizations),
            const SizedBox(height: AppColors.paddingLarge),
            
            // Identifiers
            _buildIdentifiersSection(compound, localizations),
            const SizedBox(height: AppColors.paddingLarge),
            
            // Synonyms
            if (compound.synonyms.isNotEmpty)
              _buildSynonymsSection(compound, localizations),
            
            // Hazards
            if (compound.hasHazards) ...[
              const SizedBox(height: AppColors.paddingLarge),
              _buildHazardsSection(compound, localizations),
            ],
            
            // Description
            if (compound.description != null) ...[
              const SizedBox(height: AppColors.paddingLarge),
              _buildDescriptionSection(compound, localizations),
            ],
            
            const SizedBox(height: AppColors.paddingLarge),
          ],
        ),
      ),
    );
  }
  
  /// Build header section with compound name and formula
  Widget _buildHeaderSection(Compound compound) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppColors.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compound name
            Row(
              children: [
                Expanded(
                  child: Text(
                    compound.displayName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (compound.hasHazards)
                  Icon(
                    AppHelpers.getHazardIcon(compound.hazards),
                    color: AppHelpers.getHazardColor(compound.hazards),
                    size: 28,
                  ),
              ],
            ),
            
            const SizedBox(height: AppColors.paddingMedium),
            
            // Molecular formula
            if (compound.molecularFormula != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppColors.paddingMedium,
                  vertical: AppColors.paddingSmall,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(AppColors.radiusSmall),
                ),
                child: Text(
                  AppHelpers.formatMolecularFormula(compound.molecularFormula),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontFamily: 'monospace',
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  /// Build basic information section
  Widget _buildBasicInfoSection(Compound compound, AppLocalizations localizations) {
    return _buildInfoCard(
      title: 'Basic Information',
      icon: Icons.info_outline,
      children: [
        if (compound.molecularWeight != null)
          _buildInfoRow(
            'Molecular Weight',
            AppHelpers.formatMolecularWeight(compound.molecularWeight),
            Icons.scale,
            onTap: () => _copyToClipboard(
              compound.molecularWeight.toString(),
              'Molecular weight',
            ),
          ),
        
        if (compound.iupacName != null)
          _buildInfoRow(
            'IUPAC Name',
            compound.iupacName!,
            Icons.science,
            onTap: () => _copyToClipboard(
              compound.iupacName!,
              'IUPAC name',
            ),
          ),
        
        _buildInfoRow(
          'PubChem CID',
          compound.cid.toString(),
          Icons.tag,
          onTap: () => _copyToClipboard(
            compound.cid.toString(),
            'CID',
          ),
        ),
      ],
    );
  }
  
  /// Build chemical properties section
  Widget _buildChemicalPropertiesSection(Compound compound, AppLocalizations localizations) {
    return _buildInfoCard(
      title: 'Chemical Properties',
      icon: Icons.science,
      children: [
        if (compound.molecularFormula != null)
          _buildInfoRow(
            'Molecular Formula',
            AppHelpers.formatMolecularFormula(compound.molecularFormula),
            Icons.functions,
            onTap: () => _copyToClipboard(
              compound.molecularFormula!,
              'Molecular formula',
            ),
          ),
      ],
    );
  }
  
  /// Build identifiers section
  Widget _buildIdentifiersSection(Compound compound, AppLocalizations localizations) {
    return _buildInfoCard(
      title: 'Identifiers',
      icon: Icons.fingerprint,
      children: [
        if (compound.casNumber != null)
          _buildInfoRow(
            'CAS Number',
            compound.casNumber!,
            Icons.numbers,
            onTap: () => _copyToClipboard(
              compound.casNumber!,
              'CAS number',
            ),
          ),
      ],
    );
  }
  
  /// Build synonyms section
  Widget _buildSynonymsSection(Compound compound, AppLocalizations localizations) {
    return _buildInfoCard(
      title: 'Synonyms',
      icon: Icons.label,
      children: compound.synonyms.map((synonym) => 
        _buildInfoRow(
          '',
          synonym,
          Icons.label_outline,
          showLeadingText: false,
          onTap: () => _copyToClipboard(synonym, 'Synonym'),
        ),
      ).toList(),
    );
  }
  
  /// Build hazards section
  Widget _buildHazardsSection(Compound compound, AppLocalizations localizations) {
    return _buildInfoCard(
      title: 'Safety Hazards',
      icon: Icons.warning,
      iconColor: AppHelpers.getHazardColor(compound.hazards),
      children: compound.hazards.map((hazard) => 
        _buildInfoRow(
          '',
          hazard,
          Icons.warning_amber,
          showLeadingText: false,
          iconColor: AppHelpers.getHazardColor(compound.hazards),
        ),
      ).toList(),
    );
  }
  
  /// Build description section
  Widget _buildDescriptionSection(Compound compound, AppLocalizations localizations) {
    return _buildInfoCard(
      title: 'Description',
      icon: Icons.description,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppColors.paddingSmall),
          child: Text(
            compound.description!,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
  
  /// Build info card wrapper
  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    Color? iconColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
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
                  color: iconColor ?? colorScheme.primary,
                  size: 24,
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
  
  /// Build info row
  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    bool showLeadingText = true,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
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
              color: iconColor ?? colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppColors.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showLeadingText && label.isNotEmpty)
                    Text(
                      label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  Text(
                    value,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
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