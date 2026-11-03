import '../entities/geofence_zone.dart';

abstract class GeofenceRepository {
  /// Returns the saved spots, or the built-in sample spots on first launch.
  Future<List<GeofenceZone>> loadZones();

  Future<void> saveZones(List<GeofenceZone> zones);

  /// Replaces everything with the built-in sample spots and returns them.
  Future<List<GeofenceZone>> resetToSamples();
}
