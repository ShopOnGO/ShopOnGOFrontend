import 'package:flutter/material.dart';
import '../../core/utils/app_logger.dart';
import '../models/product.dart';

class ViewHistoryProvider with ChangeNotifier {
  final int _maxHistorySize = 20;
  final List<Product> _history = [];

  List<Product> get viewedProducts => _history;

  void addToHistory(Product product) {
    logger.d('History: Viewed product ${product.name} (ID: ${product.id})');
    
    _history.removeWhere((p) => p.id == product.id);
    _history.insert(0, product);

    if (_history.length > _maxHistorySize) {
      logger.d('History: Limit reached, removing oldest');
      _history.removeLast();
    }

    notifyListeners();
  }
}