import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _storage = const FlutterSecureStorage();
  final _authStateController = StreamController<bool>.broadcast();
  
  String? _baseUrl; // Dynamic base URL

  Stream<bool> get authStateStream => _authStateController.stream;
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  // Set the base URL (called from main.dart)
  void setBaseUrl(String baseUrl) {
    _baseUrl = baseUrl;
    print('AuthService: Base URL set to $_baseUrl');
  }

  Future<void> initialize() async {
    await _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final token = await _storage.read(key: 'auth_token');
    bool isValid = false;

    if (token != null) {
      try {
        final parts = token.split('.');
        if (parts.length == 3) {
          final payload = json.decode(
            utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))
          );
          final exp = payload['exp'] as int;
          isValid = DateTime.now().millisecondsSinceEpoch ~/ 1000 < exp;
          
          // If token is close to expiry (within 5 minutes), try to refresh
          final timeToExpiry = exp - (DateTime.now().millisecondsSinceEpoch ~/ 1000);
          if (isValid && timeToExpiry < 300) { // 5 minutes
            await _attemptTokenRefresh();
            // Re-check after refresh attempt
            final newToken = await _storage.read(key: 'auth_token');
            isValid = newToken != null && _isTokenValid(newToken);
          }
        }
      } catch (_) {
        isValid = false;
      }
    }

    if (!isValid) {
      await _clearTokens();
    }

    _updateAuthState(isValid);
  }

  bool _isTokenValid(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;
      
      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))
      );
      final exp = payload['exp'] as int;
      return DateTime.now().millisecondsSinceEpoch ~/ 1000 < exp;
    } catch (_) {
      return false;
    }
  }

  void _updateAuthState(bool isAuthenticated) {
    _isAuthenticated = isAuthenticated;
    _authStateController.add(isAuthenticated);
  }

  Future<void> login(Map<String, dynamic> tokenResponse) async {
    await _storage.write(key: 'auth_token', value: tokenResponse['access_token']);
    await _storage.write(key: 'refresh_token', value: tokenResponse['refresh_token']);
    _updateAuthState(true);
  }

  Future<void> loginSuccess() async {
    _updateAuthState(true);
  }

  Future<void> logout() async {
    // Try to revoke refresh token on server
    await _revokeRefreshToken();
    await _clearTokens();
    _updateAuthState(false);
  }

  Future<void> logoutAllDevices() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token != null && _baseUrl != null) {
        await http.post(
          Uri.parse('$_baseUrl/auth/logout-all'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }
    } catch (e) {
      print('Error logging out from all devices: $e');
    } finally {
      await _clearTokens();
      _updateAuthState(false);
    }
  }

  Future<void> _revokeRefreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken != null && _baseUrl != null) {
        await http.post(
          Uri.parse('$_baseUrl/auth/logout'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'refresh_token': refreshToken}),
        );
      }
    } catch (e) {
      print('Error revoking refresh token: $e');
    }
  }

  Future<void> _clearTokens() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'refresh_token');
  }

  // This is what your ApiClient will call when it receives a 401
  Future<bool> notifyAuthFailure() async {
    // Try to refresh the token first
    final refreshed = await _attemptTokenRefresh();
    if (!refreshed) {
      // If refresh fails, logout
      await logout();
      return false;
    }
    return true;
  }

  Future<bool> _attemptTokenRefresh() async {
    try {
      if (_baseUrl == null) {
        print('AuthService: Base URL not set - cannot refresh token');
        return false;
      }

      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) {
        print('AuthService: No refresh token found');
        return false;
      }

      print('AuthService: Attempting token refresh to $_baseUrl/auth/refresh');

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refresh_token': refreshToken}),
      );

      print('AuthService: Refresh response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final tokenData = json.decode(response.body);
        await _storage.write(key: 'auth_token', value: tokenData['access_token']);
        await _storage.write(key: 'refresh_token', value: tokenData['refresh_token']);
        print('AuthService: Token refresh successful');
        return true;
      } else {
        print('AuthService: Token refresh failed - ${response.statusCode}: ${response.body}');
        // Refresh failed, clear tokens
        await _clearTokens();
        return false;
      }
    } catch (e) {
      print('AuthService: Token refresh error: $e');
      await _clearTokens();
      return false;
    }
  }

  Future<String?> getValidToken() async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) return null;

    // Check if token is expired
    if (!_isTokenValid(token)) {
      // Token is expired - try to refresh
      final refreshed = await _attemptTokenRefresh();
      if (refreshed) {
        return await _storage.read(key: 'auth_token');
      } else {
        return null; // Refresh failed
      }
    }

    // Token is valid - check if close to expiry (within 5 minutes)
    try {
      final parts = token.split('.');
      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))
      );
      final exp = payload['exp'] as int;
      final timeToExpiry = exp - (DateTime.now().millisecondsSinceEpoch ~/ 1000);
      
      if (timeToExpiry < 300) { // 5 minutes
        await _attemptTokenRefresh();
        return await _storage.read(key: 'auth_token');
      }
    } catch (_) {
      // If decoding fails, try refresh anyway
      await _attemptTokenRefresh();
      return await _storage.read(key: 'auth_token');
    }

    return token; // Token is valid and not near expiry
  }

  Future<String?> getCurrentUserId() async {
    final token = await getValidToken(); // This ensures we get a valid, fresh token
    if (token == null) return null;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))
      ) as Map<String, dynamic>;

      // Use user_id first (the actual MongoDB ObjectId), fallback to sub if needed
      final userId = payload['user_id']?.toString() ?? payload['sub']?.toString();
      return userId;
    } catch (e) {
      print("Error decoding token: $e");
      return null;
    }
  }

  void dispose() {
    _authStateController.close();
  }
}