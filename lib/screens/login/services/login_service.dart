// lib/screens/login/services/login_service.dart
import '../../../services/api_client.dart';
import '../../../services/auth_service.dart'; 
import '../model/login_request.dart';
import '../model/login_response.dart';

class LoginService {
  final ApiClient api;

  LoginService({required this.api});

  /// Login with email & password
  Future<LoginResponse> login(LoginRequest request) async {
    final data = await api.post('/auth/login', body: request.toJson());

    final loginResponse = LoginResponse.fromJson(data);

    // Store token securely via ApiClient (keep existing behavior)
    await api.storage.write(
      key: 'auth_token',
      value: loginResponse.accessToken,
    );

    // Notify AuthService about successful login
    await AuthService().loginSuccess();

    return loginResponse;
  }

  /// Get stored token
  Future<String?> getToken() async {
    return await api.storage.read(key: 'auth_token');
  }

  /// Logout
  Future<void> logout() async {
    await api.storage.delete(key: 'auth_token');
    // Notify AuthService about logout
    await AuthService().logout();
  }
}