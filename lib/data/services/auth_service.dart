import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AuthService {
  String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8081';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8081';
    } else {
      return 'http://localhost:8081';
    }
  }

  Future<String> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/auth/login');

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
      if (e.toString().contains('Exception:')) rethrow;
      throw Exception('Не удалось подключиться к серверу: $e');
    }
  }

  Future<String> register(String email, String password, String name) async {
    final url = Uri.parse('$_baseUrl/auth/register');

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
      if (e.toString().contains('Exception:')) rethrow;
      throw Exception('Не удалось подключиться к серверу: $e');
    }
  }

  Future<void> changePassword(
    String token,
    String oldPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    final url = Uri.parse('$_baseUrl/auth/change/password');

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
      if (e.toString().contains('Exception:')) rethrow;
      throw Exception('Не удалось сменить пароль: $e');
    }
  }
}