import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/geofence_zone.dart';
import '../../domain/repositories/geofence_repository.dart';

/// Five starter spots around Lianga, Surigao del Sur. The coordinates are
/// approximate PLACEHOLDERS so the map works on first launch - replace them
/// with your real houses / hidden spots (long-press the map, or stand there
/// and tap "Pin my location").
const List<GeofenceZone> kSampleZones = [
  GeofenceZone(
    id: 'sample_1',
    name: 'Sample 1 - My House',
    description: 'Replace with your own house.',
    latitude: 8.63330,
    longitude: 126.08330,
    radiusMeters: 40,
  ),
  GeofenceZone(
    id: 'sample_2',
    name: 'Sample 2 - Secret Fishing Spot',
    description: 'Replace with a spot nobody has mapped.',
    latitude: 8.63425,
    longitude: 126.08410,
    radiusMeters: 50,
  ),
  GeofenceZone(
    id: 'sample_3',
    name: "Sample 3 - Friend's House",
    description: "Replace with a friend's house.",
    latitude: 8.63240,
    longitude: 126.08470,
    radiusMeters: 40,
  ),
  GeofenceZone(
    id: 'sample_4',
    name: 'Sample 4 - Study Corner',
    description: 'Replace with your favorite quiet spot.',
    latitude: 8.63180,
    longitude: 126.08240,
    radiusMeters: 45,
  ),
  GeofenceZone(
    id: 'sample_5',
    name: 'Sample 5 - Hidden View Point',
    description: 'Replace with an undiscovered place.',
    latitude: 8.63470,
    longitude: 126.08250,
    radiusMeters: 50,
  ),
];

/// Stores the custom spots on the device as JSON, so the places you add
/// are still there next time the app opens.
class GeofenceRepositoryImpl implements GeofenceRepository {
  static const String _storageKey = 'geofence_zones_v1';

  @override
  Future<List<GeofenceZone>> loadZones() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return List<GeofenceZone>.of(kSampleZones);

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => _fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Corrupted or from an incompatible version - fall back to samples.
      return List<GeofenceZone>.of(kSampleZones);
    }
  }

  @override
  Future<void> saveZones(List<GeofenceZone> zones) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(zones.map(_toJson).toList()),
    );
  }

  @override
  Future<List<GeofenceZone>> resetToSamples() async {
    final samples = List<GeofenceZone>.of(kSampleZones);
    await saveZones(samples);
    return samples;
  }

  Map<String, dynamic> _toJson(GeofenceZone zone) {
    return {
      'id': zone.id,
      'name': zone.name,
      'description': zone.description,
      'lat': zone.latitude,
      'lng': zone.longitude,
      'radius': zone.radiusMeters,
    };
  }

  GeofenceZone _fromJson(Map<String, dynamic> json) {
    return GeofenceZone(
      id: json['id'] as String,
      name: json['name'] as String,
      description: (json['description'] as String?) ?? '',
      latitude: (json['lat'] as num).toDouble(),
      longitude: (json['lng'] as num).toDouble(),
      radiusMeters: (json['radius'] as num).toDouble(),
    );
  }
}
