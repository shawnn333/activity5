import 'package:flutter/material.dart';

/// What the user typed into the editor. Turned into a GeofenceZone by the
/// provider (add) or via copyWith (edit).
class ZoneDraft {
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final double radiusMeters;

  const ZoneDraft({
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
  });
}

Future<ZoneDraft?> showZoneEditor({
  required BuildContext context,
  required String title,
  required ZoneDraft initial,
}) {
  return showDialog<ZoneDraft>(
    context: context,
    builder: (_) => _ZoneEditorDialog(title: title, initial: initial),
  );
}

class _ZoneEditorDialog extends StatefulWidget {
  final String title;
  final ZoneDraft initial;

  const _ZoneEditorDialog({required this.title, required this.initial});

  @override
  State<_ZoneEditorDialog> createState() => _ZoneEditorDialogState();
}

class _ZoneEditorDialogState extends State<_ZoneEditorDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _latController;
  late final TextEditingController _lngController;
  late double _radius;
  String? _error;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _nameController = TextEditingController(text: initial.name);
    _descriptionController = TextEditingController(text: initial.description);
    _latController =
        TextEditingController(text: initial.latitude.toStringAsFixed(6));
    _lngController =
        TextEditingController(text: initial.longitude.toStringAsFixed(6));
    _radius = initial.radiusMeters.clamp(20.0, 200.0).toDouble();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final lat = double.tryParse(_latController.text.trim());
    final lng = double.tryParse(_lngController.text.trim());

    if (name.isEmpty) {
      setState(() => _error = 'Give this spot a name.');
      return;
    }
    if (lat == null || lat < -90 || lat > 90) {
      setState(() => _error = 'Latitude must be a number from -90 to 90.');
      return;
    }
    if (lng == null || lng < -180 || lng > 180) {
      setState(() => _error = 'Longitude must be a number from -180 to 180.');
      return;
    }

    Navigator.of(context).pop(
      ZoneDraft(
        name: name,
        description: _descriptionController.text.trim(),
        latitude: lat,
        longitude: lng,
        radiusMeters: _radius,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const coordinateKeyboard = TextInputType.numberWithOptions(
      decimal: true,
      signed: true,
    );

    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g. Lola\'s house',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _latController,
                    keyboardType: coordinateKeyboard,
                    decoration: const InputDecoration(labelText: 'Latitude'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _lngController,
                    keyboardType: coordinateKeyboard,
                    decoration: const InputDecoration(labelText: 'Longitude'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Geofence radius: ${_radius.round()} m'),
            Slider(
              value: _radius,
              min: 20,
              max: 200,
              divisions: 18,
              label: '${_radius.round()} m',
              onChanged: (value) => setState(() => _radius = value),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(_error!, style: TextStyle(color: scheme.error)),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
