import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/cart_item.dart';
import '../../../data/models/product.dart';
import '../../../data/providers/cart_provider.dart';
import 'widgets/cart_item_card.dart';
import 'widgets/order_summary_card.dart';

class CartPage extends StatelessWidget {
  final Function(Product) onProductSelected;

  const CartPage({super.key, required this.onProductSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLargeScreen = MediaQuery.of(context).size.width > 800;

    final cartProvider = context.watch<CartProvider>();
    final cartItems = cartProvider.cartItems;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: isLargeScreen
              ? _buildWideLayout(
                  context,
                  theme,
                  cartItems,
                  cartProvider.totalAmount,
                )
              : _buildNarrowLayout(
                  context,
                  theme,
                  cartItems,
                  cartProvider.totalAmount,
                ),
        ),
      ),
    );
  }

  Widget _buildWideLayout(
    BuildContext context,
    ThemeData theme,
    List<CartItem> cartItems,
    double total,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 5, child: _buildCartItemsList(theme, cartItems)),
        const SizedBox(width: 24),
        Expanded(flex: 3, child: OrderSummaryCard(totalAmount: total)),
      ],
    );
  }

  Widget _buildNarrowLayout(
    BuildContext context,
    ThemeData theme,
    List<CartItem> cartItems,
    double total,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildCartItemsList(theme, cartItems),
        const SizedBox(height: 24),
        OrderSummaryCard(totalAmount: total),
      ],
    );
  }

  Widget _buildCartItemsList(ThemeData theme, List<CartItem> cartItems) {
    final Color panelColor = theme.colorScheme.secondaryContainer;
    final Color borderColor = theme.scaffoldBackgroundColor;
    const double borderWidth = 6.0;
    const double borderRadius = 22.0;

    return Container(
      padding: const EdgeInsets.all(borderWidth),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: cartItems.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 48.0),
              child: Center(
                child: Text(
                  'Ваша корзина пуста',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                return CartItemCard(
                  cartItem: cartItems[index],
                  onProductSelected: onProductSelected,
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 16),
            ),
    );
  }
}
