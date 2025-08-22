import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

/// Widget for displaying compound structure image
class StructureImageSection extends StatelessWidget {
  /// Structure image URL
  final int cid;
  

  const StructureImageSection({
    super.key,
    required this.cid,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
  

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Molecular Structure',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 300,
                  maxHeight: 300,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: 'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/$cid/PNG',

                    placeholder: (context, url) => _buildLoadingWidget(),
                    errorWidget: (context, url, error) => _buildErrorWidget(theme),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
           
          ],
        ),
      ),
    );
  }

  /// Build loading shimmer widget
  Widget _buildLoadingWidget() {
    return Container(
      width: 300,
      height: 300,
      padding: const EdgeInsets.all(16),
      child: Shimmer(
        duration: const Duration(seconds: 2),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Icon(
              Icons.image,
              size: 48,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  /// Build error widget when image fails to load
  Widget _buildErrorWidget(ThemeData theme) {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: 48,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 8),
          Text(
            'Structure image\nunavailable',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build widget when no image URL is provided
  Widget _buildNoImageWidget(ThemeData theme) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Molecular Structure',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 300,
                height: 200,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported,
                      size: 48,
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Structure image\nnot available',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}