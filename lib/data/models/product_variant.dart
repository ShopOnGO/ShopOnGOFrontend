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
    var imageList = json['imageURLs'] as List? ?? [];
    List<String> images = imageList.map((i) => i.toString()).toList();

    DateTime createdAt = DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now();
    DateTime updatedAt = DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now();

    DateTime? deletedAt;
    if (json['deletedAt'] != null && json['deletedAt'] is Map) {
       if (json['deletedAt']['valid'] == true) {
         deletedAt = DateTime.tryParse(json['deletedAt']['time'] ?? '');
       }
    } else if (json['deletedAt'] != null && json['deletedAt'] is String) {
       deletedAt = DateTime.tryParse(json['deletedAt']);
    }

    return ProductVariant(
      id: json['id'] ?? 0,
      sku: json['sku'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      sizes: json['sizes'] ?? '',
      colors: json['colors'] ?? '',
      stock: json['stock'] ?? 0,
      imageURLs: images,
      barcode: json['barcode'] ?? '',
      dimensions: json['dimensions'] ?? '',
      discount: (json['discount'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? true,
      minOrder: json['minOrder'] ?? 1,
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      reservedStock: json['reservedStock'] ?? 0,
      material: json['material'] ?? '',
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }
}