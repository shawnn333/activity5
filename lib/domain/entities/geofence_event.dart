enum GeofenceTransition { enter, exit }

class GeofenceEvent {
  final String zoneId;
  final String zoneName;
  final GeofenceTransition transition;
  final DateTime timestamp;
  final double distanceMeters;

  const GeofenceEvent({
    required this.zoneId,
    required this.zoneName,
    required this.transition,
    required this.timestamp,
    required this.distanceMeters,
  });
}
