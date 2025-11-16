import 'package:flutter/material.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;
  bool get isAuthenticated => _user != null;

  void login() {
    _user = User(
      id: '1',
      name: 'Имя Фамилия',
      email: 'email@example.com',
      avatarUrl: '',
    );
    notifyListeners();
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}