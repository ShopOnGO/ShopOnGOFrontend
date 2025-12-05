import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/brand.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../models/product_variant.dart';

class ProductService {
  
  static Map<int, String> _brandsCache = {};

  Future<List<Product>> fetchProducts() async {
    final results = await Future.wait([
      _performSearchQuery(),
      _ensureBrandsLoaded(),
    ]);

    final rawList = results[0] as List<Product>;
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
            category_id
            brand_id
            variants {
              variant_id
              sku
              price
              sizes
              colors
              stock
              rating
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
    try {
      final response = await http.get(Uri.parse(ApiConfig.brandsEndpoint));
      if (response.statusCode == 200) {
        final List<dynamic> brandsJson = json.decode(utf8.decode(response.bodyBytes));
        for (var b in brandsJson) {
          if (b['id'] != null && b['name'] != null) {
            _brandsCache[b['id']] = b['name'];
          }
        }
        print('SUCCESS: Loaded ${_brandsCache.length} brands.');
      }
    } catch (e) {
      print('Error fetching brands: $e');
    }
  }

  Product _mapGraphqlProduct(Map<String, dynamic> json) {
    var variantList = json['variants'] as List? ?? [];
    
    int productId = 0;
    if (json['id'] is int) {
      productId = json['id'];
    } else if (json['id'] is String) {
      productId = int.tryParse(json['id']) ?? 0;
    }

    List<ProductVariant> variants = variantList.map((v) {
      int vId = 0;
      if (v['variant_id'] != null) {
        if (v['variant_id'] is int) {
          vId = v['variant_id'];
        } else if (v['variant_id'] is String) {
          vId = int.tryParse(v['variant_id']) ?? 0;
        }
      }

      String seed = vId > 0 ? vId.toString() : productId.toString();
      List<String> images = ['https://picsum.photos/seed/$seed/400/600'];

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
        imageURLs: images, 
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

    return Product(
      id: productId,
      name: json['name'] ?? 'Без названия',
      description: json['description'] ?? '',
      imageURLs: variants.isNotEmpty ? variants.first.imageURLs : [],
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
      isActive: true,
      videoURLs: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}