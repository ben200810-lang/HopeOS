import 'dart:math' as math;

import '../../data/models/capture_entry.dart';
import '../../data/models/health_entry.dart';
import '../../data/models/mood_entry.dart';
import '../../data/models/timeline_event.dart';

/// A detected behavioral pattern that may be associated with ADHD.
///
/// This is NOT a diagnosis. The engine only surfaces observational patterns
/// from the user's own data.
class DetectedPattern {
  final String patternId;
  final Map<String, String> name;
  final Map<String, String> description;
  final String emoji;
  final double confidence;
  final String evidence;

  const DetectedPattern({
    required this.patternId,
    required this.name,
    required this.description,
    required this.emoji,
    required this.confidence,
    required this.evidence,
  });

  String localizedName(String locale) => name[locale] ?? name['en'] ?? patternId;
  String localizedDescription(String locale) =>
      description[locale] ?? description['en'] ?? '';
}

/// Analyzes user data for behavioral patterns commonly associated with ADHD.
///
/// IMPORTANT: This engine does NOT diagnose ADHD. It only identifies patterns
/// in the user's own data that research has associated with ADHD traits.
class AdhdInsightEngine {
  static const double _minConfidence = 0.3;

  /// Analyze all available data and return detected patterns.
  List<DetectedPattern> analyze({
    required List<HealthEntry> healthEntries,
    required List<MoodEntry> moodEntries,
    required List<CaptureEntry> captureEntries,
    required List<TimelineEvent> timelineEvents,
  }) {
    final patterns = <DetectedPattern>[];

    final sleepPattern = _analyzeSleepPatterns(healthEntries);
    if (sleepPattern != null) patterns.add(sleepPattern);

    final moodPattern = _analyzeMoodVolatility(moodEntries);
    if (moodPattern != null) patterns.add(moodPattern);

    final activityPattern = _analyzeActivityConsistency(timelineEvents);
    if (activityPattern != null) patterns.add(activityPattern);

    final spendingPattern = _analyzeSpendingPatterns(captureEntries);
    if (spendingPattern != null) patterns.add(spendingPattern);

    final timePattern = _analyzeTimePatterns(timelineEvents);
    if (timePattern != null) patterns.add(timePattern);

    final eveningPattern = _analyzeEveningActivity(timelineEvents);
    if (eveningPattern != null) patterns.add(eveningPattern);

    return patterns;
  }

  DetectedPattern? _analyzeSleepPatterns(List<HealthEntry> entries) {
    final sleepEntries =
        entries.where((e) => e.sleepHours != null).toList();
    if (sleepEntries.length < 3) return null;

    final hours = sleepEntries.map((e) => e.sleepHours!).toList();
    final mean = hours.reduce((a, b) => a + b) / hours.length;
    final variance =
        hours.map((h) => (h - mean) * (h - mean)).reduce((a, b) => a + b) /
            hours.length;
    final stdDev = _sqrt(variance);

    // High variance (>1.5h std dev) or frequent poor sleep (<6h)
    final poorSleepCount = hours.where((h) => h < 6).length;
    final poorSleepRatio = poorSleepCount / hours.length;

    final score = (stdDev > 1.5 ? 0.5 : stdDev / 3.0) +
        (poorSleepRatio > 0.3 ? 0.3 : poorSleepRatio);

    if (score < _minConfidence) return null;

    return DetectedPattern(
      patternId: 'irregular_sleep',
      name: const {
        'en': 'Irregular sleep patterns',
        'hu': 'Rendszertelen alvási szokások',
      },
      description: const {
        'en':
            'Your sleep data shows notable variation in duration. Inconsistent sleep is commonly reported in ADHD research.',
        'hu':
            'Az alvási adatai jelentős időtartam-ingadozást mutatnak. A rendszertelen alvás gyakran előfordul az ADHD kutatásokban.',
      },
      emoji: '🌙',
      confidence: score.clamp(0.0, 1.0),
      evidence:
          'Std dev: ${stdDev.toStringAsFixed(1)}h, poor sleep nights: ${(poorSleepRatio * 100).toStringAsFixed(0)}%',
    );
  }

  DetectedPattern? _analyzeMoodVolatility(List<MoodEntry> entries) {
    if (entries.length < 5) return null;

    final moods = entries.map((e) => e.moodLevel.toDouble()).toList();
    final energies = entries.map((e) => e.energyLevel.toDouble()).toList();

    final moodMean = moods.reduce((a, b) => a + b) / moods.length;
    final moodVariance = moods
            .map((m) => (m - moodMean) * (m - moodMean))
            .reduce((a, b) => a + b) /
        moods.length;

    // Count rapid swings (>=2 level change between consecutive entries)
    int swingCount = 0;
    for (int i = 1; i < moods.length; i++) {
      if ((moods[i] - moods[i - 1]).abs() >= 2) swingCount++;
    }
    final swingRatio = swingCount / (moods.length - 1);

    // Check energy-mood mismatch (normalize energy 1-10 to mood 1-5 scale)
    int mismatchCount = 0;
    for (int i = 0; i < moods.length && i < energies.length; i++) {
      final normalizedEnergy = (energies[i] - 1) * 4.0 / 9.0 + 1.0;
      if ((moods[i] - normalizedEnergy).abs() >= 2) mismatchCount++;
    }
    final mismatchRatio = mismatchCount / moods.length;

    final score =
        (moodVariance > 2 ? 0.4 : moodVariance / 5.0) +
        (swingRatio > 0.3 ? 0.3 : swingRatio) +
        (mismatchRatio > 0.3 ? 0.2 : mismatchRatio * 0.67);

    if (score < _minConfidence) return null;

    return DetectedPattern(
      patternId: 'mood_volatility',
      name: const {
        'en': 'Mood volatility',
        'hu': 'Hangulati ingadozás',
      },
      description: const {
        'en':
            'Your mood logs show frequent shifts. Rapid mood changes are often reported in ADHD-related research.',
        'hu':
            'A hangulati naplója gyakori változásokat mutat. A gyors hangulatváltásokat gyakran említik az ADHD-vel kapcsolatos kutatásokban.',
      },
      emoji: '🎢',
      confidence: score.clamp(0.0, 1.0),
      evidence:
          'Mood variance: ${moodVariance.toStringAsFixed(1)}, swing ratio: ${(swingRatio * 100).toStringAsFixed(0)}%',
    );
  }

  DetectedPattern? _analyzeActivityConsistency(List<TimelineEvent> events) {
    if (events.length < 7) return null;

    // Group events by day
    final dailyCounts = <String, int>{};
    for (final event in events) {
      final day =
          '${event.timestamp.year}-${event.timestamp.month}-${event.timestamp.day}';
      dailyCounts[day] = (dailyCounts[day] ?? 0) + 1;
    }

    if (dailyCounts.length < 3) return null;

    final counts = dailyCounts.values.toList();
    final mean = counts.reduce((a, b) => a + b) / counts.length;
    final variance = counts
            .map((c) => (c - mean) * (c - mean))
            .reduce((a, b) => a + b) /
        counts.length;
    final coeffOfVariation = _sqrt(variance) / mean;

    if (coeffOfVariation < 0.5) return null;

    final score = (coeffOfVariation - 0.5).clamp(0.0, 1.0);

    return DetectedPattern(
      patternId: 'inconsistent_productivity',
      name: const {
        'en': 'Inconsistent productivity',
        'hu': 'Egyenetlen produktivitás',
      },
      description: const {
        'en':
            'Your activity levels vary significantly between days. Burst-and-pause patterns are often noted in ADHD research.',
        'hu':
            'Az aktivitási szintjei jelentősen változnak a napok között. A lökésszerű és szünetelő mintákat gyakran említik az ADHD kutatásokban.',
      },
      emoji: '📊',
      confidence: score.clamp(0.0, 1.0),
      evidence:
          'Coefficient of variation: ${coeffOfVariation.toStringAsFixed(2)}',
    );
  }

  DetectedPattern? _analyzeSpendingPatterns(List<CaptureEntry> entries) {
    final expenses = entries
        .where((e) => e.type == CaptureType.expense && e.amount != null)
        .toList();
    if (expenses.length < 5) return null;

    // Check for frequent small expenses
    final amounts = expenses.map((e) => e.amount!).toList();
    final mean = amounts.reduce((a, b) => a + b) / amounts.length;

    // Count days with multiple expenses
    final dailyExpenses = <String, int>{};
    for (final e in expenses) {
      final day =
          '${e.createdAt.year}-${e.createdAt.month}-${e.createdAt.day}';
      dailyExpenses[day] = (dailyExpenses[day] ?? 0) + 1;
    }
    final multiExpenseDays =
        dailyExpenses.values.where((c) => c >= 3).length;
    final multiRatio =
        dailyExpenses.isEmpty ? 0.0 : multiExpenseDays / dailyExpenses.length;

    // Variance check
    final variance = amounts
            .map((a) => (a - mean) * (a - mean))
            .reduce((a, b) => a + b) /
        amounts.length;
    final coeffOfVariation = mean > 0 ? _sqrt(variance) / mean : 0.0;

    final score = (multiRatio > 0.3 ? 0.4 : multiRatio * 1.33) +
        (coeffOfVariation > 1.0 ? 0.4 : coeffOfVariation * 0.4);

    if (score < _minConfidence) return null;

    return DetectedPattern(
      patternId: 'impulsive_spending',
      name: const {
        'en': 'Impulsive spending patterns',
        'hu': 'Impulzív költési szokások',
      },
      description: const {
        'en':
            'Your spending data shows variability and frequent purchases. Impulsive spending is a pattern noted in ADHD research.',
        'hu':
            'A költési adatai változékonyságot és gyakori vásárlásokat mutatnak. Az impulzív költekezés az ADHD kutatásokban említett minta.',
      },
      emoji: '💸',
      confidence: score.clamp(0.0, 1.0),
      evidence:
          'Multi-expense days: ${(multiRatio * 100).toStringAsFixed(0)}%, CV: ${coeffOfVariation.toStringAsFixed(2)}',
    );
  }

  DetectedPattern? _analyzeTimePatterns(List<TimelineEvent> events) {
    if (events.length < 10) return null;

    // Check for irregular entry timing patterns
    final hours = events.map((e) => e.timestamp.hour).toList();
    final mean = hours.reduce((a, b) => a + b) / hours.length;
    final variance =
        hours.map((h) => (h - mean) * (h - mean)).reduce((a, b) => a + b) /
            hours.length;

    // Check for gaps followed by clusters
    final sortedEvents = List<TimelineEvent>.from(events)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    int gapClusterCount = 0;
    for (int i = 1; i < sortedEvents.length - 1; i++) {
      final prevGap = sortedEvents[i]
          .timestamp
          .difference(sortedEvents[i - 1].timestamp)
          .inHours;
      final nextGap = sortedEvents[i + 1]
          .timestamp
          .difference(sortedEvents[i].timestamp)
          .inMinutes;
      if (prevGap > 6 && nextGap < 30) gapClusterCount++;
    }
    final gapClusterRatio = gapClusterCount / (sortedEvents.length - 2);

    final score = (variance > 40 ? 0.4 : variance / 100) +
        (gapClusterRatio > 0.2 ? 0.4 : gapClusterRatio * 2.0);

    if (score < _minConfidence) return null;

    return DetectedPattern(
      patternId: 'time_blindness',
      name: const {
        'en': 'Time perception difficulties',
        'hu': 'Időérzékelési nehézségek',
      },
      description: const {
        'en':
            'Your data shows irregular entry timing with bursts following gaps. Time perception challenges are often discussed in ADHD literature.',
        'hu':
            'Az adatai szabálytalan időzítést mutatnak, szüneteket követő aktivitási hullámokkal. Az időérzékelési kihívásokat gyakran tárgyalják az ADHD irodalomban.',
      },
      emoji: '⏰',
      confidence: score.clamp(0.0, 1.0),
      evidence:
          'Hour variance: ${variance.toStringAsFixed(1)}, gap-cluster ratio: ${(gapClusterRatio * 100).toStringAsFixed(0)}%',
    );
  }

  DetectedPattern? _analyzeEveningActivity(List<TimelineEvent> events) {
    if (events.length < 7) return null;

    // Count events after 21:00
    final eveningEvents = events.where((e) => e.timestamp.hour >= 21).length;
    final lateNightEvents = events.where((e) => e.timestamp.hour >= 23).length;
    final eveningRatio = eveningEvents / events.length;
    final lateNightRatio = lateNightEvents / events.length;

    final score = (eveningRatio > 0.3 ? 0.5 : eveningRatio * 1.67) +
        (lateNightRatio > 0.15 ? 0.3 : lateNightRatio * 2.0);

    if (score < _minConfidence) return null;

    return DetectedPattern(
      patternId: 'evening_hyperactivity',
      name: const {
        'en': 'Evening hyperactivity',
        'hu': 'Esti hiperaktivitás',
      },
      description: const {
        'en':
            'A significant portion of your activity occurs in the evening. Increased evening mental activity is often discussed in ADHD contexts.',
        'hu':
            'Tevékenységeinek jelentős része az esti órákban történik. A fokozott esti szellemi aktivitást gyakran tárgyalják ADHD kontextusban.',
      },
      emoji: '🦉',
      confidence: score.clamp(0.0, 1.0),
      evidence:
          'Evening entries: ${(eveningRatio * 100).toStringAsFixed(0)}%, late night: ${(lateNightRatio * 100).toStringAsFixed(0)}%',
    );
  }

  double _sqrt(double value) => math.sqrt(value);
}
