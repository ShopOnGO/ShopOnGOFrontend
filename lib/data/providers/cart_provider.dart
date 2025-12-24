import 'package:flutter/material.dart';
import '../../core/utils/app_logger.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../models/product_variant.dart';
import '../services/cart_service.dart';
import '../services/product_service.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService;
  final ProductService _prodService;

  CartProvider({CartService? cartService, ProductService? prodService})
    : _cartService = cartService ?? CartService(),
      _prodService = prodService ?? ProductService();

  final Map<String, CartItem> _items = {};
  bool _isLoading = false;

  List<CartItem> get cartItems => _items.values.toList();
  int get itemCount => _items.length;
  bool get isLoading => _isLoading;

  Future<void> loadRemoteCart(String token) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _cartService.getCart(token);
      _items.clear();

      if (data != null && data['CartItems'] != null) {
        final List<dynamic> remoteItems = data['CartItems'];

        for (var itemJson in remoteItems) {
          final int variantId = itemJson['ProductVariantID'];
          final int quantity = itemJson['Quantity'];
          final int productId = itemJson['ProductVariant']['ProductID'];

          final product = await _prodService.fetchProductById(productId);
          if (product != null) {
            final variant = product.variants.firstWhere(
              (v) => v.id == variantId,
              orElse: () => product.variants.first,
            );

            final cartId = '${productId}_$variantId';
            _items[cartId] = CartItem(
              id: cartId,
              product: product,
              selectedVariant: variant,
              quantity: quantity,
            );
          }
        }
      }
    } catch (e) {
      logger.e('CartProvider: Sync error', error: e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(
    Product product,
    ProductVariant variant,
    String token, {
    int quantity = 1,
  }) async {
    final cartId = '${product.id}_${variant.id}';

    if (_items.containsKey(cartId)) {
      _items.update(
        cartId,
        (existing) => CartItem(
          id: existing.id,
          product: existing.product,
          selectedVariant: existing.selectedVariant,
          quantity: existing.quantity + quantity,
        ),
      );
    } else {
      _items[cartId] = CartItem(
        id: cartId,
        product: product,
        selectedVariant: variant,
        quantity: quantity,
      );
    }
    notifyListeners();

    try {
      final success = await _cartService.addCartItem(
        variant.id,
        quantity,
        token,
      );
      if (!success) throw Exception('Failed to add to remote cart');
    } catch (e) {
      loadRemoteCart(token);
      rethrow;
    }
  }

  Future<void> incrementQuantity(String cartId, String token) async {
    final item = _items[cartId];
    if (item == null) return;

    final newQty = item.quantity + 1;
    item.quantity = newQty;
    notifyListeners();

    try {
      await _cartService.updateCartItem(item.selectedVariant.id, newQty, token);
    } catch (e) {
      loadRemoteCart(token);
    }
  }

  Future<void> decrementQuantity(String cartId, String token) async {
    final item = _items[cartId];
    if (item == null) return;

    if (item.quantity > 1) {
      final newQty = item.quantity - 1;
      item.quantity = newQty;
      notifyListeners();
      try {
        await _cartService.updateCartItem(
          item.selectedVariant.id,
          newQty,
          token,
        );
      } catch (e) {
        loadRemoteCart(token);
      }
    } else {
      removeFromCart(cartId, token);
    }
  }

  Future<void> removeFromCart(String cartId, String token) async {
    final item = _items[cartId];
    if (item == null) return;

    _items.remove(cartId);
    notifyListeners();

    try {
      await _cartService.deleteCartItem(item.selectedVariant.id, token);
    } catch (e) {
      loadRemoteCart(token);
    }
  }

  Future<void> clearCart(String token) async {
    _items.clear();
    notifyListeners();
    try {
      await _cartService.deleteCart(token);
    } catch (e) {
      loadRemoteCart(token);
    }
  }

  void clearLocalData() {
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
