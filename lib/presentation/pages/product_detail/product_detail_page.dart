import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/product.dart';
import '../../../data/providers/cart_provider.dart';
import '../../../data/providers/liked_provider.dart';
import '../../../data/providers/view_history_provider.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  final VoidCallback onClose;

  const ProductDetailPage({
    super.key,
    required this.product,
    required this.onClose,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _selectedVariantIndex = 0;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ViewHistoryProvider>(
        context,
        listen: false,
      ).addToHistory(widget.product);
    });
  }

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const double closeButtonIconSize = 40.0;
    const double closeButtonDiameter = kMinInteractiveDimension;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 40.0, vertical: 32.0),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(6.0 + 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(22.0),
                  border: Border.all(
                      color: theme.scaffoldBackgroundColor, width: 6.0),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    bool isWide = constraints.maxWidth > 850;
                    return isWide
                        ? _buildWideLayout(context)
                        : _buildNarrowLayout(context);
                  },
                ),
              ),
              Positioned(
                top: -(closeButtonDiameter / 2),
                right: -(closeButtonDiameter / 2),
                child: Material(
                  color: theme.scaffoldBackgroundColor,
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon: Icon(Icons.close,
                        color: theme.iconTheme.color,
                        size: closeButtonIconSize),
                    onPressed: widget.onClose,
                    splashRadius: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    final imageUrl =
        widget.product.variants[_selectedVariantIndex].imageURLs.isNotEmpty
            ? widget.product.variants[_selectedVariantIndex].imageURLs.first
            : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 30.0, 24.0, 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: _buildImagePanel(context, imageUrl),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 5,
            child: _buildDetailsPanel(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsPanel(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final selectedVariant = widget.product.variants[_selectedVariantIndex];
    final likedProvider = context.watch<LikedProvider>();
    final isLiked = likedProvider.isInLiked(widget.product, selectedVariant);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 24.0, 16.0, 24.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.brand.name.toUpperCase(),
                        style: textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.product.name,
                        style: textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${selectedVariant.price.toStringAsFixed(0)} BYN',
                        style: textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (isLiked) {
                      likedProvider.removeFromLiked(
                          '${widget.product.id}_${selectedVariant.id}');
                    } else {
                      likedProvider.addToLiked(
                          widget.product, selectedVariant);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isLiked
                            ? 'Удалено из избранного'
                            : 'Добавлено в избранное!'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: Icon(
                    isLiked ? Icons.star_rounded : Icons.star_border_rounded,
                    color: isLiked
                        ? Colors.amber[600]
                        : theme.colorScheme.outline,
                    size: 32,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 5),
        
        _buildPurchasePanel(context),

        const SizedBox(height: 5),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Описание', style: textTheme.titleLarge),
                const SizedBox(height: 16),
                Text(
                  widget.product.description.isNotEmpty
                      ? widget.product.description
                      : 'Описание отсутствует.',
                  style: textTheme.bodyLarge?.copyWith(height: 1.6),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPurchasePanel(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final selectedVariant = widget.product.variants[_selectedVariantIndex];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.product.variants.length > 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Цвет: ${selectedVariant.colors}',
                        style: textTheme.titleMedium),
                    const SizedBox(height: 16),
                    Row(
                      children: List.generate(widget.product.variants.length,
                          (index) {
                        final variant = widget.product.variants[index];
                        final color = _getColorFromString(variant.colors);
                        final isSelected = index == _selectedVariantIndex;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedVariantIndex = index),
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(
                                      color: theme.colorScheme.primary,
                                      width: 2.5)
                                  : null,
                            ),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.dividerColor.withValues(alpha: 0.5),
                                  width:
                                      color == const Color(0xFFF5F5F5) ? 2 : 0,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Количество', style: textTheme.titleMedium),
                Container(
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (_quantity > 1) {
                            setState(() => _quantity--);
                          }
                        },
                      ),
                      Text('$_quantity', style: textTheme.titleMedium),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => setState(() => _quantity++),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.read<CartProvider>().addToCart(
                        widget.product,
                        selectedVariant,
                        quantity: _quantity,
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '${widget.product.name} (x$_quantity) добавлен в корзину!'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  textStyle: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                child: const Text('Добавить в корзину'),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildNarrowLayout(BuildContext context) {
    final imageUrl = widget
        .product.variants[_selectedVariantIndex].imageURLs.isNotEmpty
        ? widget.product.variants[_selectedVariantIndex].imageURLs.first
        : null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: _buildImagePanel(context, imageUrl),
          ),
          const SizedBox(height: 20),
          _buildDetailsPanel(context),
        ],
      ),
    );
  }

  Widget _buildImagePanel(BuildContext context, String? imageUrl) {
    return Card(
      margin: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: imageUrl != null
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : const Center(child: CircularProgressIndicator()),
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.error_outline, size: 48),
              )
            : const Icon(Icons.image_not_supported, size: 48),
      ),
    );
  }
}