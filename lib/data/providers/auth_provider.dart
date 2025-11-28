import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  String? _token;
  bool _isLoading = false;

  User? get user => _user;
  bool get isAuthenticated => _token != null && !JwtDecoder.isExpired(_token!);
  bool get isLoading => _isLoading;
  String? get token => _token;

  AuthProvider() {
    _loadUserFromStorage();
  }

  Future<void> _loadUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    
    final savedName = prefs.getString('user_name');
    final savedEmail = prefs.getString('user_email');
    
    if (token != null && !JwtDecoder.isExpired(token)) {
      _token = token;
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

      if (!decodedToken.containsKey('email') && savedEmail != null) {
        decodedToken['email'] = savedEmail;
      }

      _user = User.fromTokenPayload(decodedToken, name: savedName);
      notifyListeners();
    } else {
      if (token != null) logout();
    }
  }

  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      final token = await _authService.login(email, password);
      await _saveAuthData(token, email: email);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(String email, String password, String name) async {
    _setLoading(true);
    try {
      final token = await _authService.register(email, password, name);
      await _saveAuthData(token, email: email, name: name);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword, String confirmPassword) async {
    if (_token == null) throw Exception('Вы не авторизованы');
    
    _setLoading(true);
    try {
      await _authService.changePassword(_token!, oldPassword, newPassword, confirmPassword);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _saveAuthData(
    String token, {
    String? email,
    String? name,
  }) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    
    if (email != null) decodedToken['email'] = email;
    
    String? finalName = decodedToken['name'] ?? decodedToken['username'] ?? name ?? prefs.getString('user_name');

    _user = User.fromTokenPayload(decodedToken, name: finalName);

    await prefs.setString('jwt_token', token);
    
    if (_user != null) {
      await prefs.setString('user_id', _user!.id);
    }

    if (decodedToken['email'] != null) {
      await prefs.setString('user_email', decodedToken['email']);
    }
    
    if (_user?.name != null) {
      await prefs.setString('user_name', _user!.name!);
    }

    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_email');
    await prefs.remove('user_name');
    await prefs.remove('user_id');
    
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}