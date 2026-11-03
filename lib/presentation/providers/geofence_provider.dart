import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/geo_location.dart';
import '../../domain/entities/geofence_event.dart';
import '../../domain/entities/geofence_zone.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/usecases/geofence_usecase.dart';

/// State for the Custom Map & Geofence screen: the custom spots, where the
/// user is (real GPS or a simulated tap on the map), which spots they are
/// currently inside of, and a log of enter/exit events.
class GeofenceProvider extends ChangeNotifier {
  final GeofenceUseCase useCase;

  final StreamController<GeofenceEvent> _eventController =
      StreamController<GeofenceEvent>.broadcast();
  final List<GeofenceEvent> _events = [];

  StreamSubscription<GeoLocation>? _locationSub;
  List<GeofenceZone> _zones = [];
  Set<String> _inside = {};
  GeoLocation? _location;

  bool _zonesLoaded = false;
  bool _isTracking = false;
  bool _isStarting = false;
  bool _simulationMode = false;
  String? _errorMessage;
  LocationAccess? _accessProblem;

  GeofenceProvider(this.useCase) {
    _loadZones();
  }

  List<GeofenceZone> get zones => List.unmodifiable(_zones);
  Set<String> get insideZoneIds => Set.unmodifiable(_inside);
  List<GeofenceEvent> get events => List.unmodifiable(_events);
  GeoLocation? get location => _location;

  bool get zonesLoaded => _zonesLoaded;
  bool get isTracking => _isTracking;
  bool get isStarting => _isStarting;
  bool get simulationMode => _simulationMode;
  String? get errorMessage => _errorMessage;
  LocationAccess? get accessProblem => _accessProblem;

  /// Fires once for every enter/exit so the screen can show a snackbar.
  Stream<GeofenceEvent> get eventStream => _eventController.stream;

  /// Distance from the current position to [zone], or null with no position.
  double? distanceTo(GeofenceZone zone) {
    final current = _location;
    if (current == null) return null;
    return useCase.distanceToZone(current, zone);
  }

  Future<void> _loadZones() async {
    _zones = await useCase.loadZones();
    _zonesLoaded = true;
    final current = _location;
    if (current != null) _evaluate(current, notify: false);
    notifyListeners();
  }

  // ---------------------------------------------------------------- tracking

  Future<void> startTracking() async {
    if (_isTracking || _isStarting) return;

    _simulationMode = false;
    _isStarting = true;
    _errorMessage = null;
    _accessProblem = null;
    notifyListeners();

    final access = await useCase.ensureAccess();
    if (access != LocationAccess.granted) {
      _isStarting = false;
      _accessProblem = access;
      _errorMessage = _messageFor(access);
      notifyListeners();
      return;
    }

    final first = await useCase.currentLocation();
    if (first != null) _evaluate(first, notify: false);

    await _locationSub?.cancel();
    _locationSub = useCase.watchLocation().listen(
      (loc) => _evaluate(loc),
      onError: (Object error) {
        _errorMessage = 'Location error: $error';
        _locationSub?.cancel();
        _locationSub = null;
        _isTracking = false;
        notifyListeners();
      },
    );

    _isStarting = false;
    _isTracking = true;
    notifyListeners();
  }

  Future<void> stopTracking() async {
    await _locationSub?.cancel();
    _locationSub = null;
    _isTracking = false;
    notifyListeners();
  }

  /// Same as [stopTracking] but without notifying listeners, so it is safe
  /// to call while the screen is being torn down.
  void stopTrackingSilently() {
    _locationSub?.cancel();
    _locationSub = null;
    _isTracking = false;
  }

  Future<void> openSettings() async {
    final problem = _accessProblem;
    if (problem != null) await useCase.openSettings(problem);
  }

  // -------------------------------------------------------------- simulation

  /// In simulation mode the live GPS is switched off and tapping the map
  /// moves a pretend user instead - handy for demoing enter/exit events
  /// without actually walking around.
  Future<void> setSimulationMode(bool enabled) async {
    if (enabled) {
      await _locationSub?.cancel();
      _locationSub = null;
      _isTracking = false;
      _simulationMode = true;
      _errorMessage = null;
      _accessProblem = null;
    } else {
      _simulationMode = false;
      _location = null;
      _inside = {};
    }
    notifyListeners();
  }

  void setSimulatedLocation(double latitude, double longitude) {
    if (!_simulationMode) return;
    _evaluate(
      GeoLocation(
        latitude: latitude,
        longitude: longitude,
        timestamp: DateTime.now(),
        isSimulated: true,
      ),
    );
  }

  // ------------------------------------------------------------------- zones

  Future<void> addZone({
    required String name,
    required String description,
    required double latitude,
    required double longitude,
    required double radiusMeters,
  }) async {
    final zone = GeofenceZone(
      id: 'zone_${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      description: description,
      latitude: latitude,
      longitude: longitude,
      radiusMeters: radiusMeters,
    );
    _zones = [..._zones, zone];
    await useCase.saveZones(_zones);
    _reevaluate();
    notifyListeners();
  }

  Future<void> updateZone(GeofenceZone updated) async {
    _zones = [
      for (final zone in _zones)
        if (zone.id == updated.id) updated else zone,
    ];
    await useCase.saveZones(_zones);
    _reevaluate();
    notifyListeners();
  }

  Future<void> removeZone(String id) async {
    _zones = _zones.where((zone) => zone.id != id).toList();
    _inside = {..._inside}..remove(id);
    await useCase.saveZones(_zones);
    _reevaluate();
    notifyListeners();
  }

  Future<void> resetToSamples() async {
    _zones = await useCase.resetToSamples();
    _inside = {};
    _reevaluate();
    notifyListeners();
  }

  // ---------------------------------------------------------------- internals

  void _reevaluate() {
    final current = _location;
    if (current != null) _evaluate(current, notify: false);
  }

  void _evaluate(GeoLocation loc, {bool notify = true}) {
    _location = loc;

    final after = useCase.zonesContaining(loc, _zones, _inside);
    final newEvents = useCase.transitions(
      at: loc,
      list: _zones,
      before: _inside,
      after: after,
    );
    _inside = after;

    for (final event in newEvents) {
      _events.insert(0, event);
      if (!_eventController.isClosed) _eventController.add(event);
    }
    if (_events.length > 100) {
      _events.removeRange(100, _events.length);
    }

    if (notify) notifyListeners();
  }

  String _messageFor(LocationAccess access) {
    switch (access) {
      case LocationAccess.serviceDisabled:
        return 'Location (GPS) is turned off. Turn it on, then start '
            'tracking again.';
      case LocationAccess.denied:
        return 'Location permission was denied. Allow it so the app can '
            'detect when you enter a spot.';
      case LocationAccess.deniedForever:
        return 'Location permission is blocked. Enable it for this app in '
            'the system settings.';
      case LocationAccess.granted:
        return '';
    }
  }

  @override
  void dispose() {
    _locationSub?.cancel();
    _eventController.close();
    super.dispose();
  }
}
