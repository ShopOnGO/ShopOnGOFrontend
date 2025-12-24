class ProductVariant {
  final int id;
  final String sku;
  final double price;
  final String sizes;
  final String colors;
  final int stock;
  final List<String> imageURLs;
  final String barcode;
  final String dimensions;
  final double discount;
  final bool isActive;
  final int minOrder;
  final double rating;
  final int reviewCount;
  final int reservedStock;
  final String material;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  ProductVariant({
    required this.id,
    required this.sku,
    required this.price,
    required this.sizes,
    required this.colors,
    required this.stock,
    required this.imageURLs,
    required this.barcode,
    required this.dimensions,
    required this.discount,
    required this.isActive,
    required this.minOrder,
    required this.rating,
    required this.reviewCount,
    required this.reservedStock,
    required this.material,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    var rawImages =
        json['images'] ?? json['imageURLs'] ?? json['ImageURLs'] ?? [];
    List<String> images = (rawImages as List).map((i) => i.toString()).toList();

    double parseDouble(dynamic v) {
      if (v is num) return v.toDouble();
      return double.tryParse(v?.toString() ?? '0') ?? 0.0;
    }

    return ProductVariant(
      id: json['ID'] ?? json['id'] ?? 0,
      sku: json['SKU'] ?? json['sku'] ?? '',
      price: parseDouble(json['Price'] ?? json['price']),
      sizes: json['sizes']?.toString() ?? '',
      colors: json['colors']?.toString() ?? 'Стандарт',
      stock: json['Stock'] ?? json['stock'] ?? 0,
      imageURLs: images,
      barcode: json['Barcode'] ?? json['barcode'] ?? '',
      dimensions: json['Dimensions'] ?? json['dimensions'] ?? '',
      discount: parseDouble(json['Discount'] ?? json['discount']),
      isActive: json['IsActive'] ?? json['is_active'] ?? true,
      minOrder: json['MinOrder'] ?? json['minOrder'] ?? 1,
      rating: parseDouble(json['Rating'] ?? json['rating']),
      reviewCount: json['ReviewCount'] ?? json['reviewCount'] ?? 0,
      reservedStock: json['ReservedStock'] ?? json['reservedStock'] ?? 0,
      material: json['material']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['CreatedAt'] ?? json['createdAt'] ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['UpdatedAt'] ?? json['updatedAt'] ?? '') ??
          DateTime.now(),
    );
  }
}
