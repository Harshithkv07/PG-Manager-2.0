import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../../core/utils/locator.dart';

class AuthService {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyToken = 'jwt_token';
  final _storage = const FlutterSecureStorage();

  // Login via API
  Future<bool> login(String username, String password) async {
    try {
      final response = await locator<Dio>().post(
        '/login',
        data: FormData.fromMap({
          'username': username,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final token = response.data['access_token'];
        await _storage.write(key: _keyToken, value: token);
        await _storage.write(key: _keyIsLoggedIn, value: 'true');
        return true;
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  // Logout
  Future<void> logout() async {
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
