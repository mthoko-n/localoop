import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart'; 

typedef JsonMap = Map<String, dynamic>;

class ApiClient {
  final String baseUrl;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  ApiClient({required this.baseUrl});

  Future<String?> _getToken() async => await storage.read(key: 'auth_token');
  Future<void> _clearToken() async => await storage.delete(key: 'auth_token');

  /// Centralized GET
  Future<JsonMap> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final token = await _getToken();
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: queryParameters?.map((k, v) => MapEntry(k, v.toString())));
    
    final response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      if (headers != null) ...headers,
    });

    return _processResponse(response);
  }

  /// Centralized POST
  Future<JsonMap> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final token = await _getToken();
    final uri = Uri.parse('$baseUrl$path');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        if (headers != null) ...headers,
      },
      body: body != null ? jsonEncode(body) : null,
    );

    return _processResponse(response);
  }

  /// Centralized PUT
  Future<JsonMap> put(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final token = await _getToken();
    final uri = Uri.parse('$baseUrl$path');

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        if (headers != null) ...headers,
      },
      body: body != null ? jsonEncode(body) : null,
    );

    return _processResponse(response);
  }

  /// Centralized DELETE
  Future<JsonMap> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final token = await _getToken();
    final uri = Uri.parse('$baseUrl$path').replace(
      queryParameters: queryParameters?.map((k, v) => MapEntry(k, v.toString())),
    );

    final response = await http.delete(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        if (headers != null) ...headers,
      },
    );

    return _processResponse(response);
  }

  /// Build a WebSocket URI
  Uri buildWsUri(String path, {Map<String, String>? queryParams}) {
    final uri = Uri.parse('$baseUrl$path').replace(
      scheme: baseUrl.startsWith('https') ? 'wss' : 'ws',
      queryParameters: queryParams,
    );
    return uri;
  }

  JsonMap _processResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};

    if (statusCode == 401) {
      _clearToken();
      AuthService().notifyAuthFailure(); // ← This is the ONLY line you need to add!
      throw ApiException(statusCode, 'Unauthorized');
    }

    if (statusCode < 200 || statusCode >= 300) {
      throw ApiException(statusCode, body['detail'] ?? 'Unknown error');
    }

    return body;
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}