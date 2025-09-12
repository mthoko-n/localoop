class PlaceLocation {
  final String placeId;
  final String name;
  final String address; // formatted address or vicinity
  final String type; // e.g., "neighborhood", "restaurant", "park"
  final Coordinates coordinates;

  PlaceLocation({
    required this.placeId,
    required this.name,
    required this.address,
    required this.type,
    required this.coordinates,
  });

  factory PlaceLocation.fromJson(Map<String, dynamic> json) {
    // Determine coordinates source (Google 'geometry' or backend 'coordinates')
    final loc = (json['geometry']?['location'] as Map<String, dynamic>?) ??
        (json['coordinates'] as Map<String, dynamic>?) ??
        {'lat': 0.0, 'lng': 0.0};

    return PlaceLocation(
      placeId: json['place_id'] ?? json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      address: json['vicinity'] ??
          json['formatted_address'] ??
          json['address'] ??
          '',
      type: (json['types'] != null && (json['types'] as List).isNotEmpty)
          ? (json['types'] as List).first
          : (json['type'] ?? 'unknown'),
      coordinates: Coordinates(
        latitude: (loc['lat'] ?? loc['latitude'] ?? 0.0).toDouble(),
        longitude: (loc['lng'] ?? loc['longitude'] ?? 0.0).toDouble(),
      ),
    );
  }
}

class Coordinates {
  final double latitude;
  final double longitude;

  Coordinates({required this.latitude, required this.longitude});

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(
      latitude: (json['lat'] ?? json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['lng'] ?? json['longitude'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };
}
