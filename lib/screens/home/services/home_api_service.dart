import '../../../services/api_client.dart';
import '../model/place_location.dart';
import '../model/location_status.dart';

class HomeApiService {
  final ApiClient api;

  HomeApiService({required this.api});

  // -----------------------------
  // Get user locations
  // -----------------------------
  Future<List<PlaceLocation>> getUserLocations() async {
    final data = await api.get('/locations/user');
    final locs = (data['locations'] as List<dynamic>?) ?? [];
    return locs.map((json) => PlaceLocation.fromJson(json)).toList();
  }

  // -----------------------------
  // Add location
  // -----------------------------
  Future<PlaceLocation> addLocation(String name, double lat, double lng) async {
    final data = await api.post('/locations/user', body: {
      'location_name': name,
      'coordinates': {'lat': lat, 'lng': lng},
    });
    if (data.containsKey('location')) {
      return PlaceLocation.fromJson(data['location']);
    }
    throw Exception('No location returned in response.');
  }

  // -----------------------------
  // Remove location
  // -----------------------------
  Future<void> removeLocation(String placeId) async {
    await api.delete('/locations/user/$placeId');
  }

  // -----------------------------
  // Update location (PUT example)
  // -----------------------------
  Future<PlaceLocation> updateLocation(String placeId, String newName) async {
    final data = await api.put('/locations/user/$placeId', body: {
      'location_name': newName,
    });
    if (data.containsKey('location')) {
      return PlaceLocation.fromJson(data['location']);
    }
    throw Exception('No location returned in response.');
  }

  // -----------------------------
  // Get location status
  // -----------------------------
  Future<LocationStatus> getLocationStatus(String locationId) async {
    final data = await api.get('/locations/$locationId/status');
    return LocationStatus.fromJson(data);
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
    final body = {
      'query': query,
      if (latitude != null && longitude != null)
        'coordinates': {'lat': latitude, 'lng': longitude},
      'radius_km': radiusKm,
    };

    final data = await api.post('/locations/search', body: body);
    final suggestions = (data['suggestions'] as List<dynamic>?) ?? [];
    return suggestions
        .map((json) => PlaceLocation.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // -----------------------------
  // Logout
  // -----------------------------
  Future<void> logout() async {
    // Clear token through ApiClient
    await api.storage.delete(key: 'auth_token');
  }
}
