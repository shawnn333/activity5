import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/network_event.dart';
import '../../../domain/entities/network_status.dart';
import '../../../domain/entities/queued_request.dart';
import '../../providers/network_provider.dart';

class Activity2Screen extends StatelessWidget {
  const Activity2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NetworkProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity 02'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 760;
            final contentWidth = wide ? 900.0 : double.infinity;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentWidth),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    wide ? 32 : 20,
                    16,
                    wide ? 32 : 20,
                    32,
                  ),
                  children: [
                    Text(
                      'LABORATORY ACTIVITY 02',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Network Monitor',
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Real-time Wi-Fi/Cellular monitoring with handover-safe '
                      'request queuing.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    _StatusCard(status: provider.status),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Simulated Requests',
                            style: theme.textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: provider.simulateRequest,
                          icon: const Icon(Icons.cloud_download_outlined),
                          label: const Text('New Request'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Simulates a long-running dataset fetch. Toggle Wi-Fi off '
                      'mid-request to trigger a handover and watch it queue.',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 14),
                    if (provider.requests.isEmpty)
                      const _EmptyState()
                    else
                      ...provider.requests.map(
                        (r) => _RequestTile(request: r),
                      ),
                    const SizedBox(height: 28),
                    Text(
                      'Handover Log',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Records every time the active interface changes.',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 14),
                    if (provider.events.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            'No handovers detected yet.',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      )
                    else
                      ...provider.events.map((e) => _EventTile(event: e)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final NetworkStatus status;
  const _StatusCard({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = _statusConfig(status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [config.color, config.color.withValues(alpha: 0.78)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(config.icon, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const _LivePulse(color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'ACTIVE INTERFACE',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  config.label,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  config.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _statusConfig(NetworkStatus status) {
    switch (status) {
      case NetworkStatus.wifi:
        return _StatusConfig(
          icon: Icons.wifi_rounded,
          label: 'Wi-Fi',
          color: const Color(0xFF2E7D32),
          description: 'Connected over a wireless network.',
        );
      case NetworkStatus.cellular:
        return _StatusConfig(
          icon: Icons.signal_cellular_alt_rounded,
          label: 'Cellular',
          color: const Color(0xFF1565C0),
          description: 'Connected over the mobile data network.',
        );
      case NetworkStatus.offline:
        return _StatusConfig(
          icon: Icons.wifi_off_rounded,
          label: 'Offline',
          color: const Color(0xFFC62828),
          description: 'No active connection. New requests will queue.',
        );
    }
  }
}

class _StatusConfig {
  final IconData icon;
  final String label;
  final Color color;
  final String description;

  _StatusConfig({
    required this.icon,
    required this.label,
    required this.color,
    required this.description,
  });
}

class _LivePulse extends StatefulWidget {
  final Color color;
  const _LivePulse({required this.color});

  @override
  State<_LivePulse> createState() => _LivePulseState();
}

class _LivePulseState extends State<_LivePulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.35, end: 1.0).animate(_controller),
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}

class _RequestTile extends StatelessWidget {
  final QueuedRequest request;
  const _RequestTile({required this.request});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = _statusColor(request.status, scheme);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      request.label,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  _StatusChip(status: request.status, color: color),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Attempt ${request.attempts} · started at '
                '${_formatTime(request.createdAt)}',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: request.progress / 100,
                  minHeight: 8,
                  backgroundColor: scheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final RequestStatus status;
  final Color color;
  const _StatusChip({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    final (text, icon) = switch (status) {
      RequestStatus.inProgress => ('In Progress', Icons.sync_rounded),
      RequestStatus.queued => ('Queued', Icons.pause_circle_outline_rounded),
      RequestStatus.success => ('Success', Icons.check_circle_outline_rounded),
      RequestStatus.failed => ('Failed', Icons.error_outline_rounded),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

Color _statusColor(RequestStatus status, ColorScheme scheme) {
  switch (status) {
    case RequestStatus.inProgress:
      return scheme.primary;
    case RequestStatus.queued:
      return Colors.orange.shade800;
    case RequestStatus.success:
      return Colors.green.shade700;
    case RequestStatus.failed:
      return scheme.error;
  }
}

String _formatTime(DateTime time) {
  final h = time.hour.toString().padLeft(2, '0');
  final m = time.minute.toString().padLeft(2, '0');
  final s = time.second.toString().padLeft(2, '0');
  return '$h:$m:$s';
}

class _EventTile extends StatelessWidget {
  final NetworkEvent event;
  const _EventTile({required this.event});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final reconnect = event.to != NetworkStatus.offline;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor:
                reconnect ? scheme.secondaryContainer : scheme.errorContainer,
            child: Icon(
              reconnect ? Icons.swap_horiz_rounded : Icons.link_off_rounded,
              color: reconnect
                  ? scheme.onSecondaryContainer
                  : scheme.onErrorContainer,
            ),
          ),
          title: Text('${event.from.label} \u2192 ${event.to.label}'),
          subtitle: Text(_formatTime(event.timestamp)),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.cloud_queue_rounded, size: 36, color: scheme.primary),
            const SizedBox(height: 10),
            const Text(
              'No requests yet. Tap "New Request" to simulate a '
              'long-running dataset fetch.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
