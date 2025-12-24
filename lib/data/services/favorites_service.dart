import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/utils/app_logger.dart';
import '../config/api_config.dart';

class FavoritesService {
  Future<List<dynamic>> getFavorites(String token) async {
    final url = Uri.parse(ApiConfig.favoritesEndpoint);
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['favorites'] ?? [];
      } else {
        logger.e(
          'FavoritesService: Failed to load. Status: ${response.statusCode}',
        );
        return [];
      }
    } catch (e) {
      logger.e('FavoritesService: Error getting favorites', error: e);
      return [];
    }
  }

  Future<bool> addFavorite(int variantId, String token) async {
    final url = Uri.parse('${ApiConfig.favoritesEndpoint}$variantId');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      logger.e('FavoritesService: Error adding', error: e);
      return false;
    }
  }

  Future<bool> deleteFavorite(int favEntryId, String token) async {
    final url = Uri.parse('${ApiConfig.favoritesEndpoint}$favEntryId');
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
      logger.e('FavoritesService: Error deleting', error: e);
      return false;
    }
  }
}
