import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyToken = 'jwt_token';
  final _storage = const FlutterSecureStorage();
  final _supabase = Supabase.instance.client;

  // Login
  Future<bool> login(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(email: email, password: password);
      if (response.session != null) {
        await _storage.write(key: _keyToken, value: response.session!.accessToken);
        await _storage.write(key: _keyIsLoggedIn, value: 'true');
        return true;
      }
      return false;
    } catch (e) {
      print('LOGIN ERROR: $e');
      return false;
    }
  }

  // Register
  Future<bool> register(String email, String password, String pgName) async {
    try {
      final response = await _supabase.auth.signUp(email: email, password: password);
      if (response.user != null) {
        await _supabase.rpc('create_tenant', params: {'new_pg_name': pgName});
        await _storage.write(key: _keyToken, value: response.session?.accessToken ?? 'mock_token_string');
        await _storage.write(key: _keyIsLoggedIn, value: 'true');
        return true;
      }
      return false;
    } catch (e) {
      print('REGISTER ERROR: $e');
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _supabase.auth.signOut();
    await _storage.delete(key: _keyToken);
    await _storage.write(key: _keyIsLoggedIn, value: 'false');
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final value = await _storage.read(key: _keyIsLoggedIn);
    return value == 'true';
  }

  // Get current JWT token
  Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }
}
