import 'product.dart';
import 'product_variant.dart';

class CartItem {
  final String id;
  final Product product;
  final ProductVariant selectedVariant;
  int quantity;

  CartItem({
    required this.id,
    required this.product,
    required this.selectedVariant,
    this.quantity = 1,
  });
}