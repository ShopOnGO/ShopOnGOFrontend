import 'product.dart';
import 'product_variant.dart';

class LikedItem {
  final String id;
  final Product product;
  final ProductVariant selectedVariant;

  LikedItem({
    required this.id,
    required this.product,
    required this.selectedVariant,
  });
}
