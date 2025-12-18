import 'package:flutter/material.dart';
import '../../core/utils/app_logger.dart';
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
      logger.d('Liked: Item already exists - $likedId');
      return;
    }

    logger.i('Liked: Adding product ${product.name}, Variant: ${variant.id}');
    _items.putIfAbsent(
      likedId,
      () => LikedItem(id: likedId, product: product, selectedVariant: variant),
    );
    notifyListeners();
  }

  void removeFromLiked(String likedId) {
    logger.i('Liked: Removing item - $likedId');
    _items.remove(likedId);
    notifyListeners();
  }

  void clearLiked() {
    logger.i('Liked: Clearing all');
    _items.clear();
    notifyListeners();
  }
}