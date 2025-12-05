import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class AuthService {
  
  Future<String> login(String email, String password) async {
    final url = Uri.parse(ApiConfig.loginEndpoint);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['token'];
      } else {
        try {
          final decoded = jsonDecode(response.body);
          throw Exception(decoded['error'] ?? response.body);
        } catch (_) {
          throw Exception('Ошибка входа: ${response.body}');
        }
      }
    } catch (e) {
      throw Exception('Ошибка соединения с Auth Service: $e');
    }
  }

  Future<String> register(String email, String password, String name) async {
    final url = Uri.parse(ApiConfig.registerEndpoint);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password, 'name': name}),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['token'];
      } else {
        try {
          final decoded = jsonDecode(response.body);
          throw Exception(decoded['error'] ?? response.body);
        } catch (_) {
          throw Exception('Ошибка регистрации: ${response.body}');
        }
      }
    } catch (e) {
      throw Exception('Ошибка соединения с Auth Service: $e');
    }
  }

  /// ----------------------------
  /// 🔐 Смена пароля (исправленная)
  /// ----------------------------
  Future<void> changePassword(
    String token,
    String oldPassword,
    String newPassword,
  ) async {
    final url = Uri.parse(ApiConfig.changePasswordEndpoint);

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
        String errorMsg = response.body;
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map && decoded.containsKey('error')) {
            errorMsg = decoded['error'];
          }
        } catch (_) {}
        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception('Не удалось сменить пароль: $e');
    }
  }
}
