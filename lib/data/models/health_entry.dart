class HealthEntry {
  final String id;
  final double waterLiters;
  final double? sleepHours;
  final int? exerciseMinutes;
  final int? steps;
  final String? note;
  final DateTime date;
  final DateTime updatedAt;

  HealthEntry({
    required this.id,
    required this.waterLiters,
    this.sleepHours,
    this.exerciseMinutes,
    this.steps,
    this.note,
    required this.date,
    required this.updatedAt,
  });

  HealthEntry copyWith({
    String? id,
    double? waterLiters,
    double? sleepHours,
    int? exerciseMinutes,
    int? steps,
    String? note,
    DateTime? date,
    DateTime? updatedAt,
  }) {
    return HealthEntry(
      id: id ?? this.id,
      waterLiters: waterLiters ?? this.waterLiters,
      sleepHours: sleepHours ?? this.sleepHours,
      exerciseMinutes: exerciseMinutes ?? this.exerciseMinutes,
      steps: steps ?? this.steps,
      note: note ?? this.note,
      date: date ?? this.date,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'waterLiters': waterLiters,
      'sleepHours': sleepHours,
      'exerciseMinutes': exerciseMinutes,
      'steps': steps,
      'note': note,
      'date': date.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory HealthEntry.fromMap(Map<String, dynamic> map) {
    return HealthEntry(
      id: map['id'] as String,
      waterLiters: (map['waterLiters'] as num).toDouble(),
      sleepHours: (map['sleepHours'] as num?)?.toDouble(),
      exerciseMinutes: map['exerciseMinutes'] as int?,
      steps: map['steps'] as int?,
      note: map['note'] as String?,
      date: DateTime.parse(map['date'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  double get waterProgress => waterLiters / 2.5;
  double get sleepProgress => (sleepHours ?? 0) / 8.0;
  double get exerciseProgress => (exerciseMinutes ?? 0) / 30.0;
}
