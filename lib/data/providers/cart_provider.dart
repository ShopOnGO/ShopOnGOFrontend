import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../models/product_variant.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  List<CartItem> get cartItems => _items.values.toList();

  int get itemCount => _items.length;

  void addToCart(Product product, ProductVariant variant) {
    final cartId = '${product.id}_${variant.id}';

    if (_items.containsKey(cartId)) {
      _items.update(
        cartId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          product: existingCartItem.product,
          selectedVariant: existingCartItem.selectedVariant,
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        cartId,
        () => CartItem(
          id: cartId,
          product: product,
          selectedVariant: variant,
          quantity: 1,
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
    } else {
      _items.remove(cartId);
    }
    notifyListeners();
  }

  void removeFromCart(String cartId) {
    _items.remove(cartId);
    notifyListeners();
  }

  void clearCart() {
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
