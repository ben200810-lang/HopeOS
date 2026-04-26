import 'dart:convert';

const _sentinel = Object();

enum CaptureType {
  note,
  voice,
  emotion,
  drink,
  meal,
  expense,
  moment,
  photo,
}

class CaptureEntry {
  final String id;
  final CaptureType type;
  final String? text;
  final String? audioPath;
  final String? imagePath;
  final double? amount;
  final String? category;
  final int? moodLevel;
  final int? energyLevel;
  final Map<String, dynamic>? metadata;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  CaptureEntry({
    required this.id,
    required this.type,
    this.text,
    this.audioPath,
    this.imagePath,
    this.amount,
    this.category,
    this.moodLevel,
    this.energyLevel,
    this.metadata,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  CaptureEntry copyWith({
    String? id,
    CaptureType? type,
    Object? text = _sentinel,
    Object? audioPath = _sentinel,
    Object? imagePath = _sentinel,
    Object? amount = _sentinel,
    Object? category = _sentinel,
    Object? moodLevel = _sentinel,
    Object? energyLevel = _sentinel,
    Object? metadata = _sentinel,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CaptureEntry(
      id: id ?? this.id,
      type: type ?? this.type,
      text: text == _sentinel ? this.text : text as String?,
      audioPath: audioPath == _sentinel ? this.audioPath : audioPath as String?,
      imagePath: imagePath == _sentinel ? this.imagePath : imagePath as String?,
      amount: amount == _sentinel ? this.amount : amount as double?,
      category: category == _sentinel ? this.category : category as String?,
      moodLevel: moodLevel == _sentinel ? this.moodLevel : moodLevel as int?,
      energyLevel:
          energyLevel == _sentinel ? this.energyLevel : energyLevel as int?,
      metadata: metadata == _sentinel
          ? this.metadata
          : metadata as Map<String, dynamic>?,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'text': text,
      'audioPath': audioPath,
      'imagePath': imagePath,
      'amount': amount,
      'category': category,
      'moodLevel': moodLevel,
      'energyLevel': energyLevel,
      'metadata': metadata != null ? jsonEncode(metadata) : null,
      'isCompleted': isCompleted ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CaptureEntry.fromMap(Map<String, dynamic> map) {
    return CaptureEntry(
      id: map['id'] as String,
      type: CaptureType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => CaptureType.note,
      ),
      text: map['text'] as String?,
      audioPath: map['audioPath'] as String?,
      imagePath: map['imagePath'] as String?,
      amount: (map['amount'] as num?)?.toDouble(),
      category: map['category'] as String?,
      moodLevel: map['moodLevel'] as int?,
      energyLevel: map['energyLevel'] as int?,
      metadata: _parseMetadata(map['metadata'] as String?),
      isCompleted: (map['isCompleted'] as int?) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  static Map<String, dynamic>? _parseMetadata(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      // Backwards compatibility: try legacy key=value|key=value format
      final map = <String, dynamic>{};
      for (final pair in raw.split('|')) {
        final idx = pair.indexOf('=');
        if (idx > 0) {
          map[pair.substring(0, idx)] = pair.substring(idx + 1);
        }
      }
      return map.isEmpty ? null : map;
    }
  }

  String get displayTitle {
    switch (type) {
      case CaptureType.note:
        return text ?? 'Note';
      case CaptureType.voice:
        return 'Voice note';
      case CaptureType.emotion:
        return 'Feeling: ${_moodEmoji(moodLevel ?? 3)}';
      case CaptureType.drink:
        final ml = ((amount ?? 0) * 1000).round();
        return 'Drink: ${ml}ml';
      case CaptureType.meal:
        return text ?? 'Meal';
      case CaptureType.expense:
        final cat = category ?? 'General';
        return 'Expense: \$${(amount ?? 0).toStringAsFixed(2)} ($cat)';
      case CaptureType.moment:
        return text ?? 'Moment';
      case CaptureType.photo:
        return text ?? 'Photo';
    }
  }

  String get preview {
    final t = text ?? '';
    if (t.length <= 80) return t;
    return '${t.substring(0, 80)}...';
  }

  String get typeEmoji {
    switch (type) {
      case CaptureType.note:
        return '📝';
      case CaptureType.voice:
        return '🎙️';
      case CaptureType.emotion:
        return _moodEmoji(moodLevel ?? 3);
      case CaptureType.drink:
        return '💧';
      case CaptureType.meal:
        return '🍽️';
      case CaptureType.expense:
        return '💰';
      case CaptureType.moment:
        return '✨';
      case CaptureType.photo:
        return '📷';
    }
  }

  static String _moodEmoji(int level) {
    switch (level) {
      case 1:
        return '😢';
      case 2:
        return '😔';
      case 3:
        return '😐';
      case 4:
        return '😊';
      case 5:
        return '😄';
      default:
        return '😐';
    }
  }
}
