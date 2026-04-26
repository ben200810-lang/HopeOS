import 'dart:math' as math;
import '../../data/models/timeline_event.dart';

class DetectedPattern {
  final String id;
  final String titleEn;
  final String titleHu;
  final String descriptionEn;
  final String descriptionHu;
  final double confidence;
  final PatternCategory category;
  final IconType icon;

  const DetectedPattern({
    required this.id,
    required this.titleEn,
    required this.titleHu,
    required this.descriptionEn,
    required this.descriptionHu,
    required this.confidence,
    required this.category,
    this.icon = IconType.info,
  });

  String title(String locale) => locale == 'hu' ? titleHu : titleEn;
  String description(String locale) => locale == 'hu' ? descriptionHu : descriptionEn;
}

enum PatternCategory { sleep, hydration, spending, activity, mood }

enum IconType { sleep, water, money, activity, mood, info }

class PatternEngine {
  List<DetectedPattern> analyze(List<TimelineEvent> events) {
    if (events.length < 5) return [];

    final patterns = <DetectedPattern>[];

    _analyzeLateSleepCycles(events, patterns);
    _analyzeLowHydrationMornings(events, patterns);
    _analyzeImpulsiveSpending(events, patterns);
    _analyzeNightNoteActivity(events, patterns);
    _analyzeEnergyCrashes(events, patterns);

    patterns.sort((a, b) => b.confidence.compareTo(a.confidence));
    return patterns;
  }

  void _analyzeLateSleepCycles(
      List<TimelineEvent> events, List<DetectedPattern> patterns) {
    final sleepEvents = events
        .where((e) => e.type == TimelineEventType.healthSleep)
        .toList();

    if (sleepEvents.length < 3) return;

    int lateCount = 0;
    for (final e in sleepEvents) {
      final hour = e.timestamp.hour;
      if (hour >= 23 || hour < 1) lateCount++;
    }

    final ratio = lateCount / sleepEvents.length;
    if (ratio > 0.4) {
      patterns.add(DetectedPattern(
        id: 'late_sleep',
        titleEn: 'Late Sleep Pattern',
        titleHu: 'Késői alvási minta',
        descriptionEn:
            'You tend to log sleep after 23:00 (${(ratio * 100).round()}% of the time).',
        descriptionHu:
            'Általában 23:00 után rögzíted az alvást (az esetek ${(ratio * 100).round()}%-ában).',
        confidence: (ratio * 0.8).clamp(0.0, 1.0),
        category: PatternCategory.sleep,
        icon: IconType.sleep,
      ));
    }
  }

  void _analyzeLowHydrationMornings(
      List<TimelineEvent> events, List<DetectedPattern> patterns) {
    final drinkEvents = events
        .where((e) => e.type == TimelineEventType.healthWater ||
            e.type == TimelineEventType.captureDrink)
        .toList();

    if (drinkEvents.length < 5) return;

    final morningDrinks =
        drinkEvents.where((e) => e.timestamp.hour < 14).length;
    final afternoonDrinks =
        drinkEvents.where((e) => e.timestamp.hour >= 14).length;

    if (morningDrinks < afternoonDrinks && drinkEvents.length >= 10) {
      final ratio = morningDrinks / drinkEvents.length;
      patterns.add(DetectedPattern(
        id: 'low_hydration_morning',
        titleEn: 'Low Morning Hydration',
        titleHu: 'Alacsony reggeli folyadékbevitel',
        descriptionEn:
            'Your hydration tends to be low before 14:00. Only ${(ratio * 100).round()}% of drinks are in the morning.',
        descriptionHu:
            'A folyadékbeviteled általában alacsony 14:00 előtt. Az italaid mindössze ${(ratio * 100).round()}%-a esik a délelőttre.',
        confidence: ((1 - ratio) * 0.7).clamp(0.0, 1.0),
        category: PatternCategory.hydration,
        icon: IconType.water,
      ));
    }
  }

  void _analyzeImpulsiveSpending(
      List<TimelineEvent> events, List<DetectedPattern> patterns) {
    final financeEvents = events
        .where((e) => e.type == TimelineEventType.captureExpense)
        .toList();

    if (financeEvents.length < 3) return;

    // Check for multi-expense days
    final dayMap = <String, int>{};
    for (final e in financeEvents) {
      final key =
          '${e.timestamp.year}-${e.timestamp.month}-${e.timestamp.day}';
      dayMap[key] = (dayMap[key] ?? 0) + 1;
    }

    final multiExpenseDays =
        dayMap.values.where((count) => count >= 3).length;
    if (multiExpenseDays >= 2) {
      final ratio = multiExpenseDays / dayMap.length;
      patterns.add(DetectedPattern(
        id: 'impulsive_spending',
        titleEn: 'Spending Clusters',
        titleHu: 'Kiadási csoportosulások',
        descriptionEn:
            '$multiExpenseDays days with 3+ expenses detected. This may indicate impulsive spending.',
        descriptionHu:
            '$multiExpenseDays nap 3+ kiadással. Ez impulzív költekezésre utalhat.',
        confidence: (ratio * 0.75).clamp(0.0, 1.0),
        category: PatternCategory.spending,
        icon: IconType.money,
      ));
    }
  }

  void _analyzeNightNoteActivity(
      List<TimelineEvent> events, List<DetectedPattern> patterns) {
    final noteEvents = events
        .where((e) =>
            e.type == TimelineEventType.journal ||
            e.type == TimelineEventType.captureNote)
        .toList();

    if (noteEvents.length < 5) return;

    final nightNotes = noteEvents
        .where((e) => e.timestamp.hour >= 22 || e.timestamp.hour < 5)
        .length;
    final ratio = nightNotes / noteEvents.length;

    if (ratio > 0.3 && nightNotes >= 3) {
      patterns.add(DetectedPattern(
        id: 'night_activity',
        titleEn: 'High Night Activity',
        titleHu: 'Magas éjszakai aktivitás',
        descriptionEn:
            '${(ratio * 100).round()}% of your notes are logged between 22:00-05:00.',
        descriptionHu:
            'A jegyzeteid ${(ratio * 100).round()}%-a 22:00-05:00 között kerül rögzítésre.',
        confidence: (ratio * 0.7).clamp(0.0, 1.0),
        category: PatternCategory.activity,
        icon: IconType.activity,
      ));
    }
  }

  void _analyzeEnergyCrashes(
      List<TimelineEvent> events, List<DetectedPattern> patterns) {
    final moodEvents = events
        .where((e) => e.type == TimelineEventType.moodLog)
        .toList();

    if (moodEvents.length < 7) return;

    // Analyze mood timeline for sharp drops
    moodEvents.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    int crashCount = 0;
    for (int i = 1; i < moodEvents.length; i++) {
      final prev = moodEvents[i - 1];
      final curr = moodEvents[i];
      final timeDiff =
          curr.timestamp.difference(prev.timestamp).inHours;
      if (timeDiff <= 8 && timeDiff > 0) {
        final prevSubtitle = prev.subtitle ?? '';
        final currSubtitle = curr.subtitle ?? '';
        final prevLevel = _extractMoodLevel(prevSubtitle);
        final currLevel = _extractMoodLevel(currSubtitle);
        if (prevLevel != null && currLevel != null) {
          if (prevLevel - currLevel >= 2) {
            crashCount++;
          }
        }
      }
    }

    if (crashCount >= 2) {
      final ratio = crashCount / math.max(moodEvents.length - 1, 1);
      patterns.add(DetectedPattern(
        id: 'energy_crash',
        titleEn: 'Energy Crashes',
        titleHu: 'Energiaesések',
        descriptionEn:
            'Detected $crashCount sharp mood drops within short time spans.',
        descriptionHu:
            '$crashCount hirtelen hangulatesés rövid időn belül.',
        confidence: (ratio * 0.8).clamp(0.0, 1.0),
        category: PatternCategory.mood,
        icon: IconType.mood,
      ));
    }
  }

  int? _extractMoodLevel(String subtitle) {
    // Try to extract a number from strings like "Mood: 4/5" or just "4"
    final regex = RegExp(r'(\d)');
    final match = regex.firstMatch(subtitle);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }
}
