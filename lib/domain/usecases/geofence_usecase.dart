import 'dart:math' as math;

import '../entities/geo_location.dart';
import '../entities/geofence_event.dart';
import '../entities/geofence_zone.dart';
import '../repositories/geofence_repository.dart';
import '../repositories/location_repository.dart';

/// Holds the geofencing rules. The distance and enter/exit logic here is
/// plain Dart (no Flutter, no plugins), so it can be tested on its own.
class GeofenceUseCase {
  /// Once you are inside a spot you only count as "left" after moving this
  /// far past its edge. Without it, GPS jitter right on the boundary would
  /// spam enter/exit events.
  static const double exitBufferMeters = 10;

  final GeofenceRepository zones;
  final LocationRepository location;

  GeofenceUseCase({required this.zones, required this.location});

  Future<List<GeofenceZone>> loadZones() => zones.loadZones();

  Future<void> saveZones(List<GeofenceZone> list) => zones.saveZones(list);

  Future<List<GeofenceZone>> resetToSamples() => zones.resetToSamples();

  Future<LocationAccess> ensureAccess() => location.ensureAccess();

  Future<GeoLocation?> currentLocation() => location.currentLocation();

  Stream<GeoLocation> watchLocation() => location.watchLocation();

  Future<void> openSettings(LocationAccess access) =>
      location.openSettings(access);

  /// Great-circle (haversine) distance between two coordinates, in meters.
  static double distanceMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusMeters = 6371000.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusMeters * c;
  }

  static double _toRadians(double degrees) => degrees * math.pi / 180;

  double distanceToZone(GeoLocation at, GeofenceZone zone) {
    return distanceMeters(
      at.latitude,
      at.longitude,
      zone.latitude,
      zone.longitude,
    );
  }

  /// Ids of every zone the position is inside of. [previouslyInside] gives
  /// zones you were already in a bit of extra room (see [exitBufferMeters]).
  Set<String> zonesContaining(
    GeoLocation at,
    List<GeofenceZone> list,
    Set<String> previouslyInside,
  ) {
    final inside = <String>{};
    for (final zone in list) {
      final distance = distanceToZone(at, zone);
      final wasInside = previouslyInside.contains(zone.id);
      final limit =
          wasInside ? zone.radiusMeters + exitBufferMeters : zone.radiusMeters;
      if (distance <= limit) inside.add(zone.id);
    }
    return inside;
  }

  /// Turns "before" and "after" inside-sets into enter/exit events.
  List<GeofenceEvent> transitions({
    required GeoLocation at,
    required List<GeofenceZone> list,
    required Set<String> before,
    required Set<String> after,
  }) {
    final events = <GeofenceEvent>[];
    for (final zone in list) {
      final wasInside = before.contains(zone.id);
      final isInside = after.contains(zone.id);
      if (wasInside == isInside) continue;
      events.add(
        GeofenceEvent(
          zoneId: zone.id,
          zoneName: zone.name,
          transition:
              isInside ? GeofenceTransition.enter : GeofenceTransition.exit,
          timestamp: at.timestamp,
          distanceMeters: distanceToZone(at, zone),
        ),
      );
    }
    return events;
  }
}
