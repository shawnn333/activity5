import '../entities/mesh_message.dart';
import '../entities/mesh_peer.dart';
import '../repositories/mesh_repository.dart';

class MeshUseCase {
  final MeshRepository repository;

  MeshUseCase(this.repository);

  Stream<MeshPeer> get peerUpdates => repository.peerUpdates;
  Stream<MeshMessage> get messages => repository.messages;

  Future<bool> startBroadcasting(String displayName) =>
      repository.startBroadcasting(displayName);

  Future<void> stopBroadcasting() => repository.stopBroadcasting();

  Future<void> requestConnection(String peerId, String displayName) =>
      repository.requestConnection(peerId, displayName);

  Future<void> acceptConnection(String peerId) =>
      repository.acceptConnection(peerId);

  Future<void> rejectConnection(String peerId) =>
      repository.rejectConnection(peerId);

  Future<void> disconnect(String peerId) => repository.disconnect(peerId);

  Future<void> sendMessage(String peerId, String text) =>
      repository.sendMessage(peerId, text);

  void dispose() => repository.dispose();
}
