import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/cart_item.dart';
import '../../../../data/models/product.dart';
import '../../../../data/providers/cart_provider.dart';

class CartItemCard extends StatelessWidget {
  final CartItem cartItem;
  final Function(Product) onProductSelected;

  const CartItemCard({
    super.key,
    required this.cartItem,
    required this.onProductSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final cartProvider = context.read<CartProvider>();

    final product = cartItem.product;
    final variant = cartItem.selectedVariant;
    final imageUrl = variant.imageURLs.isNotEmpty
        ? variant.imageURLs.first
        : null;

    return InkWell(
      onTap: () => onProductSelected(product),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: IgnorePointer(
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) =>
                                const Icon(Icons.error_outline),
                          )
                        : const Icon(Icons.image_not_supported),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      'Цвет: ${variant.colors}',
                      style: textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Цена: ${variant.price.toStringAsFixed(0)} BYN',
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.favorite_border),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          onPressed: () =>
                              cartProvider.removeFromCart(cartItem.id),
                          icon: const Icon(Icons.delete_outline),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () =>
                          cartProvider.decrementQuantity(cartItem.id),
                    ),
                    Text('${cartItem.quantity}', style: textTheme.titleMedium),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () =>
                          cartProvider.incrementQuantity(cartItem.id),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
