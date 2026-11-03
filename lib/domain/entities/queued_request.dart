enum RequestStatus { inProgress, queued, success, failed }

class QueuedRequest {
  final String id;
  final String label;
  final DateTime createdAt;
  final RequestStatus status;
  final int attempts;
  final int progress;

  const QueuedRequest({
    required this.id,
    required this.label,
    required this.createdAt,
    required this.status,
    required this.attempts,
    required this.progress,
  });

  QueuedRequest copyWith({
    RequestStatus? status,
    int? attempts,
    int? progress,
  }) {
    return QueuedRequest(
      id: id,
      label: label,
      createdAt: createdAt,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      progress: progress ?? this.progress,
    );
  }
}
