
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:localoop/services/network_helper.dart';
import '../model/google_login_request.dart';

class GoogleLoginService {
  Future<String> signInWithGoogle(String idToken) async {
    final uri = NetworkHelper.buildUri('/auth/google');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(GoogleLoginRequest(idToken: idToken).toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['access_token']; // JWT for your app
    } else {
      throw Exception('Google login failed: ${response.body}');
    }
  }
}
