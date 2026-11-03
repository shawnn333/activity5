import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/diagnostic_result.dart';
import '../../../domain/entities/network_health.dart';
import '../../providers/diagnostic_provider.dart';

class Activity3Screen extends StatelessWidget {
  const Activity3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DiagnosticProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Activity 03')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 760;
            final contentWidth = wide ? 900.0 : double.infinity;
            final gridColumns = wide ? 3 : 2;

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
                      'LABORATORY ACTIVITY 03',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Network Diagnostic Dashboard',
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Runs idle ping, download and upload tests to score '
                      'connection health, then adapts the UI to match.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    _HealthCard(provider: provider),
                    const SizedBox(height: 28),
                    Text(
                      'Live Metrics',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 14),
                    _MetricsGrid(
                      result: provider.latest,
                      columns: gridColumns,
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Adaptive Media Preview',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'These cards re-render based on the current tier - '
                      'full previews when Excellent/Fair, lightweight '
                      'placeholders when Poor/Degraded.',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 14),
                    _AdaptiveMediaCard(
                      tier: provider.tier,
                      title: 'Product Gallery',
                      icon: Icons.image_outlined,
                    ),
                    const SizedBox(height: 12),
                    _AdaptiveMediaCard(
                      tier: provider.tier,
                      title: 'Featured Video',
                      icon: Icons.play_circle_outline_rounded,
                    ),
                    const SizedBox(height: 12),
                    _AdaptiveMediaCard(
                      tier: provider.tier,
                      title: 'Promo Banner',
                      icon: Icons.campaign_outlined,
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Diagnostic Log',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Every completed test run, most recent first.',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 14),
                    if (provider.history.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            'Running the first diagnostic pass...',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      )
                    else
                      ...provider.history.map((r) => _LogTile(result: r)),
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

class _HealthCard extends StatelessWidget {
  final DiagnosticProvider provider;
  const _HealthCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tier = provider.tier;
    final config = _tierConfig(tier);

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                        _LivePulse(
                          color: Colors.white,
                          active: provider.isRunning,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'NETWORK HEALTH',
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
                      tier?.label ?? 'Checking...',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tier?.description ??
                          'Running the first diagnostic pass.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (provider.isRunning) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                minHeight: 6,
                backgroundColor: Colors.white.withValues(alpha: 0.25),
                valueColor: const AlwaysStoppedAnimation(Colors.white),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.currentStep,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
          Row(
            children: [
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: config.color,
                ),
                onPressed: provider.isRunning ? null : provider.runNow,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Run Diagnostic Now'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Auto-refreshes every 20s',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _TierConfig _tierConfig(NetworkHealthTier? tier) {
    switch (tier) {
      case NetworkHealthTier.excellent:
        return _TierConfig(Icons.speed_rounded, const Color(0xFF2E7D32));
      case NetworkHealthTier.fair:
        return _TierConfig(
          Icons.network_check_rounded,
          const Color(0xFFB8860B),
        );
      case NetworkHealthTier.poor:
        return _TierConfig(
          Icons.signal_wifi_statusbar_connected_no_internet_4_rounded,
          const Color(0xFFEF6C00),
        );
      case NetworkHealthTier.degraded:
        return _TierConfig(
          Icons.report_gmailerrorred_rounded,
          const Color(0xFFC62828),
        );
      case null:
        return _TierConfig(Icons.hourglass_top_rounded, const Color(0xFF546E7A));
    }
  }
}

class _TierConfig {
  final IconData icon;
  final Color color;
  _TierConfig(this.icon, this.color);
}

class _LivePulse extends StatefulWidget {
  final Color color;
  final bool active;
  const _LivePulse({required this.color, required this.active});

  @override
  State<_LivePulse> createState() => _LivePulseState();
}

class _LivePulseState extends State<_LivePulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: widget.active
          ? Tween<double>(begin: 0.3, end: 1.0).animate(_controller)
          : const AlwaysStoppedAnimation(0.85),
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  final DiagnosticResult? result;
  final int columns;
  const _MetricsGrid({required this.result, required this.columns});

  @override
  Widget build(BuildContext context) {
    final metrics = <_Metric>[
      _Metric('Idle Ping', _fmtMs(result?.idlePingMs), Icons.timer_outlined),
      _Metric(
        'Download',
        _fmtMbps(result?.downloadMbps),
        Icons.download_rounded,
      ),
      _Metric(
        'Download Ping',
        _fmtMs(result?.downloadPingMs),
        Icons.arrow_downward_rounded,
      ),
      _Metric('Upload', _fmtMbps(result?.uploadMbps), Icons.upload_rounded),
      _Metric(
        'Upload Ping',
        _fmtMs(result?.uploadPingMs),
        Icons.arrow_upward_rounded,
      ),
      _Metric(
        'Packet Loss',
        result == null
            ? '--'
            : '${result!.packetLossPercent.toStringAsFixed(1)}%',
        Icons.warning_amber_rounded,
      ),
    ];

    return GridView.count(
      crossAxisCount: columns,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.7,
      children: metrics.map((m) => _MetricTile(metric: m)).toList(),
    );
  }

  String _fmtMs(double? v) => v == null ? '--' : '${v.toStringAsFixed(0)} ms';
  String _fmtMbps(double? v) =>
      v == null ? '--' : '${v.toStringAsFixed(1)} Mbps';
}

class _Metric {
  final String label;
  final String value;
  final IconData icon;
  _Metric(this.label, this.value, this.icon);
}

class _MetricTile extends StatelessWidget {
  final _Metric metric;
  const _MetricTile({required this.metric});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(metric.icon, size: 18, color: scheme.primary),
            const SizedBox(height: 8),
            Text(
              metric.value,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            Text(
              metric.label,
              style: theme.textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// This is the "dynamically adapt the UI" part of the objective: the same
/// card renders full detail on a good connection and collapses to a
/// minimal placeholder as the tier degrades, so no bandwidth is spent
/// rendering rich media the link can't comfortably carry.
class _AdaptiveMediaCard extends StatelessWidget {
  final NetworkHealthTier? tier;
  final String title;
  final IconData icon;

  const _AdaptiveMediaCard({
    required this.tier,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    switch (tier) {
      case NetworkHealthTier.excellent:
        return _mediaShell(
          theme,
          title,
          'High-resolution preview',
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [scheme.primary, scheme.primary.withValues(alpha: 0.55)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 42, color: Colors.white),
          ),
        );
      case NetworkHealthTier.fair:
        return _mediaShell(
          theme,
          title,
          'Standard quality',
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 32, color: scheme.onPrimaryContainer),
          ),
        );
      case NetworkHealthTier.poor:
        return _mediaShell(
          theme,
          title,
          'Data-saver preview',
          Container(
            height: 56,
            decoration: BoxDecoration(
              border: Border.all(color: scheme.outlineVariant),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 22, color: scheme.outline),
          ),
        );
      case NetworkHealthTier.degraded:
      case null:
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(Icons.cloud_off_rounded, size: 20, color: scheme.error),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '$title - media paused to save data',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }

  Widget _mediaShell(
    ThemeData theme,
    String title,
    String subtitle,
    Widget media,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            media,
            const SizedBox(height: 10),
            Text(
              title,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(subtitle, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  final DiagnosticResult result;
  const _LogTile({required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = _tierColor(result.tier, scheme);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(Icons.insights_rounded, color: color),
          ),
          title: Text(
            '${result.tier.label} · '
            '${result.downloadMbps.toStringAsFixed(1)} Mbps down',
          ),
          subtitle: Text(
            '${_formatTime(result.timestamp)} · '
            'ping ${result.idlePingMs.toStringAsFixed(0)}ms · '
            'loss ${result.packetLossPercent.toStringAsFixed(1)}%',
          ),
        ),
      ),
    );
  }

  Color _tierColor(NetworkHealthTier tier, ColorScheme scheme) {
    switch (tier) {
      case NetworkHealthTier.excellent:
        return Colors.green.shade700;
      case NetworkHealthTier.fair:
        return Colors.amber.shade800;
      case NetworkHealthTier.poor:
        return Colors.orange.shade800;
      case NetworkHealthTier.degraded:
        return scheme.error;
    }
  }

  String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    final s = time.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}
