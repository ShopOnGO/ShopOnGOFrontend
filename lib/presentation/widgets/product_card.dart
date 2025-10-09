import 'package:flutter/material.dart';
import '../../data/models/product.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final Function(Product) onProductSelected;

  const ProductCard({
    super.key,
    required this.product,
    required this.onProductSelected,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  int _selectedVariantIndex = 0;

  Color _getColorFromString(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'черный':
        return Colors.black;
      case 'белый':
        return const Color(0xFFF5F5F5);
      case 'синий':
        return Colors.blue;
      case 'красный':
        return Colors.red;
      case 'зеленый':
        return Colors.green;
      case 'серый':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  Widget _buildVariantSelector() {
    const double itemWidth = 32.0;
    const double itemHeight = 24.0;
    const double overlap = 8.0;
    final int itemCount = widget.product.variants.length;
    final double totalWidth =
        (itemWidth * itemCount) - (overlap * (itemCount - 1));
    return SizedBox(
      width: totalWidth,
      height: itemHeight + 4,
      child: Stack(
        alignment: Alignment.center,
        children:
            List.generate(itemCount, (index) {
              final isSelected = index == _selectedVariantIndex;
              if (isSelected) return const SizedBox.shrink();
              return Positioned(
                left: index * (itemWidth - overlap),
                child: _buildVariantChip(index),
              );
            })..add(
              Positioned(
                left: _selectedVariantIndex * (itemWidth - overlap),
                child: _buildVariantChip(_selectedVariantIndex),
              ),
            ),
      ),
    );
  }

  Widget _buildVariantChip(int index) {
    final theme = Theme.of(context);
    final variant = widget.product.variants[index];
    final color = _getColorFromString(variant.colors);
    final isSelected = index == _selectedVariantIndex;
    return GestureDetector(
      onTap: () => setState(() => _selectedVariantIndex = index),
      child: Transform.scale(
        scale: isSelected ? 1.1 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: 32,
          height: 24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.cardColor, width: 3),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(9),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    if (widget.product.variants.isEmpty) {
      return Card(
        child: Center(child: Text('Нет данных', style: textTheme.bodySmall)),
      );
    }
    final selectedVariant = widget.product.variants[_selectedVariantIndex];
    final imageUrl = selectedVariant.imageURLs.isNotEmpty
        ? selectedVariant.imageURLs.first
        : null;

    return GestureDetector(
      onTap: () => widget.onProductSelected(widget.product),
      child: Card(
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
                        errorBuilder: (c, e, s) => Icon(
                          Icons.error_outline,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        loadingBuilder: (c, ch, p) => p == null
                            ? ch
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
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.product.brand.name,
                    style: textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${selectedVariant.price.toStringAsFixed(0)} BYN',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.product.variants.length > 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Center(child: _buildVariantSelector()),
              ),
          ],
        ),
      ),
    );
  }
}
