import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../core/utils/app_logger.dart';
import '../config/api_config.dart';
import '../models/brand.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../models/product_variant.dart';

class ProductService {
  final Map<int, String> _brandsCache = {};

  Future<String?> uploadImage(
    Uint8List bytes,
    String fileName,
    String token,
  ) async {
    try {
      final uri = Uri.parse(ApiConfig.mediaUploadEndpoint);
      var request = http.MultipartRequest('POST', uri);

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName,
          contentType: MediaType.parse(
            fileName.toLowerCase().endsWith('.png')
                ? 'image/png'
                : 'image/jpeg',
          ),
        ),
      );

      request.headers['Authorization'] = 'Bearer $token';

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        logger.i(
          'ProductService: Image uploaded successfully to ${data['url']}',
        );
        return data['url'];
      } else {
        logger.w(
          'ProductService: Upload failed with status ${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      logger.e('ProductService: Upload error', error: e);
      return null;
    }
  }

  Future<bool> createProduct(
    Map<String, dynamic> productData,
    String token,
  ) async {
    final url = Uri.parse('http://localhost:8081/products');
    logger.i('ProductService: Sending product data to 8081');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(productData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        logger.i('ProductService: Product created successfully');
        return true;
      } else {
        logger.e(
          'ProductService: Failed to create product. Body: ${response.body}',
        );
        return false;
      }
    } catch (e) {
      logger.e('ProductService: Exception in createProduct', error: e);
      return false;
    }
  }

  Future<List<Brand>> getAllBrands() async {
    final uri = Uri.parse(ApiConfig.brandsEndpoint);
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> brandsJson = json.decode(
          utf8.decode(response.bodyBytes),
        );
        List<Brand> brands = brandsJson
            .map((json) => Brand.fromJson(json))
            .toList();
        for (var b in brands) {
          _brandsCache[b.id] = b.name;
        }
        return brands;
      }
      return [];
    } catch (e) {
      logger.e('ProductService: Error fetching brands', error: e);
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
      "in": {"limit": 100, "page": 1},
    };

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.graphqlUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'query': query, 'variables': variables}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(
          utf8.decode(response.bodyBytes),
        );
        if (jsonResponse['errors'] != null) return [];
        final data = jsonResponse['data'];
        if (data == null || data['searchProducts'] == null) return [];

        final List<dynamic> productsJson =
            data['searchProducts']['products'] ?? [];
        return productsJson
            .map((jsonItem) => _mapGraphqlProduct(jsonItem))
            .toList();
      }
      return [];
    } catch (e) {
      logger.e('ProductService: GraphQL error', error: e);
      return [];
    }
  }

  Future<void> _ensureBrandsLoaded() async {
    if (_brandsCache.isNotEmpty) return;
    await getAllBrands();
  }

  Product _mapGraphqlProduct(Map<String, dynamic> json) {
    int productId = json['id'] is int
        ? json['id']
        : int.tryParse(json['id'].toString()) ?? 0;
    List<String> productImages =
        (json['image_urls'] as List?)?.map((e) => e.toString()).toList() ?? [];

    var variantList = json['variants'] as List? ?? [];
    List<ProductVariant> variants = variantList.map((v) {
      int vId = v['variant_id'] is int
          ? v['variant_id']
          : int.tryParse(v['variant_id'].toString()) ?? 0;
      List<String> variantImages =
          (v['image_urls'] as List?)?.map((e) => e.toString()).toList() ?? [];
      if (variantImages.isEmpty) variantImages = List.from(productImages);

      String colorStr = v['colors']?.toString() ?? 'Стандарт';
      colorStr = colorStr
          .replaceAll('[', '')
          .replaceAll(']', '')
          .replaceAll('"', '');

      return ProductVariant(
        id: vId,
        sku: v['sku']?.toString() ?? '',
        price: (v['price'] ?? 0).toDouble(),
        sizes: v['sizes']?.toString() ?? '',
        colors: colorStr,
        stock: v['stock'] is int ? v['stock'] : 0,
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

    return Product(
      id: productId,
      name: json['name'] ?? 'Без названия',
      description: json['description'] ?? '',
      imageURLs: productImages,
      brand: Brand(
        id: brandId,
        name: _brandsCache[brandId] ?? 'Бренд #$brandId',
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
      videoURLs:
          (json['video_urls'] as List?)?.map((e) => e.toString()).toList() ??
          [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
