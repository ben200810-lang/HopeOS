class RescueEvent {
  final String id;
  final String action;
  final DateTime completedAt;

  const RescueEvent({
    required this.id,
    required this.action,
    required this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'action': action,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  factory RescueEvent.fromMap(Map<String, dynamic> map) {
    return RescueEvent(
      id: map['id'] as String,
      action: map['action'] as String,
      completedAt: DateTime.parse(map['completedAt'] as String),
    );
  }
}
