import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/brand.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../models/product_variant.dart';

class ProductService {
  
  static Map<int, String> _brandsCache = {};

  Future<List<Brand>> getAllBrands() async {
    final uri = Uri.parse(ApiConfig.brandsEndpoint);
    print('GET BRANDS URL: $uri');

    try {
      final response = await http.get(uri);
      
      print('GET BRANDS STATUS: ${response.statusCode}');
      print('GET BRANDS BODY: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> brandsJson = json.decode(utf8.decode(response.bodyBytes));
        List<Brand> brands = brandsJson.map((json) => Brand.fromJson(json)).toList();
        
        for (var b in brands) {
          _brandsCache[b.id] = b.name;
        }
        
        print('SUCCESS: Parsed ${brands.length} brands');
        return brands;
      } else {
        print('Failed to load brands: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching brands list: $e');
      return [];
    }
  }



  Future<List<Product>> fetchProducts() async {
    await _ensureBrandsLoaded();

    final rawList = await _performSearchQuery();
    
    return rawList.where((p) => p.variants.isNotEmpty).toList();
  }

  Future<List<Product>> _performSearchQuery() async {
    const String query = r'''
      query Search($in: SearchInput!) {
        searchProducts(input: $in) {
          products {
            id
            name
            description
            material
            category_id
            brand_id
            is_active
            image_urls
            video_urls
            variants {
              variant_id
              sku
              price
              sizes
              colors
              stock
              rating
              image_urls
            }
          }
        }
      }
    ''';

    final Map<String, dynamic> variables = {
      "in": {
        "limit": 100,
        "page": 1
      }
    };

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.graphqlUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'query': query,
          'variables': variables,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(utf8.decode(response.bodyBytes));
        
        if (jsonResponse['errors'] != null) {
          print('GraphQL Errors: ${jsonResponse['errors']}');
          return [];
        }

        final data = jsonResponse['data'];
        if (data == null || data['searchProducts'] == null) {
          return [];
        }
        
        final List<dynamic> productsJson = data['searchProducts']['products'] ?? [];
        return productsJson.map((jsonItem) => _mapGraphqlProduct(jsonItem)).toList();
      } else {
        print('Search Request failed: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching products search: $e');
      return [];
    }
  }

  Future<void> _ensureBrandsLoaded() async {
    if (_brandsCache.isNotEmpty) return;
    await getAllBrands();
  }

  Product _mapGraphqlProduct(Map<String, dynamic> json) {
    int productId = 0;
    if (json['id'] is int) {
      productId = json['id'];
    } else if (json['id'] is String) {
      productId = int.tryParse(json['id']) ?? 0;
    }

    List<String> productImages = [];
    if (json['image_urls'] != null && json['image_urls'] is List) {
      productImages = (json['image_urls'] as List).map((e) => e.toString()).toList();
    }

    var variantList = json['variants'] as List? ?? [];
    List<ProductVariant> variants = variantList.map((v) {
      int vId = 0;
      if (v['variant_id'] != null) {
         vId = v['variant_id'] is int ? v['variant_id'] : int.tryParse(v['variant_id'].toString()) ?? 0;
      }

      List<String> variantImages = [];
      if (v['image_urls'] != null && v['image_urls'] is List) {
        variantImages = (v['image_urls'] as List).map((e) => e.toString()).toList();
      }
      if (variantImages.isEmpty) {
        variantImages = List.from(productImages);
      }

      String colorStr = v['colors']?.toString() ?? '';
      colorStr = colorStr.replaceAll('[', '').replaceAll(']', '').replaceAll('"', '');
      if (colorStr.isEmpty) colorStr = 'Стандарт';

      return ProductVariant(
        id: vId, 
        sku: v['sku']?.toString() ?? '',
        price: (v['price'] ?? 0).toDouble(),
        sizes: v['sizes']?.toString() ?? '',
        colors: colorStr,
        stock: (v['stock'] ?? 0) is int ? v['stock'] : 0,
        imageURLs: variantImages,
        barcode: '',
        dimensions: '',
        discount: 0.0,
        isActive: true,
        minOrder: 1,
        rating: (v['rating'] ?? 0).toDouble(),
        reviewCount: 0,
        reservedStock: 0,
        material: json['material']?.toString() ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }).toList();

    final brandId = json['brand_id'] is int ? json['brand_id'] : 0;
    final categoryId = json['category_id'] is int ? json['category_id'] : 0;
    String brandName = _brandsCache[brandId] ?? 'Бренд #$brandId';

    List<String> videoURLs = [];
    if (json['video_urls'] != null && json['video_urls'] is List) {
      videoURLs = (json['video_urls'] as List).map((e) => e.toString()).toList();
    }

    return Product(
      id: productId,
      name: json['name'] ?? 'Без названия',
      description: json['description'] ?? '',
      imageURLs: productImages,
      brand: Brand(
        id: brandId,
        name: brandName,
        description: '',
        logo: '',
        videoUrl: '',
      ),
      category: Category(
        id: categoryId,
        name: 'Категория #$categoryId',
        description: '',
        imageUrl: '',
      ),
      variants: variants,
      isActive: json['is_active'] ?? true,
      videoURLs: videoURLs,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}