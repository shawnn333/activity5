/// A custom spot on the map (a house, a hidden place, anything that is not
/// on Google Maps) plus the radius around it that counts as "inside".
class GeofenceZone {
  final String id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final double radiusMeters;

  const GeofenceZone({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
  });

  GeofenceZone copyWith({
    String? name,
    String? description,
    double? latitude,
    double? longitude,
    double? radiusMeters,
  }) {
    return GeofenceZone(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusMeters: radiusMeters ?? this.radiusMeters,
    );
  }
}
