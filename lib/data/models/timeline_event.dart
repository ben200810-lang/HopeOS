import 'package:flutter/material.dart';

import 'action_item.dart';
import 'capture_entry.dart';
import 'health_entry.dart';
import 'journal_entry.dart';
import 'mood_entry.dart';
import '../../features/activity/domain/activity_entry.dart';
import '../../features/rescue/rescue_event.dart';

enum TimelineEventType {
  journal,
  captureNote,
  captureVoice,
  captureEmotion,
  captureDrink,
  captureMeal,
  captureExpense,
  captureMoment,
  capturePhoto,
  moodLog,
  healthWater,
  healthSleep,
  healthExercise,
  actionCompleted,
  activity,
  rescue,
}

enum TimelineFilter {
  all,
  notes,
  finance,
  drinks,
  moodEnergy,
  sleep,
  activity,
  rescue,
}

class TimelineEvent {
  final String id;
  final TimelineEventType type;
  final String title;
  final String? subtitle;
  final String emoji;
  final IconData icon;
  final Color color;
  final DateTime timestamp;
  final bool isCompleted;
  final dynamic source;

  const TimelineEvent({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    required this.emoji,
    required this.icon,
    required this.color,
    required this.timestamp,
    this.isCompleted = false,
    this.source,
  });

  factory TimelineEvent.fromJournalEntry(JournalEntry entry) {
    final preview = entry.content.length > 80
        ? '${entry.content.substring(0, 80)}...'
        : entry.content;
    return TimelineEvent(
      id: 'journal_${entry.id}',
      type: TimelineEventType.journal,
      title: entry.title ?? 'Untitled note',
      subtitle: preview.isEmpty ? null : preview,
      emoji: '\u{1F4DD}',
      icon: Icons.book,
      color: Colors.teal,
      timestamp: entry.createdAt,
      source: entry,
    );
  }

  factory TimelineEvent.fromCaptureEntry(CaptureEntry entry, {String currencySymbol = '\$'}) {
    final type = _captureTypeToEventType(entry.type);
    return TimelineEvent(
      id: 'capture_${entry.id}',
      type: type,
      title: entry.formattedTitle(currencySymbol),
      subtitle: entry.text != null && entry.text!.isNotEmpty
          ? entry.preview
          : null,
      emoji: entry.typeEmoji,
      icon: _captureIcon(entry.type),
      color: _captureColor(entry.type),
      timestamp: entry.createdAt,
      isCompleted: entry.isCompleted,
      source: entry,
    );
  }

  factory TimelineEvent.fromMoodEntry(MoodEntry entry) {
    return TimelineEvent(
      id: 'mood_${entry.id}',
      type: TimelineEventType.moodLog,
      title: 'Mood: ${entry.moodEmoji}  Energy: ${entry.energyEmoji}',
      subtitle: entry.note,
      emoji: entry.moodEmoji,
      icon: Icons.mood,
      color: Colors.purple,
      timestamp: entry.createdAt,
      source: entry,
    );
  }

  factory TimelineEvent.fromHealthWater(HealthEntry entry) {
    return TimelineEvent(
      id: 'health_water_${entry.id}',
      type: TimelineEventType.healthWater,
      title: 'Water: ${entry.waterLiters.toStringAsFixed(1)}L',
      subtitle: null,
      emoji: '\u{1F4A7}',
      icon: Icons.water_drop,
      color: Colors.blue,
      timestamp: entry.updatedAt,
      source: entry,
    );
  }

  factory TimelineEvent.fromHealthSleep(HealthEntry entry) {
    return TimelineEvent(
      id: 'health_sleep_${entry.id}',
      type: TimelineEventType.healthSleep,
      title: 'Sleep: ${entry.sleepHours?.toStringAsFixed(1) ?? "0"}h',
      subtitle: null,
      emoji: '\u{1F634}',
      icon: Icons.bedtime,
      color: Colors.indigo,
      timestamp: entry.updatedAt,
      source: entry,
    );
  }

  factory TimelineEvent.fromHealthExercise(HealthEntry entry) {
    return TimelineEvent(
      id: 'health_exercise_${entry.id}',
      type: TimelineEventType.healthExercise,
      title: 'Exercise: ${entry.exerciseMinutes ?? 0} min',
      subtitle: null,
      emoji: '\u{1F3C3}',
      icon: Icons.directions_run,
      color: Colors.green,
      timestamp: entry.updatedAt,
      source: entry,
    );
  }

  factory TimelineEvent.fromCompletedAction(ActionItem action) {
    return TimelineEvent(
      id: 'action_${action.id}',
      type: TimelineEventType.actionCompleted,
      title: action.title,
      subtitle: action.description,
      emoji: '\u{2705}',
      icon: Icons.check_circle,
      color: Colors.green,
      timestamp: action.completedAt ?? action.createdAt,
      isCompleted: true,
      source: action,
    );
  }

  factory TimelineEvent.fromActivityEntry(ActivityEntry entry) {
    final stepsText = entry.steps != null ? '${entry.steps} steps' : null;
    final distText = entry.distanceMeters != null
        ? '${(entry.distanceMeters! / 1000).toStringAsFixed(1)} km'
        : null;
    final parts = [stepsText, distText].whereType<String>().join(' \u{00B7} ');

    return TimelineEvent(
      id: 'activity_${entry.id}',
      type: TimelineEventType.activity,
      title: '${entry.activityType}: ${entry.durationMinutes} min',
      subtitle: parts.isNotEmpty ? parts : null,
      emoji: '\u{1F3C3}',
      icon: Icons.fitness_center,
      color: Colors.orange,
      timestamp: entry.startTime,
      source: entry,
    );
  }

  factory TimelineEvent.fromRescueEvent(RescueEvent event) {
    return TimelineEvent(
      id: 'rescue_${event.id}',
      type: TimelineEventType.rescue,
      title: event.action,
      subtitle: 'Dopamine Rescue',
      emoji: '\u{1F525}',
      icon: Icons.flash_on,
      color: Colors.deepPurple,
      timestamp: event.completedAt,
      isCompleted: true,
      source: event,
    );
  }

  bool matchesFilter(TimelineFilter filter) {
    switch (filter) {
      case TimelineFilter.all:
        return true;
      case TimelineFilter.notes:
        return type == TimelineEventType.journal ||
            type == TimelineEventType.captureNote ||
            type == TimelineEventType.captureVoice ||
            type == TimelineEventType.captureMoment ||
            type == TimelineEventType.capturePhoto;
      case TimelineFilter.finance:
        return type == TimelineEventType.captureExpense;
      case TimelineFilter.drinks:
        return type == TimelineEventType.captureDrink ||
            type == TimelineEventType.healthWater;
      case TimelineFilter.moodEnergy:
        return type == TimelineEventType.moodLog ||
            type == TimelineEventType.captureEmotion;
      case TimelineFilter.sleep:
        return type == TimelineEventType.healthSleep;
      case TimelineFilter.activity:
        return type == TimelineEventType.activity ||
            type == TimelineEventType.healthExercise;
      case TimelineFilter.rescue:
        return type == TimelineEventType.rescue;
    }
  }

  static TimelineEventType _captureTypeToEventType(CaptureType captureType) {
    switch (captureType) {
      case CaptureType.note:
        return TimelineEventType.captureNote;
      case CaptureType.voice:
        return TimelineEventType.captureVoice;
      case CaptureType.emotion:
        return TimelineEventType.captureEmotion;
      case CaptureType.drink:
        return TimelineEventType.captureDrink;
      case CaptureType.meal:
        return TimelineEventType.captureMeal;
      case CaptureType.expense:
        return TimelineEventType.captureExpense;
      case CaptureType.moment:
        return TimelineEventType.captureMoment;
      case CaptureType.photo:
        return TimelineEventType.capturePhoto;
    }
  }

  static IconData _captureIcon(CaptureType type) {
    switch (type) {
      case CaptureType.note:
        return Icons.edit_note;
      case CaptureType.voice:
        return Icons.mic;
      case CaptureType.emotion:
        return Icons.mood;
      case CaptureType.drink:
        return Icons.water_drop;
      case CaptureType.meal:
        return Icons.restaurant;
      case CaptureType.expense:
        return Icons.receipt_long;
      case CaptureType.moment:
        return Icons.auto_awesome;
      case CaptureType.photo:
        return Icons.camera_alt;
    }
  }

  static Color _captureColor(CaptureType type) {
    switch (type) {
      case CaptureType.note:
        return Colors.teal;
      case CaptureType.voice:
        return Colors.deepPurple;
      case CaptureType.emotion:
        return Colors.amber;
      case CaptureType.drink:
        return Colors.blue;
      case CaptureType.meal:
        return Colors.orange;
      case CaptureType.expense:
        return Colors.red;
      case CaptureType.moment:
        return Colors.pink;
      case CaptureType.photo:
        return Colors.cyan;
    }
  }
}
