class Location {
  final String id;
  final String name;
  final int unreadCount;
  final String status; // "new_messages" or "caught_up"
  final String joinedAt;
  final bool isActive;
  final String lastActivity;
  final Coordinates coordinates;

  Location({
    required this.id,
    required this.name,
    required this.unreadCount,
    required this.status,
    required this.joinedAt,
    required this.isActive,
    required this.lastActivity,
    required this.coordinates,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      name: json['name'],
      unreadCount: json['unread_count'] ?? 0,
      status: json['status'] ?? 'caught_up',
      joinedAt: json['joined_at'],
      isActive: json['is_active'] ?? true,
      lastActivity: json['last_activity'],
      coordinates: Coordinates.fromJson(json['coordinates']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'unread_count': unreadCount,
      'status': status,
      'joined_at': joinedAt,
      'is_active': isActive,
      'last_activity': lastActivity,
      'coordinates': coordinates.toJson(),
    };
  }
}

class Coordinates {
  final double latitude;
  final double longitude;

  Coordinates({required this.latitude, required this.longitude});

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
