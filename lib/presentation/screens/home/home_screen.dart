import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/routes/app_routes.dart';
import '../../../domain/entities/network_health.dart';
import '../../providers/diagnostic_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/activity_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final diagnostics = context.watch<DiagnosticProvider>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'LAB ACTIVITY MASTER',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        actions: [
          _NetworkHealthBadge(tier: diagnostics.tier),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Settings',
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 760;
            final contentWidth = wide ? 900.0 : double.infinity;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentWidth),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    wide ? 32 : 20,
                    12,
                    wide ? 32 : 20,
                    32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              scheme.primary,
                              scheme.primary.withValues(alpha: 0.78),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(11),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.school_outlined,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Hello, ${settings.userName}.',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your central space for laboratory activities.',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withValues(alpha: 0.88),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Laboratory Activities',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Select an activity to continue.',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 18),
                      if (wide)
                        Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: ActivityCard(
                                    number: '01',
                                    title: 'Laboratory Activity 1',
                                    description:
                                        'Workspace for your first laboratory activity.',
                                    icon: Icons.looks_one_outlined,
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      AppRoutes.activity1,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ActivityCard(
                                    number: '02',
                                    title: 'Laboratory Activity 2',
                                    description:
                                        'Network Monitor: live Wi-Fi/Cellular status with handover-safe request queuing.',
                                    icon: Icons.wifi_tethering_outlined,
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      AppRoutes.activity2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ActivityCard(
                                    number: '03',
                                    title: 'Laboratory Activity 3',
                                    description:
                                        'Network Diagnostic Dashboard: speed/ping scoring that adapts the UI in real time.',
                                    icon: Icons.speed_outlined,
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      AppRoutes.activity3,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ActivityCard(
                                    number: '04',
                                    title: 'Laboratory Activity 4',
                                    description:
                                        'Local Mesh Chat: offline peer-to-peer discovery and messaging over Nearby Connections.',
                                    icon: Icons.device_hub_outlined,
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      AppRoutes.activity4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ActivityCard(
                                    number: '05',
                                    title: 'Laboratory Activity 5',
                                    description:
                                        'Custom Map & Geofence: five of your own spots with enter/exit tracking.',
                                    icon: Icons.pin_drop_outlined,
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      AppRoutes.activity5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Expanded(child: SizedBox()),
                              ],
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            ActivityCard(
                              number: '01',
                              title: 'Laboratory Activity 1',
                              description:
                                  'Workspace for your first laboratory activity.',
                              icon: Icons.looks_one_outlined,
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.activity1,
                              ),
                            ),
                            const SizedBox(height: 14),
                            ActivityCard(
                              number: '02',
                              title: 'Laboratory Activity 2',
                              description:
                                  'Network Monitor: live Wi-Fi/Cellular status with handover-safe request queuing.',
                              icon: Icons.wifi_tethering_outlined,
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.activity2,
                              ),
                            ),
                            const SizedBox(height: 14),
                            ActivityCard(
                              number: '03',
                              title: 'Laboratory Activity 3',
                              description:
                                  'Network Diagnostic Dashboard: speed/ping scoring that adapts the UI in real time.',
                              icon: Icons.speed_outlined,
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.activity3,
                              ),
                            ),
                            const SizedBox(height: 14),
                            ActivityCard(
                              number: '04',
                              title: 'Laboratory Activity 4',
                              description:
                                  'Local Mesh Chat: offline peer-to-peer discovery and messaging over Nearby Connections.',
                              icon: Icons.device_hub_outlined,
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.activity4,
                              ),
                            ),
                            const SizedBox(height: 14),
                            ActivityCard(
                              number: '05',
                              title: 'Laboratory Activity 5',
                              description:
                                  'Custom Map & Geofence: five of your own spots with enter/exit tracking.',
                              icon: Icons.pin_drop_outlined,
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.activity5,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 28),
                      Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 6,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: scheme.secondaryContainer,
                            child: Icon(
                              Icons.settings_outlined,
                              color: scheme.onSecondaryContainer,
                            ),
                          ),
                          title: const Text(
                            'Settings',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: const Text('Appearance and profile'),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.settings,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Small chip in the home AppBar that reads the current tier straight from
/// [DiagnosticProvider] - proof that the network-health state set on the
/// Activity 3 screen really is global app state, not local to that screen.
class _NetworkHealthBadge extends StatelessWidget {
  final NetworkHealthTier? tier;
  const _NetworkHealthBadge({required this.tier});

  @override
  Widget build(BuildContext context) {
    final color = _color(tier);
    return Tooltip(
      message: tier == null
          ? 'Checking network health...'
          : 'Network health: ${tier!.label}',
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 14),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              tier?.label ?? '...',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _color(NetworkHealthTier? tier) {
    switch (tier) {
      case NetworkHealthTier.excellent:
        return Colors.green.shade700;
      case NetworkHealthTier.fair:
        return Colors.amber.shade800;
      case NetworkHealthTier.poor:
        return Colors.orange.shade800;
      case NetworkHealthTier.degraded:
        return Colors.red.shade700;
      case null:
        return Colors.blueGrey;
    }
  }
}
