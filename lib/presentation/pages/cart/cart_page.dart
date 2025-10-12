import 'package:flutter/material.dart';
import '../../../data/models/product.dart';
import '../../../data/services/product_service.dart';
import 'widgets/cart_item_card.dart';
import 'widgets/order_summary_card.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late Future<List<Product>> _cartItemsFuture;

  @override
  void initState() {
    super.initState();
    _cartItemsFuture = ProductService().fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLargeScreen = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: FutureBuilder<List<Product>>(
        future: _cartItemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Ваша корзина пуста'));
          }

          final cartItems = snapshot.data!.take(3).toList();
          final double total = cartItems.fold(
            0,
            (sum, item) => sum + item.variants.first.price,
          );

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: isLargeScreen
                  ? _buildWideLayout(context, theme, cartItems, total)
                  : _buildNarrowLayout(context, theme, cartItems, total),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWideLayout(
    BuildContext context,
    ThemeData theme,
    List<Product> cartItems,
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
    List<Product> cartItems,
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

  Widget _buildCartItemsList(ThemeData theme, List<Product> cartItems) {
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
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          return CartItemCard(product: cartItems[index]);
        },
        separatorBuilder: (context, index) => const SizedBox(height: 16),
      ),
    );
  }
}
