import 'package:flutter_test/flutter_test.dart';
import 'package:tailornado/data/models/product.dart';

void main() {
  group('Product JSON Parsing', () {
    test('Успешный парсинг, когда deletedAt валиден', () {
      final json = {
        "id": 1,
        "name": "Test",
        "deletedAt": {"valid": true, "time": "2025-10-10T10:00:00Z"},
        "variants": [],
        "imageURLs": [],
      };

      final product = Product.fromJson(json);
      expect(product.deletedAt, isNotNull);
      expect(product.deletedAt!.year, 2025);
    });

    test('Успешный парсинг, когда deletedAt = null или invalid', () {
      final json = {
        "id": 1,
        "name": "Test",
        "deletedAt": {"valid": false, "time": ""},
        "variants": [],
      };

      final product = Product.fromJson(json);
      expect(product.deletedAt, isNull);
    });
  });
}
