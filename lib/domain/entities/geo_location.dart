/// Where the user is right now. [isSimulated] is true when the position
/// came from tapping the map in simulation mode instead of the GPS.
class GeoLocation {
  final double latitude;
  final double longitude;
  final double accuracyMeters;
  final DateTime timestamp;
  final bool isSimulated;

  const GeoLocation({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.accuracyMeters = 0,
    this.isSimulated = false,
  });
}
