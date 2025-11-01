import 'package:flutter/material.dart';
import '../models/liked_item.dart';
import '../models/product.dart';
import '../models/product_variant.dart';

class LikedProvider with ChangeNotifier {
  final Map<String, LikedItem> _items = {};

  List<LikedItem> get likedItems => _items.values.toList();

  int get itemCount => _items.length;

  bool isInLiked(Product product, ProductVariant variant) {
    final likedId = '${product.id}_${variant.id}';
    if (_items.containsKey(likedId)) {
      return true;
    } else {
      return false;
    }
  }

  void addToLiked(Product product, ProductVariant variant) {
    final likedId = '${product.id}_${variant.id}';

    if (_items.containsKey(likedId)) {
      _items.update(
        likedId,
        (existingLikedItem) => LikedItem(
          id: existingLikedItem.id,
          product: existingLikedItem.product,
          selectedVariant: existingLikedItem.selectedVariant,
          quantity: existingLikedItem.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        likedId,
        () => LikedItem(
          id: likedId,
          product: product,
          selectedVariant: variant,
          quantity: 1,
        ),
      );
    }
    notifyListeners();
  }

  void incrementQuantity(String likedId) {
    if (_items.containsKey(likedId)) {
      _items.update(
        likedId,
        (item) => LikedItem(
          id: item.id,
          product: item.product,
          selectedVariant: item.selectedVariant,
          quantity: item.quantity + 1,
        ),
      );
      notifyListeners();
    }
  }

  void decrementQuantity(String likedId) {
    if (!_items.containsKey(likedId)) return;

    if (_items[likedId]!.quantity > 1) {
      _items.update(
        likedId,
        (item) => LikedItem(
          id: item.id,
          product: item.product,
          selectedVariant: item.selectedVariant,
          quantity: item.quantity - 1,
        ),
      );
    } else {
      _items.remove(likedId);
    }
    notifyListeners();
  }

  void removeFromLiked(String likedId) {
    _items.remove(likedId);
    notifyListeners();
  }

  void clearLiked() {
    _items.clear();
    notifyListeners();
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, likedItem) {
      total += likedItem.selectedVariant.price * likedItem.quantity;
    });
    return total;
  }
}
