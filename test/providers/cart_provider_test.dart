import 'package:flutter_test/flutter_test.dart';
import 'package:tailornado/data/providers/cart_provider.dart';
import 'package:tailornado/data/models/product.dart';
import 'package:tailornado/data/models/product_variant.dart';
import 'package:tailornado/data/models/brand.dart';
import 'package:tailornado/data/models/category.dart';
import 'package:tailornado/data/services/cart_service.dart';

class FakeCartService extends Fake implements CartService {
  @override
  Future<bool> addCartItem(int v, int q, String t) async => true;
  @override
  Future<bool> updateCartItem(int v, int q, String t) async => true;
  @override
  Future<bool> deleteCartItem(int v, String t) async => true;
}

void main() {
  group('CartProvider Tests', () {
    late CartProvider cartProvider;
    late Product mockProduct;
    late ProductVariant mockVariant;
    const String dummyToken = "test_token";

    setUp(() {
      cartProvider = CartProvider(cartService: FakeCartService());

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

    test('Добавление товара в корзину увеличивает счетчик', () async {
      await cartProvider.addToCart(mockProduct, mockVariant, dummyToken);
      expect(cartProvider.itemCount, 1);
      expect(cartProvider.totalAmount, 100.0);
    });

    test('Повторное добавление увеличивает количество', () async {
      await cartProvider.addToCart(mockProduct, mockVariant, dummyToken);
      await cartProvider.addToCart(mockProduct, mockVariant, dummyToken);

      expect(cartProvider.itemCount, 1);
      expect(cartProvider.cartItems[0].quantity, 2);
      expect(cartProvider.totalAmount, 200.0);
    });

    test('Удаление товара полностью очищает его из корзины', () async {
      await cartProvider.addToCart(mockProduct, mockVariant, dummyToken);
      final cartId = '${mockProduct.id}_${mockVariant.id}';
      await cartProvider.removeFromCart(cartId, dummyToken);
      expect(cartProvider.itemCount, 0);
    });
  });
}
