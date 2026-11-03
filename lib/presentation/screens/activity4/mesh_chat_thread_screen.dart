import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/mesh_message.dart';
import '../../../domain/entities/mesh_peer.dart';
import '../../providers/mesh_chat_provider.dart';

/// Pure `UI = f(state)`: this screen holds no message state of its own.
/// Every bubble on screen is derived straight from
/// `MeshChatProvider.threadFor(peerId)`, so sending or receiving a
/// payload just updates the provider and the screen rebuilds to match.
class MeshChatThreadScreen extends StatefulWidget {
  final String peerId;
  final String peerName;

  const MeshChatThreadScreen({
    super.key,
    required this.peerId,
    required this.peerName,
  });

  @override
  State<MeshChatThreadScreen> createState() => _MeshChatThreadScreenState();
}

class _MeshChatThreadScreenState extends State<MeshChatThreadScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send(MeshChatProvider provider) {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    provider.sendMessage(widget.peerId, text);
    _controller.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MeshChatProvider>();
    final messages = provider.threadFor(widget.peerId);
    final peer = provider.peerById(widget.peerId);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.peerName),
            if (peer != null)
              Text(
                peer.status.label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.appBarTheme.foregroundColor?.withValues(alpha: 0.75),
                ),
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Text(
                      'No messages yet. Say hello!',
                      style: theme.textTheme.bodyMedium,
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) =>
                        _MessageBubble(message: messages[index]),
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(provider),
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: () => _send(provider),
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MeshMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final align = message.isMine ? Alignment.centerRight : Alignment.centerLeft;
    final color = message.isMine ? scheme.primary : scheme.surfaceContainerHighest;
    final textColor = message.isMine ? scheme.onPrimary : scheme.onSurface;

    return Align(
      alignment: align,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.isMine ? 16 : 4),
            bottomRight: Radius.circular(message.isMine ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message.text, style: TextStyle(color: textColor)),
            const SizedBox(height: 2),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                color: textColor.withValues(alpha: 0.7),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
