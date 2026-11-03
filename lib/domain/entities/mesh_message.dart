class MeshMessage {
  final String id;
  final String peerId;
  final String text;
  final bool isMine;
  final DateTime timestamp;

  const MeshMessage({
    required this.id,
    required this.peerId,
    required this.text,
    required this.isMine,
    required this.timestamp,
  });
}
