// lib/screens/login/services/login_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:localoop/services/network_helper.dart';
import '../model/login_request.dart';
import '../model/login_response.dart';

class LoginService {
  final _storage = const FlutterSecureStorage();

  /// Login with email & password
  Future<LoginResponse> login(LoginRequest request) async {
    final uri = NetworkHelper.buildUri('/auth/login');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final loginResponse = LoginResponse.fromJson(data);

      // Store token securely
      await _storage.write(key: 'auth_token', value: loginResponse.accessToken);

      return loginResponse;
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  /// Get stored token
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  /// Logout
  Future<void> logout() async {
    await _storage.deleteAll();
  }
}
