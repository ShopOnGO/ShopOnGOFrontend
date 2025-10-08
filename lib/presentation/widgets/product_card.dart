import 'package:flutter/material.dart';
import '../../data/models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    final firstVariant = product.variants.isNotEmpty
        ? product.variants.first
        : null;
    if (firstVariant == null) {
      return Card(
        child: Center(child: Text('Нет данных', style: textTheme.bodySmall)),
      );
    }

    final imageUrl = product.imageURLs.isNotEmpty
        ? product.imageURLs.first
        : (firstVariant.imageURLs.isNotEmpty
              ? firstVariant.imageURLs.first
              : null);

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              color: colorScheme.surfaceContainerHighest,
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.error_outline,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      loadingBuilder: (context, child, progress) =>
                          progress == null
                          ? child
                          : const Center(child: CircularProgressIndicator()),
                    )
                  : Icon(
                      Icons.image_not_supported,
                      size: 48,
                      color: colorScheme.onSurfaceVariant,
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  product.brand.name,
                  style: textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '${firstVariant.price.toStringAsFixed(0)} BYN',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
