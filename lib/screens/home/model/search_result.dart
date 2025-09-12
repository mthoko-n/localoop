import 'place_location.dart';

class SearchResult {
  final String id;
  final String name;
  final String displayName;
  final Coordinates coordinates;
  final String type;

  SearchResult({
    required this.id,
    required this.name,
    required this.displayName,
    required this.coordinates,
    required this.type,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      id: json['id'],
      name: json['name'],
      displayName: json['display_name'],
      coordinates: Coordinates.fromJson(json['coordinates']),
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'display_name': displayName,
      'coordinates': coordinates.toJson(),
      'type': type,
    };
  }
}
