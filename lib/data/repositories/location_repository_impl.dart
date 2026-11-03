import 'package:geolocator/geolocator.dart';

import '../../domain/entities/geo_location.dart';
import '../../domain/repositories/location_repository.dart';

/// Wraps the `geolocator` plugin: permission handling plus live GPS fixes.
class LocationRepositoryImpl implements LocationRepository {
  @override
  Future<LocationAccess> ensureAccess() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return LocationAccess.serviceDisabled;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationAccess.deniedForever;
    }
    if (permission == LocationPermission.denied) {
      return LocationAccess.denied;
    }
    return LocationAccess.granted;
  }

  @override
  Future<GeoLocation?> currentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return _toLocation(position);
    } catch (_) {
      // No fix in time (indoors, cold start). The stream will deliver one.
      return null;
    }
  }

  @override
  Stream<GeoLocation> watchLocation() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 2,
      ),
    ).map(_toLocation);
  }

  @override
  Future<void> openSettings(LocationAccess access) async {
    if (access == LocationAccess.serviceDisabled) {
      await Geolocator.openLocationSettings();
    } else {
      await Geolocator.openAppSettings();
    }
  }

  GeoLocation _toLocation(Position position) {
    return GeoLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracyMeters: position.accuracy,
      timestamp: DateTime.now(),
    );
  }
}
