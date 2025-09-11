// lib/screens/login/services/register_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:localoop/services/network_helper.dart';
import '../model/register_request.dart';
import '../model/register_response.dart';

class RegisterService {
  Future<RegisterResponse> register(RegisterRequest request) async {
    final uri = NetworkHelper.buildUri('/auth/register');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return RegisterResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Registration failed: ${response.body}');
    }
  }
}
