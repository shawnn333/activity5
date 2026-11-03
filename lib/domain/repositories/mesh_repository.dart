import '../entities/mesh_message.dart';
import '../entities/mesh_peer.dart';

abstract class MeshRepository {
  /// Fires whenever a peer is discovered, lost, or changes connection
  /// state (connecting, awaiting approval, connected, disconnected).
  Stream<MeshPeer> get peerUpdates;

  /// Fires for every text payload sent or received on any open socket.
  Stream<MeshMessage> get messages;

  /// Starts broadcasting this device's presence and scanning for others
  /// at the same time. Returns false if permissions were denied or the
  /// radios couldn't be started.
  Future<bool> startBroadcasting(String displayName);

  Future<void> stopBroadcasting();

  /// Sends a connection request to a discovered peer (the handshake).
  Future<void> requestConnection(String peerId, String displayName);

  /// Accepts an incoming connection request, completing the handshake.
  Future<void> acceptConnection(String peerId);

  Future<void> rejectConnection(String peerId);

  Future<void> disconnect(String peerId);

  /// Routes a text payload to [peerId] over the established socket.
  Future<void> sendMessage(String peerId, String text);

  void dispose();
}
