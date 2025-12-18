import 'package:flutter/material.dart';
import '../../core/utils/app_logger.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../models/product_variant.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  List<CartItem> get cartItems => _items.values.toList();
  int get itemCount => _items.length;

  void addToCart(Product product, ProductVariant variant, {int quantity = 1}) {
    final cartId = '${product.id}_${variant.id}';
    logger.i('Cart: Adding item - Product: ${product.name}, Variant: ${variant.id}, Qty: $quantity');

    if (_items.containsKey(cartId)) {
      _items.update(
        cartId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          product: existingCartItem.product,
          selectedVariant: existingCartItem.selectedVariant,
          quantity: existingCartItem.quantity + quantity,
        ),
      );
    } else {
      _items.putIfAbsent(
        cartId,
        () => CartItem(
          id: cartId,
          product: product,
          selectedVariant: variant,
          quantity: quantity,
        ),
      );
    }
    notifyListeners();
  }

  void incrementQuantity(String cartId) {
    if (_items.containsKey(cartId)) {
      _items.update(
        cartId,
        (item) => CartItem(
          id: item.id,
          product: item.product,
          selectedVariant: item.selectedVariant,
          quantity: item.quantity + 1,
        ),
      );
      logger.d('Cart: Incremented quantity for $cartId. New Qty: ${_items[cartId]?.quantity}');
      notifyListeners();
    }
  }

  void decrementQuantity(String cartId) {
    if (!_items.containsKey(cartId)) return;

    if (_items[cartId]!.quantity > 1) {
      _items.update(
        cartId,
        (item) => CartItem(
          id: item.id,
          product: item.product,
          selectedVariant: item.selectedVariant,
          quantity: item.quantity - 1,
        ),
      );
      logger.d('Cart: Decremented quantity for $cartId. New Qty: ${_items[cartId]?.quantity}');
    } else {
      logger.i('Cart: Removing item via decrement: $cartId');
      _items.remove(cartId);
    }
    notifyListeners();
  }

  void removeFromCart(String cartId) {
    logger.i('Cart: Removing item: $cartId');
    _items.remove(cartId);
    notifyListeners();
  }

  void clearCart() {
    logger.i('Cart: Clearing entire cart');
    _items.clear();
    notifyListeners();
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.selectedVariant.price * cartItem.quantity;
    });
    return total;
  }
}