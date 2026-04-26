class ActivityEntry {
  final String id;
  final String activityType;
  final int durationMinutes;
  final int? steps;
  final double? distanceMeters;
  final int? caloriesBurned;
  final String source;
  final DateTime startTime;
  final DateTime? endTime;
  final DateTime createdAt;

  ActivityEntry({
    required this.id,
    required this.activityType,
    required this.durationMinutes,
    this.steps,
    this.distanceMeters,
    this.caloriesBurned,
    this.source = 'manual',
    required this.startTime,
    this.endTime,
    required this.createdAt,
  });

  ActivityEntry copyWith({
    String? id,
    String? activityType,
    int? durationMinutes,
    int? steps,
    double? distanceMeters,
    int? caloriesBurned,
    String? source,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? createdAt,
  }) {
    return ActivityEntry(
      id: id ?? this.id,
      activityType: activityType ?? this.activityType,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      steps: steps ?? this.steps,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      source: source ?? this.source,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'activityType': activityType,
      'durationMinutes': durationMinutes,
      'steps': steps,
      'distanceMeters': distanceMeters,
      'caloriesBurned': caloriesBurned,
      'source': source,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ActivityEntry.fromMap(Map<String, dynamic> map) {
    return ActivityEntry(
      id: map['id'] as String,
      activityType: map['activityType'] as String,
      durationMinutes: map['durationMinutes'] as int,
      steps: map['steps'] as int?,
      distanceMeters: (map['distanceMeters'] as num?)?.toDouble(),
      caloriesBurned: map['caloriesBurned'] as int?,
      source: (map['source'] as String?) ?? 'manual',
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: map['endTime'] != null
          ? DateTime.parse(map['endTime'] as String)
          : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
