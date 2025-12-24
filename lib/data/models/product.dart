import 'brand.dart';
import 'category.dart';
import 'product_variant.dart';

class Product {
  final int id;
  final String name;
  final String description;
  final List<String> imageURLs;
  final Brand brand;
  final Category category;
  final List<ProductVariant> variants;

  final bool isActive;
  final List<String> videoURLs;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.imageURLs,
    required this.brand,
    required this.category,
    required this.variants,
    required this.isActive,
    required this.videoURLs,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    var variantList = json['Variants'] as List? ?? json['variants'] as List? ?? [];
    List<ProductVariant> variants = variantList
        .map((i) => ProductVariant.fromJson(i))
        .toList();

    var imageList = json['ImageURLs'] as List? ?? json['imageURLs'] as List? ?? [];
    List<String> images = imageList.map((i) => i.toString()).toList();

    var videoList = json['VideoURLs'] as List? ?? json['videoURLs'] as List? ?? [];
    List<String> videos = videoList.map((i) => i.toString()).toList();

    DateTime createdAt = DateTime.tryParse(json['CreatedAt'] ?? json['createdAt'] ?? '') ?? DateTime.now();
    DateTime updatedAt = DateTime.tryParse(json['UpdatedAt'] ?? json['updatedAt'] ?? '') ?? DateTime.now();
    
    DateTime? deletedAt;
    var d = json['DeletedAt'] ?? json['deletedAt'];
    if (d != null && d is Map) {
      if (d['valid'] == true) {
        deletedAt = DateTime.tryParse(d['time'] ?? '');
      }
    } else if (d != null && d is String) {
      deletedAt = DateTime.tryParse(d);
    }

    return Product(
      id: json['ID'] ?? json['id'] ?? 0,
      name: json['name'] ?? 'Без названия',
      description: json['description'] ?? '',
      imageURLs: images,
      brand: json['Brand'] != null 
          ? Brand.fromJson(json['Brand']) 
          : (json['brand'] != null ? Brand.fromJson(json['brand']) : Brand(id: json['brand_id'] ?? 0, name: 'Бренд', description: '', logo: '', videoUrl: '')),
      category: json['Category'] != null 
          ? Category.fromJson(json['Category']) 
          : (json['category'] != null ? Category.fromJson(json['category']) : Category(id: json['category_id'] ?? 0, name: 'Категория', description: '', imageUrl: '')),
      variants: variants,
      isActive: json['is_active'] ?? json['IsActive'] ?? true,
      videoURLs: videos,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }
}