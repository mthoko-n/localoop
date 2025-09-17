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

    // Store both tokens via AuthService (updated to handle token pairs)
    await AuthService().login(data); // Pass the full response with both tokens

    return loginResponse;
  }

  /// Get stored access token (now handled by AuthService)
  Future<String?> getToken() async {
    return await AuthService().getValidToken(); // This ensures we get a valid, fresh token
  }

  /// Logout with refresh token revocation
  Future<void> logout() async {
    // AuthService now handles proper logout including refresh token revocation
    await AuthService().logout();
  }

  /// Logout from all devices
  Future<void> logoutAllDevices() async {
    await AuthService().logoutAllDevices();
  }
}