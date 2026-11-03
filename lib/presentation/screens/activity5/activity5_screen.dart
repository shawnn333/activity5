import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/geofence_event.dart';
import '../../../domain/entities/geofence_zone.dart';
import '../../providers/geofence_provider.dart';
import 'zone_editor_dialog.dart';

/// Lianga, Surigao del Sur - used when there are no spots to center on.
const LatLng _defaultCenter = LatLng(8.6333, 126.0833);

class Activity5Screen extends StatefulWidget {
  const Activity5Screen({super.key});

  @override
  State<Activity5Screen> createState() => _Activity5ScreenState();
}

class _Activity5ScreenState extends State<Activity5Screen> {
  final MapController _mapController = MapController();
  late final GeofenceProvider _provider;
  StreamSubscription<GeofenceEvent>? _eventSub;
  bool _didFit = false;

  @override
  void initState() {
    super.initState();
    _provider = context.read<GeofenceProvider>();
    _eventSub = _provider.eventStream.listen(_onGeofenceEvent);
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    // GPS only runs while this screen is open, to save battery.
    _provider.stopTrackingSilently();
    super.dispose();
  }

  void _onGeofenceEvent(GeofenceEvent event) {
    if (!mounted) return;
    final entered = event.transition == GeofenceTransition.enter;
    final verb = entered ? 'Entered' : 'Left';
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor:
            entered ? Colors.green.shade700 : Colors.blueGrey.shade700,
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Icon(
              entered ? Icons.login_rounded : Icons.logout_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text('$verb ${event.zoneName}')),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------ map helpers

  LatLng _initialCenter(List<GeofenceZone> zones) {
    if (zones.isEmpty) return _defaultCenter;
    final lat = zones.map((z) => z.latitude).reduce((a, b) => a + b) /
        zones.length;
    final lng = zones.map((z) => z.longitude).reduce((a, b) => a + b) /
        zones.length;
    return LatLng(lat, lng);
  }

  void _fitAll(List<GeofenceZone> zones) {
    if (zones.isEmpty) return;
    try {
      if (zones.length == 1) {
        _mapController.move(
          LatLng(zones.first.latitude, zones.first.longitude),
          17,
        );
        return;
      }
      _mapController.fitCamera(
        CameraFit.coordinates(
          coordinates:
              zones.map((z) => LatLng(z.latitude, z.longitude)).toList(),
          padding: const EdgeInsets.all(56),
          maxZoom: 18,
        ),
      );
    } catch (_) {
      // Map not ready yet - the next fit attempt will work.
    }
  }

  void _centerOn(double latitude, double longitude, {double zoom = 18}) {
    try {
      _mapController.move(LatLng(latitude, longitude), zoom);
    } catch (_) {}
  }

  // ----------------------------------------------------------- spot actions

  Future<void> _addZoneAt(
    GeofenceProvider provider,
    double latitude,
    double longitude,
  ) async {
    final draft = await showZoneEditor(
      context: context,
      title: 'Add custom spot',
      initial: ZoneDraft(
        name: 'Spot ${provider.zones.length + 1}',
        description: '',
        latitude: latitude,
        longitude: longitude,
        radiusMeters: 50,
      ),
    );
    if (draft == null) return;
    await provider.addZone(
      name: draft.name,
      description: draft.description,
      latitude: draft.latitude,
      longitude: draft.longitude,
      radiusMeters: draft.radiusMeters,
    );
  }

  Future<void> _editZone(GeofenceProvider provider, GeofenceZone zone) async {
    final draft = await showZoneEditor(
      context: context,
      title: 'Edit custom spot',
      initial: ZoneDraft(
        name: zone.name,
        description: zone.description,
        latitude: zone.latitude,
        longitude: zone.longitude,
        radiusMeters: zone.radiusMeters,
      ),
    );
    if (draft == null) return;
    await provider.updateZone(
      zone.copyWith(
        name: draft.name,
        description: draft.description,
        latitude: draft.latitude,
        longitude: draft.longitude,
        radiusMeters: draft.radiusMeters,
      ),
    );
  }

  Future<void> _pinMyLocation(GeofenceProvider provider) async {
    final loc = provider.location;
    if (loc == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No position yet. Start tracking first, or use simulation mode '
            'and tap the map.',
          ),
        ),
      );
      return;
    }
    await _addZoneAt(provider, loc.latitude, loc.longitude);
  }

  Future<void> _confirmReset(GeofenceProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset spots?'),
        content: const Text(
          'This replaces all of your custom spots with the 5 sample spots.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await provider.resetToSamples();
      _fitAll(provider.zones);
    }
  }

  void _showZoneSheet(GeofenceProvider provider, GeofenceZone zone) {
    final inside = provider.insideZoneIds.contains(zone.id);
    final distance = provider.distanceTo(zone);
    final scheme = Theme.of(context).colorScheme;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final status = inside
            ? 'You are inside this spot'
            : distance == null
                ? 'No position yet'
                : '${_formatDistance(distance)} away';

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                zone.name,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              if (zone.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(zone.description, style: theme.textTheme.bodyMedium),
              ],
              const SizedBox(height: 12),
              Text(
                '${zone.latitude.toStringAsFixed(6)}, '
                '${zone.longitude.toStringAsFixed(6)}',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Radius ${zone.radiusMeters.round()} m  -  $status',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: inside ? Colors.green.shade700 : null,
                  fontWeight: inside ? FontWeight.w700 : null,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      _centerOn(zone.latitude, zone.longitude);
                    },
                    icon: const Icon(Icons.center_focus_strong_outlined),
                    label: const Text('Show on map'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      _editZone(provider, zone);
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit'),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: scheme.error,
                    ),
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      provider.removeZone(zone.id);
                    },
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------------ build

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GeofenceProvider>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // Zones load asynchronously; once they arrive, frame them all once.
    if (!_didFit && provider.zonesLoaded && provider.zones.isNotEmpty) {
      _didFit = true;
      final zones = provider.zones;
      WidgetsBinding.instance.addPostFrameCallback((_) => _fitAll(zones));
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final mapHeight = math.max(280.0, math.min(460.0, screenHeight * 0.42));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity 05'),
        actions: [
          IconButton(
            tooltip: 'Fit all spots',
            onPressed: () => _fitAll(provider.zones),
            icon: const Icon(Icons.zoom_out_map_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: mapHeight,
              child: _buildMap(provider, scheme),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: _buildDetails(provider, theme),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap(GeofenceProvider provider, ColorScheme scheme) {
    final user = provider.location;

    final circles = <CircleMarker>[];
    final markers = <Marker>[];

    for (final zone in provider.zones) {
      final inside = provider.insideZoneIds.contains(zone.id);
      final color = inside ? Colors.green.shade600 : scheme.primary;

      circles.add(
        CircleMarker(
          point: LatLng(zone.latitude, zone.longitude),
          radius: zone.radiusMeters,
          useRadiusInMeter: true,
          color: color.withValues(alpha: 0.18),
          borderColor: color,
          borderStrokeWidth: 2,
        ),
      );

      markers.add(
        Marker(
          point: LatLng(zone.latitude, zone.longitude),
          width: 120,
          height: 64,
          alignment: Alignment.topCenter,
          child: GestureDetector(
            onTap: () => _showZoneSheet(provider, zone),
            child: _ZonePin(name: zone.name, inside: inside, color: color),
          ),
        ),
      );
    }

    if (user != null) {
      markers.add(
        Marker(
          point: LatLng(user.latitude, user.longitude),
          width: 44,
          height: 44,
          child: _UserDot(simulated: user.isSimulated),
        ),
      );
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _initialCenter(provider.zones),
            initialZoom: 16.5,
            minZoom: 3,
            maxZoom: 19,
            onLongPress: (tapPosition, point) =>
                _addZoneAt(provider, point.latitude, point.longitude),
            onTap: (tapPosition, point) {
              if (provider.simulationMode) {
                provider.setSimulatedLocation(point.latitude, point.longitude);
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.lab_activity_master',
            ),
            CircleLayer(circles: circles),
            MarkerLayer(markers: markers),
          ],
        ),
        Positioned(
          left: 8,
          bottom: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              '\u00A9 OpenStreetMap contributors',
              style: TextStyle(fontSize: 10, color: Colors.black87),
            ),
          ),
        ),
        Positioned(
          right: 10,
          top: 10,
          child: FloatingActionButton.small(
            heroTag: 'activity5_my_location',
            tooltip: 'Go to my position',
            onPressed: user == null
                ? null
                : () => _centerOn(user.latitude, user.longitude),
            child: const Icon(Icons.my_location_rounded),
          ),
        ),
        if (provider.simulationMode)
          Positioned(
            top: 10,
            left: 10,
            right: 70,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.shade800,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Simulation mode: tap the map to move yourself',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> _buildDetails(GeofenceProvider provider, ThemeData theme) {
    final scheme = theme.colorScheme;

    return [
      Text(
        'LABORATORY ACTIVITY 05',
        style: theme.textTheme.labelMedium?.copyWith(
          color: scheme.primary,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        'Custom Map & Geofence Tracker',
        style: theme.textTheme.headlineSmall
            ?.copyWith(fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 6),
      Text(
        'Long-press the map to add your own spot. Start tracking to get '
        'enter/exit alerts as you walk into a circle, or switch on '
        'simulation mode and tap the map to test it without moving.',
        style: theme.textTheme.bodyMedium,
      ),
      const SizedBox(height: 16),
      _StatusCard(provider: provider),
      const SizedBox(height: 12),
      Card(
        child: SwitchListTile(
          value: provider.simulationMode,
          onChanged: provider.setSimulationMode,
          title: const Text(
            'Simulation mode',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: const Text('Tap the map to move a pretend user.'),
          secondary: const Icon(Icons.science_outlined),
        ),
      ),
      if (provider.errorMessage != null) ...[
        const SizedBox(height: 12),
        _ErrorBanner(
          message: provider.errorMessage!,
          showSettings: provider.accessProblem != null,
          onOpenSettings: provider.openSettings,
        ),
      ],
      const SizedBox(height: 24),
      Row(
        children: [
          Expanded(
            child: Text(
              'Custom Spots (${provider.zones.length})',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Spot options',
            onSelected: (value) {
              if (value == 'pin') _pinMyLocation(provider);
              if (value == 'reset') _confirmReset(provider);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'pin', child: Text('Pin my location')),
              PopupMenuItem(value: 'reset', child: Text('Reset to samples')),
            ],
          ),
        ],
      ),
      const SizedBox(height: 4),
      Text(
        'Tap a spot for details. The 5 sample spots are placeholders - '
        'replace them with your real houses and hidden places.',
        style: theme.textTheme.bodySmall,
      ),
      const SizedBox(height: 12),
      if (provider.zones.isEmpty)
        const Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text('No spots yet. Long-press the map to add one.'),
          ),
        )
      else
        ...provider.zones.map(
          (zone) => _ZoneTile(
            zone: zone,
            inside: provider.insideZoneIds.contains(zone.id),
            distance: provider.distanceTo(zone),
            onTap: () => _showZoneSheet(provider, zone),
          ),
        ),
      const SizedBox(height: 24),
      Text(
        'Geofence Log',
        style: theme.textTheme.titleLarge
            ?.copyWith(fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 4),
      Text(
        'Every time you enter or leave a spot, newest first.',
        style: theme.textTheme.bodySmall,
      ),
      const SizedBox(height: 12),
      if (provider.events.isEmpty)
        const Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text('No enter/exit events yet.'),
          ),
        )
      else
        ...provider.events.map((event) => _EventTile(event: event)),
    ];
  }
}

// ---------------------------------------------------------------- map widgets

class _ZonePin extends StatelessWidget {
  final String name;
  final bool inside;
  final Color color;

  const _ZonePin({
    required this.name,
    required this.inside,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 116),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color, width: 1.2),
          ),
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: inside ? FontWeight.w800 : FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        Icon(Icons.location_on_rounded, size: 36, color: color),
      ],
    );
  }
}

class _UserDot extends StatelessWidget {
  final bool simulated;
  const _UserDot({required this.simulated});

  @override
  Widget build(BuildContext context) {
    final color = simulated ? Colors.orange.shade800 : Colors.blue.shade700;
    return Center(
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.45),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------- detail widgets

class _StatusCard extends StatelessWidget {
  final GeofenceProvider provider;
  const _StatusCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final insideZones = provider.zones
        .where((zone) => provider.insideZoneIds.contains(zone.id))
        .toList();
    final user = provider.location;
    final isInside = insideZones.isNotEmpty;

    GeofenceZone? nearest;
    double? nearestDistance;
    for (final zone in provider.zones) {
      final d = provider.distanceTo(zone);
      if (d == null) continue;
      if (nearestDistance == null || d < nearestDistance) {
        nearest = zone;
        nearestDistance = d;
      }
    }

    final Color color = isInside
        ? Colors.green.shade700
        : user != null
            ? scheme.primary
            : Colors.blueGrey.shade600;

    final String headline;
    if (isInside) {
      headline = 'Inside ${insideZones.map((z) => z.name).join(', ')}';
    } else if (user != null) {
      headline = 'Outside all spots';
    } else {
      headline = 'No position yet';
    }

    String detail;
    if (user == null) {
      detail = provider.simulationMode
          ? 'Tap the map to place yourself.'
          : 'Start tracking to use your GPS.';
    } else {
      final source = user.isSimulated
          ? 'Simulated position'
          : 'GPS accuracy +/- ${user.accuracyMeters.round()} m';
      detail = nearest != null && nearestDistance != null
          ? '$source  -  nearest: ${nearest.name} '
              '(${_formatDistance(nearestDistance)})'
          : source;
    }

    final String buttonLabel;
    if (provider.isStarting) {
      buttonLabel = 'Locating...';
    } else if (provider.isTracking) {
      buttonLabel = 'Stop tracking';
    } else {
      buttonLabel = 'Start tracking';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withValues(alpha: 0.78)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isInside ? Icons.where_to_vote_rounded : Icons.explore_rounded,
                color: Colors.white,
                size: 26,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  headline,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            detail,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: color,
            ),
            onPressed: provider.simulationMode || provider.isStarting
                ? null
                : provider.isTracking
                    ? provider.stopTracking
                    : provider.startTracking,
            icon: provider.isStarting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    provider.isTracking
                        ? Icons.stop_circle_outlined
                        : Icons.gps_fixed_rounded,
                  ),
            label: Text(buttonLabel),
          ),
          if (provider.simulationMode)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'GPS is paused while simulation mode is on.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final bool showSettings;
  final VoidCallback onOpenSettings;

  const _ErrorBanner({
    required this.message,
    required this.showSettings,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 18,
                color: scheme.onErrorContainer,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: scheme.onErrorContainer),
                ),
              ),
            ],
          ),
          if (showSettings)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onOpenSettings,
                child: const Text('Open settings'),
              ),
            ),
        ],
      ),
    );
  }
}

class _ZoneTile extends StatelessWidget {
  final GeofenceZone zone;
  final bool inside;
  final double? distance;
  final VoidCallback onTap;

  const _ZoneTile({
    required this.zone,
    required this.inside,
    required this.distance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = inside ? Colors.green.shade700 : scheme.primary;
    final distanceText =
        distance == null ? '' : '  -  ${_formatDistance(distance!)} away';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: ListTile(
          onTap: onTap,
          leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(
              inside ? Icons.check_circle_rounded : Icons.location_on_outlined,
              color: color,
            ),
          ),
          title: Text(
            zone.name,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text('${zone.radiusMeters.round()} m radius$distanceText'),
          trailing: inside
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'INSIDE',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                )
              : const Icon(Icons.chevron_right_rounded),
        ),
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  final GeofenceEvent event;
  const _EventTile({required this.event});

  @override
  Widget build(BuildContext context) {
    final entered = event.transition == GeofenceTransition.enter;
    final color = entered ? Colors.green.shade700 : Colors.blueGrey.shade600;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(
              entered ? Icons.login_rounded : Icons.logout_rounded,
              color: color,
            ),
          ),
          title: Text(
            '${entered ? 'Entered' : 'Left'} ${event.zoneName}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            '${_formatTime(event.timestamp)}  -  '
            '${_formatDistance(event.distanceMeters)} from center',
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------- helpers

String _formatDistance(double meters) {
  if (meters < 1000) return '${meters.round()} m';
  return '${(meters / 1000).toStringAsFixed(2)} km';
}

String _formatTime(DateTime time) {
  final h = time.hour.toString().padLeft(2, '0');
  final m = time.minute.toString().padLeft(2, '0');
  final s = time.second.toString().padLeft(2, '0');
  return '$h:$m:$s';
}
