enum MeshConnectionStatus {
  discovered,
  connecting,
  awaitingApproval,
  connected,
  rejected,
  disconnected,
}

extension MeshConnectionStatusX on MeshConnectionStatus {
  String get label {
    switch (this) {
      case MeshConnectionStatus.discovered:
        return 'Found';
      case MeshConnectionStatus.connecting:
        return 'Connecting';
      case MeshConnectionStatus.awaitingApproval:
        return 'Wants to connect';
      case MeshConnectionStatus.connected:
        return 'Connected';
      case MeshConnectionStatus.rejected:
        return 'Rejected';
      case MeshConnectionStatus.disconnected:
        return 'Disconnected';
    }
  }
}

class MeshPeer {
  final String id;
  final String name;
  final MeshConnectionStatus status;

  const MeshPeer({
    required this.id,
    required this.name,
    required this.status,
  });

  MeshPeer copyWith({String? name, MeshConnectionStatus? status}) {
    return MeshPeer(
      id: id,
      name: name ?? this.name,
      status: status ?? this.status,
    );
  }
}
