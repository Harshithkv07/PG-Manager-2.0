import 'package:flutter/material.dart';
import '../../data/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoggedIn = false;
  bool _isLoading = false;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Check login status on app start
  Future<void> checkLoginStatus() async {
    _setLoading(true);
    try {
      _isLoggedIn = await _authService.isLoggedIn();
    } finally {
      _setLoading(false);
    }
  }

  // Login
  Future<bool> login(String username, String password) async {
    _setLoading(true);
    try {
      final success = await _authService.login(username, password);
      
      if (success) {
        _isLoggedIn = true;
      }
      return success;
    } finally {
      _setLoading(false);
    }
  }

  // Register
  Future<bool> register(String email, String password, String pgName) async {
    _setLoading(true);
    try {
      final success = await _authService.register(email, password, pgName);
      
      if (success) {
        _isLoggedIn = true;
      }
      return success;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
    _isLoggedIn = false;
    notifyListeners();
  }
}
