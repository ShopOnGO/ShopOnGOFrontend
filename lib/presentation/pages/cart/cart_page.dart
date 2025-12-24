import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../data/models/cart_item.dart';
import '../../../data/models/product.dart';
import '../../../data/providers/cart_provider.dart';
import '../../../data/providers/auth_provider.dart';
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
    final auth = context.watch<AuthProvider>();
    final cartItems = cartProvider.cartItems;

    if (cartProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: isLargeScreen
              ? _buildWideLayout(context, theme, cartItems, cartProvider, auth)
              : _buildNarrowLayout(
                  context,
                  theme,
                  cartItems,
                  cartProvider,
                  auth,
                ),
        ),
      ),
    );
  }

  Widget _buildWideLayout(
    BuildContext context,
    ThemeData theme,
    List<CartItem> cartItems,
    CartProvider cartProvider,
    AuthProvider auth,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: _buildCartItemsList(
            context,
            theme,
            cartItems,
            cartProvider,
            auth,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 3,
          child: OrderSummaryCard(totalAmount: cartProvider.totalAmount),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(
    BuildContext context,
    ThemeData theme,
    List<CartItem> cartItems,
    CartProvider cartProvider,
    AuthProvider auth,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildCartItemsList(context, theme, cartItems, cartProvider, auth),
        const SizedBox(height: 24),
        OrderSummaryCard(totalAmount: cartProvider.totalAmount),
      ],
    );
  }

  Widget _buildCartItemsList(
    BuildContext context,
    ThemeData theme,
    List<CartItem> cartItems,
    CartProvider cartProvider,
    AuthProvider auth,
  ) {
    final Color panelColor = theme.colorScheme.secondaryContainer;
    final Color borderColor = theme.scaffoldBackgroundColor;
    const double borderWidth = 6.0;
    const double borderRadius = 22.0;

    return Container(
      padding: const EdgeInsets.all(borderWidth + 10),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (cartItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0, left: 8, right: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${"tabs.cart".tr()} (${cartItems.length})',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () =>
                        _showClearDialog(context, cartProvider, auth.token!),
                    icon: const Icon(
                      Icons.delete_sweep_outlined,
                      size: 20,
                      color: Colors.white70,
                    ),
                    label: Text(
                      'cart.clear_all'.tr(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (cartItems.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48.0),
              child: Center(
                child: Text(
                  'cart.empty'.tr(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
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
        ],
      ),
    );
  }

  void _showClearDialog(
    BuildContext context,
    CartProvider provider,
    String token,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('cart.clear_all'.tr()),
        content: Text('cart.clear_confirm'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('auth.btn_cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              provider.clearCart(token);
              Navigator.pop(ctx);
            },
            child: Text(
              'cart.clear_all'.tr(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
