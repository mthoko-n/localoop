import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _storage = const FlutterSecureStorage();
  final _authStateController = StreamController<bool>.broadcast();

  Stream<bool> get authStateStream => _authStateController.stream;
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

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
        }
      } catch (_) {
        isValid = false;
      }
    }

    if (!isValid) {
      await _storage.delete(key: 'auth_token');
    }

    _updateAuthState(isValid);
  }

  void _updateAuthState(bool isAuthenticated) {
    _isAuthenticated = isAuthenticated;
    _authStateController.add(isAuthenticated);
  }

  Future<void> login(String token) async {
    await _storage.write(key: 'auth_token', value: token);
    _updateAuthState(true);
  }

  // Overloaded method for when you already have the token stored
  Future<void> loginSuccess() async {
    _updateAuthState(true);
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    _updateAuthState(false);
  }

  // This is what your ApiClient will call
  void notifyAuthFailure() {
    logout(); // This will trigger the stream and update UI
  }

  // ✅ New: Decode JWT and return the user id ("sub" or "user_id")
// Replace your getCurrentUserId method with this:

Future<String?> getCurrentUserId() async {
  final token = await _storage.read(key: 'auth_token');
  print("Token from storage: $token"); // <-- print the raw token
  if (token == null) return null;

  try {
    final parts = token.split('.');
    if (parts.length != 3) return null;

    final payload = json.decode(
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))
    ) as Map<String, dynamic>;

    //print("Decoded payload: $payload"); // <-- print the decoded payload

    // Use user_id first (the actual MongoDB ObjectId), fallback to sub if needed
    final userId = payload['user_id']?.toString() ?? payload['sub']?.toString();
    //print("Current user ID: $userId"); // <-- print the final user ID

    return userId;
  } catch (e) {
    print("Error decoding token: $e"); // <-- print any decoding errors
    return null;
  }
}


  void dispose() {
    _authStateController.close();
  }
}
