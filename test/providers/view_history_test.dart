import 'package:flutter_test/flutter_test.dart';
import 'package:tailornado/data/providers/view_history_provider.dart';
import 'package:tailornado/data/models/product.dart';
import 'package:tailornado/data/models/brand.dart';
import 'package:tailornado/data/models/category.dart';

Product createFakeProduct(int id) {
  return Product(
    id: id,
    name: 'Product $id',
    description: '',
    imageURLs: [],
    brand: Brand(id: 1, name: 'Brand', description: '', logo: '', videoUrl: ''),
    category: Category(id: 1, name: 'Category', description: '', imageUrl: ''),
    variants: [],
    isActive: true,
    videoURLs: [],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

void main() {
  group('ViewHistoryProvider Tests', () {
    test('История не должна превышать 20 элементов', () {
      final history = ViewHistoryProvider();

      for (int i = 1; i <= 25; i++) {
        history.addToHistory(createFakeProduct(i));
      }

      expect(history.viewedProducts.length, 20);
      expect(history.viewedProducts.first.id, 25);
      expect(history.viewedProducts.any((p) => p.id == 1), false);
    });

    test('Повторный просмотр товара перемещает его в начало списка', () {
      final history = ViewHistoryProvider();
      final p1 = createFakeProduct(1);
      final p2 = createFakeProduct(2);

      history.addToHistory(p1);
      history.addToHistory(p2);
      expect(history.viewedProducts.first.id, 2);

      history.addToHistory(p1);
      expect(history.viewedProducts.first.id, 1);
      expect(history.viewedProducts.length, 2);
    });
  });
}