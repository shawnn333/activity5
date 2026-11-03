import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/mesh_message.dart';
import '../../domain/entities/mesh_peer.dart';
import '../../domain/usecases/mesh_usecase.dart';

/// Holds everything the Local Mesh Chat screen needs: whether this device
/// is currently broadcasting/scanning, the list of discovered/connected
/// peers, and a running message thread per peer. The screens underneath
/// are pure `UI = f(state)` - they just render whatever this provider
/// currently holds and call back into it on user action.
class MeshChatProvider extends ChangeNotifier {
  final MeshUseCase useCase;

  StreamSubscription<MeshPeer>? _peerSub;
  StreamSubscription<MeshMessage>? _messageSub;

  String displayName = 'Device-${DateTime.now().millisecond}';
  bool isBroadcasting = false;
  bool isStarting = false;
  String? errorMessage;

  final Map<String, MeshPeer> _peers = {};
  final Map<String, List<MeshMessage>> _threads = {};

  MeshChatProvider(this.useCase) {
    _peerSub = useCase.peerUpdates.listen(_onPeerUpdate);
    _messageSub = useCase.messages.listen(_onMessage);
  }

  List<MeshPeer> get peers => _peers.values.toList()
    ..sort((a, b) => a.name.compareTo(b.name));

  List<MeshMessage> threadFor(String peerId) =>
      List.unmodifiable(_threads[peerId] ?? const []);

  MeshPeer? peerById(String peerId) => _peers[peerId];

  void setDisplayName(String name) {
    if (name.trim().isEmpty) return;
    displayName = name.trim();
    notifyListeners();
  }

  Future<void> startMesh() async {
    if (isBroadcasting || isStarting) return;
    isStarting = true;
    errorMessage = null;
    notifyListeners();

    final ok = await useCase.startBroadcasting(displayName);

    isStarting = false;
    isBroadcasting = ok;
    if (!ok) {
      errorMessage =
          'Could not start broadcasting. Check that Bluetooth and '
          'Location are on and permissions are granted.';
    }
    notifyListeners();
  }

  Future<void> stopMesh() async {
    await useCase.stopBroadcasting();
    isBroadcasting = false;
    notifyListeners();
  }

  Future<void> connectTo(MeshPeer peer) {
    return useCase.requestConnection(peer.id, displayName);
  }

  Future<void> accept(String peerId) => useCase.acceptConnection(peerId);

  Future<void> reject(String peerId) => useCase.rejectConnection(peerId);

  Future<void> disconnect(String peerId) => useCase.disconnect(peerId);

  Future<void> sendMessage(String peerId, String text) {
    if (text.trim().isEmpty) return Future.value();
    return useCase.sendMessage(peerId, text.trim());
  }

  void _onPeerUpdate(MeshPeer peer) {
    _peers[peer.id] = peer;
    notifyListeners();
  }

  void _onMessage(MeshMessage message) {
    final thread = _threads.putIfAbsent(message.peerId, () => []);
    thread.add(message);
    notifyListeners();
  }

  @override
  void dispose() {
    _peerSub?.cancel();
    _messageSub?.cancel();
    useCase.dispose();
    super.dispose();
  }
}
