import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../data/models/cart_item.dart';
import '../../../../data/models/product.dart';
import '../../../../data/providers/cart_provider.dart';
import '../../../../data/providers/liked_provider.dart';
import '../../../../data/providers/auth_provider.dart';
import '../../../widgets/custom_notification.dart';

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
    final auth = context.watch<AuthProvider>();
    final likedProvider = context.watch<LikedProvider>();

    final product = cartItem.product;
    final variant = cartItem.selectedVariant;
    final imageUrl = variant.imageURLs.isNotEmpty
        ? variant.imageURLs.first
        : null;

    final isLiked = likedProvider.isInLiked(variant.id);

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
                    Text(
                      product.name,
                      style: textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'cart.item_color'.tr(args: [variant.colors]),
                      style: textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'cart.item_price'.tr(
                        args: [
                          variant.price.toStringAsFixed(0),
                          'common.currency'.tr(),
                        ],
                      ),
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () async {
                            if (!auth.isAuthenticated) {
                              NotificationHelper.show(
                                context,
                                message: 'auth.login_required_to_favorite'.tr(),
                                isError: true,
                              );
                              return;
                            }

                            try {
                              if (isLiked) {
                                await likedProvider.removeFromLiked(
                                  variant.id,
                                  auth.token!,
                                );
                                if (context.mounted) {
                                  NotificationHelper.show(
                                    context,
                                    message: 'product.fav_removed'.tr(),
                                  );
                                }
                              } else {
                                await likedProvider.addToLiked(
                                  product,
                                  variant,
                                  auth.token!,
                                );
                                if (context.mounted) {
                                  NotificationHelper.show(
                                    context,
                                    message: 'product.fav_added'.tr(),
                                  );
                                }
                              }
                            } catch (e) {
                              if (context.mounted) {
                                NotificationHelper.show(
                                  context,
                                  message: 'common.error_occurred'.tr(),
                                  isError: true,
                                );
                              }
                            }
                          },
                          icon: Icon(
                            isLiked
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: isLiked
                                ? Colors.amber[600]
                                : theme.colorScheme.outline,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          onPressed: () {
                            if (auth.isAuthenticated) {
                              cartProvider.removeFromCart(
                                cartItem.id,
                                auth.token!,
                              );
                            }
                          },
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
                      onPressed: () {
                        if (auth.isAuthenticated) {
                          cartProvider.decrementQuantity(
                            cartItem.id,
                            auth.token!,
                          );
                        }
                      },
                    ),
                    Text('${cartItem.quantity}', style: textTheme.titleMedium),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        if (auth.isAuthenticated) {
                          cartProvider.incrementQuantity(
                            cartItem.id,
                            auth.token!,
                          );
                        }
                      },
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
