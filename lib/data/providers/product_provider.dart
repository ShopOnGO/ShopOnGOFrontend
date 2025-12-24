import 'package:flutter/material.dart';
import '../../core/utils/app_logger.dart';
import '../models/product.dart';
import '../models/brand.dart';
import '../services/product_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _service = ProductService();

  List<Product> _products = [];
  List<Brand> _brands = [];
  bool _isLoading = false;
  double _maxPrice = 1000;

  List<Product> get products => _products;
  List<Brand> get brands => _brands;
  bool get isLoading => _isLoading;
  double get maxPrice => _maxPrice;

  Future<void> loadProducts({bool force = false}) async {
    if (!force && _products.isNotEmpty) {
      logger.d('ProductProvider: Data already in memory, skipping fetch.');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      logger.i('ProductProvider: Fetching products and brands from network...');

      final results = await Future.wait([
        _service.fetchProducts(),
        _service.getAllBrands(),
      ]);

      _products = results[0] as List<Product>;
      _brands = results[1] as List<Brand>;

      double foundMax = 0;
      for (var p in _products) {
        for (var v in p.variants) {
          if (v.price > foundMax) foundMax = v.price;
        }
      }
      _maxPrice = foundMax > 0 ? foundMax : 1000;

      logger.i(
        'ProductProvider: Successfully loaded ${_products.length} products.',
      );
    } catch (e) {
      logger.e('ProductProvider: Error loading products', error: e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Product? getProductFromCache(int id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
