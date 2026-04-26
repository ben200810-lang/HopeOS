import '../models/action_item.dart';
import '../models/capture_entry.dart';
import '../models/health_entry.dart';
import '../models/journal_entry.dart';
import '../models/mood_entry.dart';
import '../models/timeline_event.dart';
import '../../features/activity/data/activity_repository.dart';
import '../../features/activity/domain/activity_entry.dart';
import 'action_repository.dart';
import 'capture_repository.dart';
import 'health_repository.dart';
import 'journal_repository.dart';
import 'mood_repository.dart';

class TimelineRepository {
  final JournalRepository _journals = JournalRepository();
  final CaptureRepository _captures = CaptureRepository();
  final MoodRepository _moods = MoodRepository();
  final HealthRepository _health = HealthRepository();
  final ActionRepository _actions = ActionRepository();
  final ActivityRepository _activities = ActivityRepository();

  Future<List<TimelineEvent>> getAll() async {
    final results = await Future.wait([
      _journals.getAll(),
      _captures.getAll(),
      _moods.getAll(),
      _health.getRecent(30),
      _actions.getCompleted(),
      _activities.getAll(),
    ]);

    final journals = results[0] as List<JournalEntry>;
    final captures = results[1] as List<CaptureEntry>;
    final moods = results[2] as List<MoodEntry>;
    final healthEntries = results[3] as List<HealthEntry>;
    final completedActions = results[4] as List<ActionItem>;
    final activities = results[5] as List<ActivityEntry>;

    return _merge(
        journals, captures, moods, healthEntries, completedActions, activities);
  }

  Future<List<TimelineEvent>> getToday() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    final results = await Future.wait([
      _journals.getAll(),
      _captures.getToday(),
      _moods.getToday(),
      _health.getRecent(1),
      _actions.getCompleted(),
      _activities.getByDateRange(startOfDay, now),
    ]);

    final journals = (results[0] as List<JournalEntry>)
        .where((e) => e.createdAt.isAfter(startOfDay))
        .toList();
    final captures = results[1] as List<CaptureEntry>;
    final moods = results[2] as List<MoodEntry>;
    final healthEntries = results[3] as List<HealthEntry>;
    final completedActions = (results[4] as List<ActionItem>)
        .where((a) =>
            a.completedAt != null && a.completedAt!.isAfter(startOfDay))
        .toList();
    final activities = results[5] as List<ActivityEntry>;

    return _merge(
        journals, captures, moods, healthEntries, completedActions, activities);
  }

  List<TimelineEvent> _merge(
    List<JournalEntry> journals,
    List<CaptureEntry> captures,
    List<MoodEntry> moods,
    List<HealthEntry> healthEntries,
    List<ActionItem> completedActions,
    List<ActivityEntry> activities,
  ) {
    final events = <TimelineEvent>[];

    for (final j in journals) {
      events.add(TimelineEvent.fromJournalEntry(j));
    }

    for (final c in captures) {
      events.add(TimelineEvent.fromCaptureEntry(c));
    }

    for (final m in moods) {
      events.add(TimelineEvent.fromMoodEntry(m));
    }

    for (final h in healthEntries) {
      if (h.waterLiters > 0) {
        events.add(TimelineEvent.fromHealthWater(h));
      }
      if (h.sleepHours != null && h.sleepHours! > 0) {
        events.add(TimelineEvent.fromHealthSleep(h));
      }
      if (h.exerciseMinutes != null && h.exerciseMinutes! > 0) {
        events.add(TimelineEvent.fromHealthExercise(h));
      }
    }

    for (final a in completedActions) {
      events.add(TimelineEvent.fromCompletedAction(a));
    }

    for (final act in activities) {
      events.add(TimelineEvent.fromActivityEntry(act));
    }

    events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return events;
  }
}
