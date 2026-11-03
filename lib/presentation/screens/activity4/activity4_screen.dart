import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/mesh_peer.dart';
import '../../providers/mesh_chat_provider.dart';
import 'mesh_chat_thread_screen.dart';

class Activity4Screen extends StatefulWidget {
  const Activity4Screen({super.key});

  @override
  State<Activity4Screen> createState() => _Activity4ScreenState();
}

class _Activity4ScreenState extends State<Activity4Screen> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final provider = context.read<MeshChatProvider>();
    _nameController = TextEditingController(text: provider.displayName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MeshChatProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Activity 04')),
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
                      'LABORATORY ACTIVITY 04',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Local Mesh Chat',
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Discovers nearby devices over Bluetooth/Wi-Fi and '
                      'chats with them directly - no internet, no server.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 14),
                    _InfoBanner(theme: theme),
                    const SizedBox(height: 20),
                    _BroadcastCard(
                      provider: provider,
                      nameController: _nameController,
                    ),
                    if (provider.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      _ErrorBanner(message: provider.errorMessage!),
                    ],
                    const SizedBox(height: 28),
                    Text(
                      'Nearby Devices',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      provider.isBroadcasting
                          ? 'Scanning continuously while the mesh is on.'
                          : 'Start the mesh to begin discovering devices.',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 14),
                    if (provider.peers.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            provider.isBroadcasting
                                ? 'Searching for nearby devices...'
                                : 'No devices yet. Tap "Start Mesh" above.',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      )
                    else
                      ...provider.peers.map(
                        (peer) => _PeerTile(peer: peer, provider: provider),
                      ),
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

class _InfoBanner extends StatelessWidget {
  final ThemeData theme;
  const _InfoBanner({required this.theme});

  @override
  Widget build(BuildContext context) {
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: scheme.secondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Android devices only. Needs two physical phones with '
              'Bluetooth and Location turned on - the emulator can\'t '
              'discover real peers.',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, size: 18, color: scheme.onErrorContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: scheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _BroadcastCard extends StatelessWidget {
  final MeshChatProvider provider;
  final TextEditingController nameController;
  const _BroadcastCard({required this.provider, required this.nameController});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = provider.isBroadcasting ? Colors.green.shade700 : scheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
                provider.isBroadcasting
                    ? Icons.podcasts_rounded
                    : Icons.podcasts_outlined,
                color: Colors.white,
                size: 26,
              ),
              const SizedBox(width: 10),
              Text(
                provider.isBroadcasting ? 'Mesh is ON' : 'Mesh is OFF',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: nameController,
            enabled: !provider.isBroadcasting,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Your display name',
              labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: provider.setDisplayName,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: color,
            ),
            onPressed: provider.isStarting
                ? null
                : () {
                    provider.setDisplayName(nameController.text);
                    if (provider.isBroadcasting) {
                      provider.stopMesh();
                    } else {
                      provider.startMesh();
                    }
                  },
            icon: provider.isStarting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    provider.isBroadcasting
                        ? Icons.stop_circle_outlined
                        : Icons.play_circle_outline_rounded,
                  ),
            label: Text(
              provider.isStarting
                  ? 'Starting...'
                  : provider.isBroadcasting
                      ? 'Stop Mesh'
                      : 'Start Mesh',
            ),
          ),
        ],
      ),
    );
  }
}

class _PeerTile extends StatelessWidget {
  final MeshPeer peer;
  final MeshChatProvider provider;
  const _PeerTile({required this.peer, required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: scheme.primaryContainer,
            child: Icon(Icons.smartphone_rounded, color: scheme.onPrimaryContainer),
          ),
          title: Text(peer.name, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(peer.status.label),
          trailing: _actionFor(context),
        ),
      ),
    );
  }

  Widget _actionFor(BuildContext context) {
    switch (peer.status) {
      case MeshConnectionStatus.discovered:
        return FilledButton(
          onPressed: () => provider.connectTo(peer),
          child: const Text('Connect'),
        );
      case MeshConnectionStatus.connecting:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case MeshConnectionStatus.awaitingApproval:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Reject',
              onPressed: () => provider.reject(peer.id),
              icon: const Icon(Icons.close_rounded),
            ),
            IconButton(
              tooltip: 'Accept',
              onPressed: () => provider.accept(peer.id),
              icon: const Icon(Icons.check_rounded),
            ),
          ],
        );
      case MeshConnectionStatus.connected:
        return TextButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MeshChatThreadScreen(
                peerId: peer.id,
                peerName: peer.name,
              ),
            ),
          ),
          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
          label: const Text('Open Chat'),
        );
      case MeshConnectionStatus.rejected:
      case MeshConnectionStatus.disconnected:
        return OutlinedButton(
          onPressed: () => provider.connectTo(peer),
          child: const Text('Retry'),
        );
    }
  }
}
