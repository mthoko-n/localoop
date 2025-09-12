import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../model/location.dart';
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

  // Existing methods...
Future<List<Location>> getUserLocations() async {
  final uri = NetworkHelper.buildUri('/locations/user');
  print('Calling: $uri'); // Debug
  
  try {
    final headers = await _getHeaders();
    //print('Headers: $headers'); // Debug (be careful not to log this in production)
    
    final response = await http.get(uri, headers: headers);
    print('Response status: ${response.statusCode}'); // Debug
    print('Response body: ${response.body}'); // Debug

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['locations'] as List)
          .map((json) => Location.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to fetch locations: ${response.body}');
    }
  } catch (e) {
    print('Error in getUserLocations: $e'); // Debug
    rethrow;
  }
}

   Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }

  Future<Location> addLocation(String name, double lat, double lng) async {
    final uri = NetworkHelper.buildUri('/locations/user');
    final body = jsonEncode({
      'location_name': name,
      'coordinates': {'latitude': lat, 'longitude': lng},
    });

    final response =
        await http.post(uri, headers: await _getHeaders(), body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Location.fromJson(data['location']);
    } else {
      throw Exception('Failed to add location: ${response.body}');
    }
  }

  Future<void> removeLocation(String id) async {
    final uri = NetworkHelper.buildUri('/locations/user/$id');
    final response = await http.delete(uri, headers: await _getHeaders());

    if (response.statusCode != 200) {
      throw Exception('Failed to remove location: ${response.body}');
    }
  }

  Future<LocationStatus> getLocationStatus(String locationId) async {
    final uri = NetworkHelper.buildUri('/locations/$locationId/status');
    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return LocationStatus.fromJson(data);
    } else {
      throw Exception('Failed to get location status: ${response.body}');
    }
  }

  // -----------------------------
  // New: Search locations
  // -----------------------------
  Future<List<Location>> searchLocations(String query,
      {double? latitude, double? longitude, int radiusKm = 10}) async {
    final uri = NetworkHelper.buildUri('/locations/search');
    final body = {
      'query': query,
      if (latitude != null && longitude != null)
        'coordinates': {'latitude': latitude, 'longitude': longitude},
      'radius_km': radiusKm,
    };

    final response = await http.post(uri,
        headers: await _getHeaders(), body: jsonEncode(body));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final suggestions = data['suggestions'] as List;
      return suggestions.map((json) => Location.fromJson(json)).toList();
    } else {
      throw Exception('Search failed: ${response.body}');
    }
  }
}
