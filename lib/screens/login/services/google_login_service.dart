import 'dart:convert';
import 'package:localoop/services/api_client.dart';
import 'package:localoop/services/auth_service.dart';
import '../model/google_login_request.dart';

class GoogleLoginService {
  final ApiClient api;

  GoogleLoginService({required this.api});

  Future<Map<String, dynamic>> signInWithGoogle(String idToken) async {
    final data = await api.post(
      '/auth/google',
      body: GoogleLoginRequest(idToken: idToken).toJson(),
    );

    // Store both tokens via AuthService (handles token pairs)
    await AuthService().login(data);

    // Return the full token response instead of just access token
    return {
      'access_token': data['access_token'],
      'refresh_token': data['refresh_token'],
      'token_type': data['token_type'] ?? 'bearer',
      'expires_in': data['expires_in'] ?? 900,
    };
  }
}