import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../domain/entities/mesh_message.dart';
import '../../domain/entities/mesh_peer.dart';
import '../../domain/repositories/mesh_repository.dart';

/// Wraps Google's Nearby Connections API (via the `nearby_connections`
/// plugin) to broadcast this device's presence, discover others over
/// Bluetooth/Wi-Fi, run the connection handshake, and route byte
/// payloads once a socket is open - all without any internet access or
/// central server. Android only; the plugin has no iOS/web backend, and
/// the emulator cannot discover real peers, so this needs two physical
/// Android devices to actually test.
class MeshRepositoryImpl implements MeshRepository {
  /// Identifies this app to other instances of itself during discovery.
  /// Two devices only find each other if they share the same service ID
  /// and are both running compatible advertise/discover calls.
  static const _serviceId = 'com.labactivitymaster.meshchat';

  /// P2P_STAR lets one advertiser accept connections from many
  /// discoverers at once, which fits a simple group chat screen.
  static const _strategy = Strategy.P2P_STAR;

  final StreamController<MeshPeer> _peerController =
      StreamController<MeshPeer>.broadcast();
  final StreamController<MeshMessage> _messageController =
      StreamController<MeshMessage>.broadcast();
  final Map<String, String> _peerNames = {};

  @override
  Stream<MeshPeer> get peerUpdates => _peerController.stream;

  @override
  Stream<MeshMessage> get messages => _messageController.stream;

  @override
  Future<bool> startBroadcasting(String displayName) async {
    final granted = await _ensurePermissions();
    if (!granted) return false;

    bool advertiseOk = false;
    bool discoverOk = false;

    try {
      advertiseOk = await Nearby().startAdvertising(
        displayName,
        _strategy,
        serviceId: _serviceId,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
      );

      discoverOk = await Nearby().startDiscovery(
        displayName,
        _strategy,
        serviceId: _serviceId,
        onEndpointFound: (id, name, serviceId) {
          _peerNames[id] = name;
          _peerController.add(
            MeshPeer(
              id: id,
              name: name,
              status: MeshConnectionStatus.discovered,
            ),
          );
        },
        onEndpointLost: (id) {
          if (id == null) return;
          _peerController.add(
            MeshPeer(
              id: id,
              name: _peerNames[id] ?? id,
              status: MeshConnectionStatus.disconnected,
            ),
          );
        },
      );
    } catch (_) {
      // Platform exceptions here are almost always "Bluetooth is off" or
      // "insufficient permissions" - surfaced to the UI as a plain
      // failure to start rather than a crash.
      return false;
    }

    return advertiseOk && discoverOk;
  }

  @override
  Future<void> stopBroadcasting() async {
    await Nearby().stopAdvertising();
    await Nearby().stopDiscovery();
  }

  @override
  Future<void> requestConnection(String peerId, String displayName) async {
    _peerController.add(
      MeshPeer(
        id: peerId,
        name: _peerNames[peerId] ?? peerId,
        status: MeshConnectionStatus.connecting,
      ),
    );
    await Nearby().requestConnection(
      displayName,
      peerId,
      onConnectionInitiated: _onConnectionInitiated,
      onConnectionResult: _onConnectionResult,
      onDisconnected: _onDisconnected,
    );
  }

  @override
  Future<void> acceptConnection(String peerId) async {
    await Nearby().acceptConnection(
      peerId,
      onPayLoadRecieved: (endpointId, payload) {
        if (payload.type == PayloadType.BYTES && payload.bytes != null) {
          _messageController.add(
            MeshMessage(
              id: '${endpointId}_${DateTime.now().microsecondsSinceEpoch}',
              peerId: endpointId,
              text: utf8.decode(payload.bytes!),
              isMine: false,
              timestamp: DateTime.now(),
            ),
          );
        }
      },
    );
  }

  @override
  Future<void> rejectConnection(String peerId) async {
    await Nearby().rejectConnection(peerId);
  }

  @override
  Future<void> disconnect(String peerId) async {
    await Nearby().disconnectFromEndpoint(peerId);
    _peerController.add(
      MeshPeer(
        id: peerId,
        name: _peerNames[peerId] ?? peerId,
        status: MeshConnectionStatus.disconnected,
      ),
    );
  }

  @override
  Future<void> sendMessage(String peerId, String text) async {
    await Nearby().sendBytesPayload(
      peerId,
      Uint8List.fromList(utf8.encode(text)),
    );
    _messageController.add(
      MeshMessage(
        id: '${peerId}_${DateTime.now().microsecondsSinceEpoch}_me',
        peerId: peerId,
        text: text,
        isMine: true,
        timestamp: DateTime.now(),
      ),
    );
  }

  void _onConnectionInitiated(String id, ConnectionInfo info) {
    _peerNames[id] = info.endpointName;
    _peerController.add(
      MeshPeer(
        id: id,
        name: info.endpointName,
        status: MeshConnectionStatus.awaitingApproval,
      ),
    );
  }

  void _onConnectionResult(String id, Status status) {
    _peerController.add(
      MeshPeer(
        id: id,
        name: _peerNames[id] ?? id,
        status: status == Status.CONNECTED
            ? MeshConnectionStatus.connected
            : MeshConnectionStatus.rejected,
      ),
    );
  }

  void _onDisconnected(String id) {
    _peerController.add(
      MeshPeer(
        id: id,
        name: _peerNames[id] ?? id,
        status: MeshConnectionStatus.disconnected,
      ),
    );
  }

  /// Nearby Connections needs Location plus the Android 12+ runtime
  /// Bluetooth permissions. Declaring them in the manifest isn't enough -
  /// they have to be requested at runtime too.
  Future<bool> _ensurePermissions() async {
    final statuses = await [
      Permission.location,
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
    ].request();

    return statuses.values.every(
      (status) => status.isGranted || status.isLimited,
    );
  }

  @override
  void dispose() {
    _peerController.close();
    _messageController.close();
  }
}
