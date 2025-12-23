import 'package:flutter_test/flutter_test.dart';
import 'package:tailornado/data/providers/cart_provider.dart';
import 'package:tailornado/data/models/product.dart';
import 'package:tailornado/data/models/product_variant.dart';
import 'package:tailornado/data/models/brand.dart';
import 'package:tailornado/data/models/category.dart';

void main() {
  group('CartProvider Tests', () {
    late CartProvider cartProvider;
    late Product mockProduct;
    late ProductVariant mockVariant;

    setUp(() {
      cartProvider = CartProvider();

      mockVariant = ProductVariant(
        id: 1,
        sku: 'test',
        price: 100.0,
        sizes: 'M',
        colors: 'Red',
        stock: 10,
        imageURLs: [],
        barcode: '',
        dimensions: '',
        discount: 0,
        isActive: true,
        minOrder: 1,
        rating: 5,
        reviewCount: 1,
        reservedStock: 0,
        material: 'cotton',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      mockProduct = Product(
        id: 1,
        name: 'Test Product',
        description: '',
        imageURLs: [],
        brand: Brand(
          id: 1,
          name: 'Nike',
          description: '',
          logo: '',
          videoUrl: '',
        ),
        category: Category(id: 1, name: 'Shoes', description: '', imageUrl: ''),
        variants: [mockVariant],
        isActive: true,
        videoURLs: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    test('Добавление товара в корзину увеличивает счетчик', () {
      cartProvider.addToCart(mockProduct, mockVariant);
      expect(cartProvider.itemCount, 1);
      expect(cartProvider.totalAmount, 100.0);
    });

    test(
      'Повторное добавление того же товара увеличивает количество (quantity)',
      () {
        cartProvider.addToCart(mockProduct, mockVariant);
        cartProvider.addToCart(mockProduct, mockVariant);

        expect(cartProvider.itemCount, 1);
        expect(cartProvider.cartItems[0].quantity, 2);
        expect(cartProvider.totalAmount, 200.0);
      },
    );

    test('Удаление товара полностью очищает его из корзины', () {
      cartProvider.addToCart(mockProduct, mockVariant);
      final cartId = '${mockProduct.id}_${mockVariant.id}';
      cartProvider.removeFromCart(cartId);
      expect(cartProvider.itemCount, 0);
    });
  });
}
