import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../core/utils/app_logger.dart';
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
    logger.d('Loading Auth Data from SharedPreferences...');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    
    final savedName = prefs.getString('user_name');
    final savedEmail = prefs.getString('user_email');
    
    if (token != null) {
      if (!JwtDecoder.isExpired(token)) {
        logger.i('Valid token found in storage.');
        _token = token;
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

        if (!decodedToken.containsKey('email') && savedEmail != null) {
          decodedToken['email'] = savedEmail;
        }

        _user = User.fromTokenPayload(decodedToken, name: savedName);
        logger.d('User initialized: ${_user?.email} (${_user?.role})');
        notifyListeners();
      } else {
        logger.w('Stored token expired. Logging out.');
        logout();
      }
    } else {
      logger.d('No token found in storage.');
    }
  }

  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      final responseData = await _authService.login(email, password);
      final token = responseData['token'];
      final name = responseData['name']; 

      logger.i('Login success for $email. Initializing session.');
      await _saveAuthData(token, email: email, name: name);
    } catch (e, stackTrace) {
      logger.e('Login error in AuthProvider', error: e, stackTrace: stackTrace);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(String email, String password, String name) async {
    _setLoading(true);
    try {
      final responseData = await _authService.register(email, password, name);
      final token = responseData['token'];
      final returnedName = responseData['name'];

      logger.i('Registration success for $email.');
      await _saveAuthData(token, email: email, name: returnedName ?? name);
    } catch (e, stackTrace) {
      logger.e('Registration error in AuthProvider', error: e, stackTrace: stackTrace);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> changePassword(
    String oldPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    if (_token == null) throw Exception('Вы не авторизованы');

    if (newPassword != confirmPassword) {
      throw Exception('Новые пароли не совпадают');
    }

    _setLoading(true);
    try {
      await _authService.changePassword(_token!, oldPassword, newPassword);
      logger.i('Password change request successful');
    } catch (e) {
      logger.w('Password change failed: $e');
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
    logger.d('Saving Auth Data. Payload: $decodedToken');

    if (email != null) decodedToken['email'] = email;
    
    String? finalName = name ?? 
                        decodedToken['name'] ?? 
                        decodedToken['username'] ?? 
                        prefs.getString('user_name');

    _user = User.fromTokenPayload(decodedToken, name: finalName);

    await prefs.setString('jwt_token', token);
    
    if (_user != null) {
      await prefs.setString('user_id', _user!.id);
    }

    if (decodedToken['email'] != null) {
      await prefs.setString('user_email', decodedToken['email']);
    }
    
    if (finalName != null) {
      await prefs.setString('user_name', finalName);
    }

    logger.i('Session saved for user: ${_user?.email}');
    notifyListeners();
  }

  Future<void> logout() async {
    logger.i('User logout initiated');
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