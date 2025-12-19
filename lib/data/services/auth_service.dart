import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/utils/app_logger.dart';
import '../config/api_config.dart';

class AuthService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse(ApiConfig.loginEndpoint);
    logger.i('AuthService: Login attempt for $email');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        logger.i('AuthService: Login success for $email');
        final data = jsonDecode(response.body);
        return {
          'token': data['token'],
          'name': data['name'], 
        };
      } else {
        logger.w('AuthService: Login failed. Status: ${response.statusCode}');
        try {
          final decoded = jsonDecode(response.body);
          throw Exception(decoded['error'] ?? response.body);
        } catch (_) {
          throw Exception('Ошибка входа: ${response.body}');
        }
      }
    } catch (e, stackTrace) {
      logger.e('AuthService: Connection Error (Login)', error: e, stackTrace: stackTrace);
      throw Exception('Ошибка соединения с Auth Service: $e');
    }
  }

  Future<Map<String, dynamic>> register(String email, String password, String name) async {
    final url = Uri.parse(ApiConfig.registerEndpoint);
    logger.i('AuthService: Registration attempt for $email');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password, 'name': name}),
      );

      if (response.statusCode == 201) {
        logger.i('AuthService: Registration success for $email');
        final data = jsonDecode(response.body);
        return {
          'token': data['token'],
          'name': data['name'] ?? name, 
        };
      } else {
        logger.w('AuthService: Registration failed. Status: ${response.statusCode}');
        try {
          final decoded = jsonDecode(response.body);
          throw Exception(decoded['error'] ?? response.body);
        } catch (_) {
          throw Exception('Ошибка регистрации: ${response.body}');
        }
      }
    } catch (e, stackTrace) {
      logger.e('AuthService: Connection Error (Register)', error: e, stackTrace: stackTrace);
      throw Exception('Ошибка соединения с Auth Service: $e');
    }
  }

  Future<void> changePassword(
    String token,
    String oldPassword,
    String newPassword,
  ) async {
    final url = Uri.parse(ApiConfig.changePasswordEndpoint);
    logger.i('AuthService: Requesting password change');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'old_password': oldPassword,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode != 200) {
        logger.w('AuthService: Password change rejected. Status: ${response.statusCode}');
        String errorMsg = response.body;
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map && decoded.containsKey('error')) {
            errorMsg = decoded['error'];
          }
        } catch (_) {}
        throw Exception(errorMsg);
      }
      logger.i('AuthService: Password changed successfully');
    } catch (e, stackTrace) {
      logger.e('AuthService: Exception during Password Change', error: e, stackTrace: stackTrace);
      throw Exception('Не удалось сменить пароль: $e');
    }
  }
}