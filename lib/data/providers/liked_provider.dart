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
    return _items.containsKey(likedId);
  }

  void addToLiked(Product product, ProductVariant variant) {
    final likedId = '${product.id}_${variant.id}';

    if (_items.containsKey(likedId)) {
      return;
    }

    _items.putIfAbsent(
      likedId,
      () => LikedItem(id: likedId, product: product, selectedVariant: variant),
    );
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
      total += likedItem.selectedVariant.price;
    });
    return total;
  }
}
