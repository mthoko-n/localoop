import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../model/place_location.dart';
import '../model/location_status.dart';
import 'package:localoop/services/network_helper.dart';

class HomeApiService {
  final _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) {
      throw Exception('No auth token found. User might not be logged in.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // -----------------------------
  // Get user locations
  // -----------------------------
  Future<List<PlaceLocation>> getUserLocations() async {
    final uri = NetworkHelper.buildUri('/locations/user');
    final headers = await _getHeaders();
    final response = await http.get(uri, headers: headers);

    Map<String, dynamic> data;
    try {
      data = response.body.isNotEmpty ? jsonDecode(response.body) : {};
    } catch (_) {
      throw Exception('Failed to decode response: ${response.body}');
    }

    if (response.statusCode == 200) {
      final locs = (data['locations'] as List<dynamic>?) ?? [];
      return locs.map((json) => PlaceLocation.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch locations: ${data['detail'] ?? "Unknown error"}');
    }
  }

  // -----------------------------
  // Logout
  // -----------------------------
  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }

  // -----------------------------
  // Add location
  // -----------------------------
  Future<PlaceLocation> addLocation(String name, double lat, double lng) async {
    final uri = NetworkHelper.buildUri('/locations/user');
    final body = jsonEncode({
      'location_name': name,
      'coordinates': {'lat': lat, 'lng': lng},
    });

    final response = await http.post(
      uri,
      headers: await _getHeaders(),
      body: body,
    );

    Map<String, dynamic> data;
    try {
      data = response.body.isNotEmpty ? jsonDecode(response.body) : {};
    } catch (_) {
      throw Exception('Failed to decode response: ${response.body}');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (data.containsKey('location')) {
        return PlaceLocation.fromJson(data['location']);
      } else {
        throw Exception('No location returned in response.');
      }
    } else {
      throw Exception('Failed to add location: ${data['detail'] ?? response.body}');
    }
  }

  // -----------------------------
  // Remove location
  // -----------------------------
  Future<void> removeLocation(String placeId) async {
    final uri = NetworkHelper.buildUri('/locations/user/$placeId');
    final response = await http.delete(uri, headers: await _getHeaders());

    Map<String, dynamic> data;
    try {
      data = response.body.isNotEmpty ? jsonDecode(response.body) : {};
    } catch (_) {
      data = {};
    }

    if (response.statusCode != 200) {
      throw Exception('Failed to remove location: ${data['detail'] ?? response.body}');
    }
  }

  // -----------------------------
  // Get location status
  // -----------------------------
  Future<LocationStatus> getLocationStatus(String locationId) async {
    final uri = NetworkHelper.buildUri('/locations/$locationId/status');
    final response = await http.get(uri, headers: await _getHeaders());

    Map<String, dynamic> data;
    try {
      data = response.body.isNotEmpty ? jsonDecode(response.body) : {};
    } catch (_) {
      throw Exception('Failed to decode response: ${response.body}');
    }

    if (response.statusCode == 200) {
      return LocationStatus.fromJson(data);
    } else {
      throw Exception('Failed to get location status: ${data['detail'] ?? response.body}');
    }
  }

  // -----------------------------
  // Search locations (backend + Google Places)
  // -----------------------------
  Future<List<PlaceLocation>> searchLocations(
    String query, {
    double? latitude,
    double? longitude,
    int radiusKm = 10,
  }) async {
    final uri = NetworkHelper.buildUri('/locations/search');
    final body = {
      'query': query,
      if (latitude != null && longitude != null)
        'coordinates': {'lat': latitude, 'lng': longitude},
      'radius_km': radiusKm,
    };

    final response = await http.post(
      uri,
      headers: await _getHeaders(),
      body: jsonEncode(body),
    );

    Map<String, dynamic> data;
    try {
      data = response.body.isNotEmpty ? jsonDecode(response.body) : {};
    } catch (_) {
      throw Exception('Failed to decode response: ${response.body}');
    }

    if (response.statusCode == 200) {
      final suggestions = (data['suggestions'] as List<dynamic>?) ?? [];
      return suggestions
          .map((json) => PlaceLocation.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Search failed: ${data['detail'] ?? response.body}');
    }
  }
}
