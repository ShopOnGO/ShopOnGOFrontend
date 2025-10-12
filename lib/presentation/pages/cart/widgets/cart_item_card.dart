// presentation/pages/cart/widgets/cart_item_card.dart

import 'package:flutter/material.dart';
import '../../../../data/models/product.dart';

class CartItemCard extends StatefulWidget {
  final Product product;

  const CartItemCard({super.key, required this.product});

  @override
  State<CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<CartItemCard> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final variant = widget.product.variants.first;
    final imageUrl =
        variant.imageURLs.isNotEmpty ? variant.imageURLs.first : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Изображение
            SizedBox(
              width: 100,
              height: 100,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
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
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.product.name, style: textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text('Цена: ${variant.price.toStringAsFixed(0)} BYN',
                      style: textTheme.bodyMedium),
                  Text('Дата: ${widget.product.createdAt.toLocal().toString().split(' ')[0]}',
                      style: textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                          onPressed: () {}, icon: const Icon(Icons.favorite_border)),
                      IconButton(
                          onPressed: () {}, icon: const Icon(Icons.delete_outline)),
                    ],
                  )
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      if (quantity > 1) setState(() => quantity--);
                    },
                  ),
                  Text('$quantity', style: textTheme.titleMedium),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => setState(() => quantity++),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}