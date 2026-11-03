import '../entities/geo_location.dart';

enum LocationAccess { granted, serviceDisabled, denied, deniedForever }

abstract class LocationRepository {
  /// Checks that GPS is on and asks for the location permission if needed.
  Future<LocationAccess> ensureAccess();

  /// One quick fix so the map has a position before the stream warms up.
  Future<GeoLocation?> currentLocation();

  /// Continuous position updates while tracking is on.
  Stream<GeoLocation> watchLocation();

  /// Opens the system page that can fix [access] (GPS toggle or app settings).
  Future<void> openSettings(LocationAccess access);
}
