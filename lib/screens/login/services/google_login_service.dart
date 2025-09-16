import 'dart:convert';
import 'package:localoop/services/api_client.dart';
import 'package:localoop/services/auth_service.dart'; // Add this import
import '../model/google_login_request.dart';

class GoogleLoginService {
  final ApiClient api;

  GoogleLoginService({required this.api});

  Future<String> signInWithGoogle(String idToken) async {
    final data = await api.post(
      '/auth/google',
      body: GoogleLoginRequest(idToken: idToken).toJson(),
    );

    final token = data['access_token'] as String;

    // Store token securely via ApiClient
    await api.storage.write(key: 'auth_token', value: token);

    // Notify AuthService about successful login
    await AuthService().loginSuccess();

    return token; // JWT for your app
  }
}