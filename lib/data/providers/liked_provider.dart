import 'package:flutter/material.dart';
import '../../core/utils/app_logger.dart';
import '../models/liked_item.dart';
import '../models/product.dart';
import '../models/product_variant.dart';
import '../services/favorites_service.dart';
import '../services/product_service.dart';

class LikedProvider with ChangeNotifier {
  final FavoritesService _favService = FavoritesService();
  final ProductService _prodService = ProductService();

  final List<LikedItem> _items = [];
  bool _isLoading = false;

  List<LikedItem> get likedItems => _items;
  int get itemCount => _items.length;
  bool get isLoading => _isLoading;

  bool isInLiked(int variantId) {
    return _items.any((item) => item.selectedVariant.id == variantId);
  }

  Future<void> loadRemoteFavorites(String token) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final rawFavs = await _favService.getFavorites(token);

      if (rawFavs.isEmpty) {
        _items.clear();
        _isLoading = false;
        notifyListeners();
        return;
      }

      List<LikedItem> tempItems = [];

      final uniqueProductIds = rawFavs
          .map((f) => f['product_id'] as int)
          .toSet();

      for (var pId in uniqueProductIds) {
        final product = await _prodService.fetchProductById(pId);
        if (product != null) {
          final relevantFavs = rawFavs.where((f) => f['product_id'] == pId);
          for (var fav in relevantFavs) {
            final vId = fav['id'];
            final variant = product.variants.firstWhere(
              (v) => v.id == vId,
              orElse: () => product.variants.first,
            );
            tempItems.add(
              LikedItem(
                favEntryId: vId,
                product: product,
                selectedVariant: variant,
              ),
            );
          }
        }
      }

      _items.clear();
      _items.addAll(tempItems);
    } catch (e) {
      logger.e('LikedProvider: Sync error', error: e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToLiked(
    Product product,
    ProductVariant variant,
    String token,
  ) async {
    if (isInLiked(variant.id)) return;

    final newItem = LikedItem(
      favEntryId: variant.id,
      product: product,
      selectedVariant: variant,
    );
    _items.add(newItem);
    notifyListeners();

    try {
      final success = await _favService.addFavorite(variant.id, token);
      if (!success) throw Exception();
    } catch (e) {
      _items.removeWhere((item) => item.selectedVariant.id == variant.id);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> removeFromLiked(int variantId, String token) async {
    final index = _items.indexWhere(
      (item) => item.selectedVariant.id == variantId,
    );
    if (index == -1) return;

    final removedItem = _items[index];

    _items.removeAt(index);
    notifyListeners();

    try {
      final success = await _favService.deleteFavorite(variantId, token);
      if (!success) throw Exception();
    } catch (e) {
      _items.insert(index, removedItem);
      notifyListeners();
      rethrow;
    }
  }

  void clearLiked() {
    _items.clear();
    notifyListeners();
  }
}
