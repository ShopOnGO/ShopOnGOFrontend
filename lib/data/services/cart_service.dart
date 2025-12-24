import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/utils/app_logger.dart';
import '../config/api_config.dart';

class CartService {
  Future<Map<String, dynamic>?> getCart(String token) async {
    final url = Uri.parse(ApiConfig.cartEndpoint);
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        logger.e('CartService: Failed to load. Status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      logger.e('CartService: Error getting cart', error: e);
      return null;
    }
  }

  Future<bool> addCartItem(int variantId, int quantity, String token) async {
    final url = Uri.parse(ApiConfig.cartItemEndpoint);
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'product_variant_id': variantId,
          'quantity': quantity,
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      logger.e('CartService: Error adding', error: e);
      return false;
    }
  }

  Future<bool> updateCartItem(int variantId, int quantity, String token) async {
    final url = Uri.parse(ApiConfig.cartItemEndpoint);
    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'product_variant_id': variantId,
          'quantity': quantity,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      logger.e('CartService: Error updating', error: e);
      return false;
    }
  }

  Future<bool> deleteCartItem(int variantId, String token) async {
    final url = Uri.parse(ApiConfig.cartItemEndpoint);
    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'product_variant_id': variantId,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      logger.e('CartService: Error deleting', error: e);
      return false;
    }
  }

  Future<bool> deleteCart(String token) async {
    final url = Uri.parse(ApiConfig.cartEndpoint);
    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      logger.e('CartService: Error clearing cart', error: e);
      return false;
    }
  }
}