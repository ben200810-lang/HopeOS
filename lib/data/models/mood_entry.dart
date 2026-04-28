class MoodEntry {
  final String id;
  final int moodLevel; // 1-5
  final int energyLevel; // 1-10
  final String? note;
  final List<String> tags;
  final DateTime createdAt;

  MoodEntry({
    required this.id,
    required this.moodLevel,
    required this.energyLevel,
    this.note,
    this.tags = const [],
    required this.createdAt,
  });

  MoodEntry copyWith({
    String? id,
    int? moodLevel,
    int? energyLevel,
    String? note,
    List<String>? tags,
    DateTime? createdAt,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      moodLevel: moodLevel ?? this.moodLevel,
      energyLevel: energyLevel ?? this.energyLevel,
      note: note ?? this.note,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'moodLevel': moodLevel,
      'energyLevel': energyLevel,
      'note': note,
      'tags': tags.join(','),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id'] as String,
      moodLevel: map['moodLevel'] as int,
      energyLevel: map['energyLevel'] as int,
      note: map['note'] as String?,
      tags: (map['tags'] as String?)?.split(',').where((t) => t.isNotEmpty).toList() ?? [],
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  String get moodEmoji {
    switch (moodLevel) {
      case 1: return '😢';
      case 2: return '😔';
      case 3: return '😐';
      case 4: return '🙂';
      case 5: return '😊';
      default: return '😐';
    }
  }

  String get energyEmoji {
    if (energyLevel <= 2) return '😴';
    if (energyLevel <= 4) return '🪫';
    if (energyLevel <= 6) return '⚡';
    if (energyLevel <= 8) return '💪';
    return '🚀';
  }
}
