class ActionItem {
  final String id;
  final String title;
  final String? description;
  final String category; // 'mental', 'health', 'journal', 'custom'
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int priority; // 1=high, 2=medium, 3=low
  final bool isRecurring;
  final String? recurringPattern; // 'daily', 'weekly'

  ActionItem({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
    this.priority = 2,
    this.isRecurring = false,
    this.recurringPattern,
  });

  ActionItem copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
    int? priority,
    bool? isRecurring,
    String? recurringPattern,
  }) {
    return ActionItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      priority: priority ?? this.priority,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPattern: recurringPattern ?? this.recurringPattern,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'isCompleted': isCompleted ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'priority': priority,
      'isRecurring': isRecurring ? 1 : 0,
      'recurringPattern': recurringPattern,
    };
  }

  factory ActionItem.fromMap(Map<String, dynamic> map) {
    return ActionItem(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      category: map['category'] as String,
      isCompleted: (map['isCompleted'] as int) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'] as String)
          : null,
      priority: map['priority'] as int,
      isRecurring: (map['isRecurring'] as int) == 1,
      recurringPattern: map['recurringPattern'] as String?,
    );
  }
}
