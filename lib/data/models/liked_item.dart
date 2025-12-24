import 'product.dart';
import 'product_variant.dart';

class LikedItem {
  final int favEntryId;
  final Product product;
  final ProductVariant selectedVariant;

  LikedItem({
    required this.favEntryId,
    required this.product,
    required this.selectedVariant,
  });
}