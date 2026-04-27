import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/health_entry.dart';
import '../../data/models/mood_entry.dart';
import '../../data/models/capture_entry.dart';
import '../../data/repositories/health_repository.dart';
import '../../data/repositories/mood_repository.dart';
import '../../data/repositories/capture_repository.dart';
import 'pattern_insight.dart';
import 'pattern_insight_repository.dart';

/// Aggregated signals for a single calendar day.
class _DaySignals {
  final DateTime date;
  double sleepHours;
  double waterLiters;
  int exerciseMinutes;
  int steps;
  List<int> moodLevels;
  List<int> energyLevels;
  int noteCount;
  List<int> noteHours;
  int expenseCount;
  double totalExpenses;
  int drinkCount;

  _DaySignals({required this.date})
      : sleepHours = 0,
        waterLiters = 0,
        exerciseMinutes = 0,
        steps = 0,
        moodLevels = [],
        energyLevels = [],
        noteCount = 0,
        noteHours = [],
        expenseCount = 0,
        totalExpenses = 0,
        drinkCount = 0;

  double get avgMood =>
      moodLevels.isEmpty ? 0 : moodLevels.reduce((a, b) => a + b) / moodLevels.length;

  double get avgEnergy =>
      energyLevels.isEmpty ? 0 : energyLevels.reduce((a, b) => a + b) / energyLevels.length;

  bool get hasMood => moodLevels.isNotEmpty;
  bool get hasSleep => sleepHours > 0;
  bool get hasActivity => exerciseMinutes > 0 || steps > 0;
}

/// Analyzes cross-domain life patterns from local data.
///
/// Runs once per day (cached via SharedPreferences). All analysis happens
/// on-device — no data is ever sent externally.
class PatternEngineService {
  static const _lastAnalysisKey = 'pattern_engine_last_analysis';

  final HealthRepository _healthRepo = HealthRepository();
  final MoodRepository _moodRepo = MoodRepository();
  final CaptureRepository _captureRepo = CaptureRepository();
  final PatternInsightRepository _insightRepo = PatternInsightRepository();

  /// Returns cached insights if analysis already ran today,
  /// otherwise runs a fresh analysis.
  Future<List<PatternInsight>> getInsights({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final alreadyRan = await _hasRunToday();
      if (alreadyRan) {
        final cached = await _insightRepo.getAll();
        if (cached.isNotEmpty) return cached;
      }
    }
    return runAnalysis();
  }

  /// Full analysis pipeline: load data → aggregate by day → detect patterns → persist.
  Future<List<PatternInsight>> runAnalysis({int windowDays = 7}) async {
    try {
      final now = DateTime.now();
      final start = now.subtract(Duration(days: windowDays));

      // Load raw data
      final healthEntries = await _healthRepo.getByDateRange(start, now);
      final moodEntries = await _moodRepo.getAll();
      final captureEntries = await _captureRepo.getAll();

      // Filter to window
      final moodInWindow = moodEntries
          .where((m) => m.createdAt.isAfter(start))
          .toList();
      final captureInWindow = captureEntries
          .where((c) => c.createdAt.isAfter(start))
          .toList();

      // Aggregate by day
      final days = _aggregateByDay(
        healthEntries,
        moodInWindow,
        captureInWindow,
        windowDays,
      );

      if (days.length < 3) {
        await _markRanToday();
        return [];
      }

      // Run all correlation detectors
      final insights = <PatternInsight>[];
      final analysisDate = now.toIso8601String().substring(0, 10);

      _detectSleepMoodCorrelation(days, insights, analysisDate);
      _detectSleepEnergyCorrelation(days, insights, analysisDate);
      _detectActivityMoodCorrelation(days, insights, analysisDate);
      _detectActivityEnergyCorrelation(days, insights, analysisDate);
      _detectHydrationEnergyCorrelation(days, insights, analysisDate);
      _detectHydrationMoodCorrelation(days, insights, analysisDate);
      _detectSpendingMoodCorrelation(days, insights, analysisDate);
      _detectLateNotePattern(days, insights, analysisDate);
      _detectLowSleepPattern(days, insights, analysisDate);
      _detectLowHydrationPattern(days, insights, analysisDate);
      _detectHighActivityDays(days, insights, analysisDate);
      _detectSpendingClusters(days, insights, analysisDate);
      _detectStepsSleepCorrelation(days, insights, analysisDate);

      // Sort by confidence
      insights.sort((a, b) => b.confidence.compareTo(a.confidence));

      // Persist & mark done
      await _insightRepo.replaceAll(insights);
      await _markRanToday();

      return insights;
    } catch (e) {
      debugPrint('PatternEngineService analysis failed: $e');
      return [];
    }
  }

  // ─── Aggregation ──────────────────────────────────────────

  List<_DaySignals> _aggregateByDay(
    List<HealthEntry> health,
    List<MoodEntry> moods,
    List<CaptureEntry> captures,
    int windowDays,
  ) {
    final now = DateTime.now();
    final dayMap = <String, _DaySignals>{};

    // Pre-create day buckets
    for (int i = 0; i < windowDays; i++) {
      final d = now.subtract(Duration(days: i));
      final key = _dayKey(d);
      dayMap[key] = _DaySignals(date: DateTime(d.year, d.month, d.day));
    }

    // Health data
    for (final h in health) {
      final key = _dayKey(h.date);
      final day = dayMap[key];
      if (day == null) continue;
      day.sleepHours = h.sleepHours ?? 0;
      day.waterLiters = h.waterLiters;
      day.exerciseMinutes = h.exerciseMinutes ?? 0;
      day.steps = h.steps ?? 0;
    }

    // Mood data
    for (final m in moods) {
      final key = _dayKey(m.createdAt);
      final day = dayMap[key];
      if (day == null) continue;
      day.moodLevels.add(m.moodLevel);
      day.energyLevels.add(m.energyLevel);
    }

    // Capture data
    for (final c in captures) {
      final key = _dayKey(c.createdAt);
      final day = dayMap[key];
      if (day == null) continue;

      switch (c.type) {
        case CaptureType.note:
        case CaptureType.voice:
          day.noteCount++;
          day.noteHours.add(c.createdAt.hour);
          break;
        case CaptureType.expense:
          day.expenseCount++;
          day.totalExpenses += c.amount ?? 0;
          break;
        case CaptureType.drink:
          day.drinkCount++;
          break;
        default:
          break;
      }
    }

    final result = dayMap.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return result;
  }

  String _dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  // ─── Cross-domain Correlations ────────────────────────────

  /// Sleep → Mood: "Your mood seems better on days after more sleep."
  void _detectSleepMoodCorrelation(
      List<_DaySignals> days, List<PatternInsight> out, String analysisDate) {
    final paired = <_Pair>[];
    for (final d in days) {
      if (d.hasSleep && d.hasMood) {
        paired.add(_Pair(d.sleepHours, d.avgMood));
      }
    }
    if (paired.length < 3) return;

    final corr = _correlation(paired);
    if (corr > 0.3) {
      final avgSleepGoodDays = paired
          .where((p) => p.y >= 4)
          .map((p) => p.x)
          .toList();
      final avgSleepStr = avgSleepGoodDays.isNotEmpty
          ? '${(avgSleepGoodDays.reduce((a, b) => a + b) / avgSleepGoodDays.length).toStringAsFixed(1)}h'
          : '7+ hours';
      out.add(PatternInsight(
        id: 'sleep_mood_positive',
        titleEn: 'Sleep may improve your mood',
        titleHu: 'Az alvás javíthatja a hangulatodat',
        descriptionEn:
            'Your mood seems better on days with more sleep. Good mood days average $avgSleepStr of sleep.',
        descriptionHu:
            'A hangulatod jobbnak tűnik a több alvás utáni napokon. A jó hangulatú napok átlagosan $avgSleepStr alvást mutatnak.',
        confidence: (corr * 0.9).clamp(0.0, 1.0),
        relatedSignals: ['sleep', 'mood'],
        domain: PatternDomain.mood,
        severity: PatternSeverity.gentle,
        analysisDate: analysisDate,
        dataPoints: paired.length,
      ));
    }
  }

  /// Sleep → Energy: "Energy levels may drop on days with less sleep."
  void _detectSleepEnergyCorrelation(
      List<_DaySignals> days, List<PatternInsight> out, String analysisDate) {
    final paired = <_Pair>[];
    for (final d in days) {
      if (d.hasSleep && d.energyLevels.isNotEmpty) {
        paired.add(_Pair(d.sleepHours, d.avgEnergy));
      }
    }
    if (paired.length < 3) return;

    final corr = _correlation(paired);
    if (corr > 0.3) {
      final lowSleepDays = paired.where((p) => p.x < 6).toList();
      final lowSleepCount = lowSleepDays.length;
      out.add(PatternInsight(
        id: 'sleep_energy_correlation',
        titleEn: 'Energy dips after short sleep',
        titleHu: 'Energiaesés kevés alvás után',
        descriptionEn:
            'On $lowSleepCount days this week your energy was lower after sleeping less than 6 hours.',
        descriptionHu:
            '$lowSleepCount napon ezen a héten alacsonyabb volt az energiaszinted 6 óránál kevesebb alvás után.',
        confidence: (corr * 0.85).clamp(0.0, 1.0),
        relatedSignals: ['sleep', 'energy'],
        domain: PatternDomain.energy,
        severity: PatternSeverity.notable,
        analysisDate: analysisDate,
        dataPoints: paired.length,
      ));
    }
  }

  /// Activity → Mood: "Your mood is usually better on days when you walk more."
  void _detectActivityMoodCorrelation(
      List<_DaySignals> days, List<PatternInsight> out, String analysisDate) {
    final paired = <_Pair>[];
    for (final d in days) {
      if (d.hasActivity && d.hasMood) {
        paired.add(_Pair(d.steps.toDouble(), d.avgMood));
      }
    }
    if (paired.length < 3) return;

    final corr = _correlation(paired);
    if (corr > 0.25) {
      final activeGoodDays = paired.where((p) => p.y >= 4).toList();
      final avgSteps = activeGoodDays.isNotEmpty
          ? (activeGoodDays.map((p) => p.x).reduce((a, b) => a + b) / activeGoodDays.length).round()
          : 3000;
      out.add(PatternInsight(
        id: 'activity_mood_positive',
        titleEn: 'Activity seems to boost your mood',
        titleHu: 'Az aktivitás javíthatja a hangulatodat',
        descriptionEn:
            'Your mood is usually better on days when you walk more than $avgSteps steps.',
        descriptionHu:
            'A hangulatod általában jobb azokon a napokon, amikor többet mozogsz ($avgSteps lépésnél több).',
        confidence: (corr * 0.85).clamp(0.0, 1.0),
        relatedSignals: ['activity', 'mood'],
        domain: PatternDomain.activity,
        severity: PatternSeverity.gentle,
        analysisDate: analysisDate,
        dataPoints: paired.length,
      ));
    }
  }

  /// Activity → Energy: Low activity + low energy correlation.
  void _detectActivityEnergyCorrelation(
      List<_DaySignals> days, List<PatternInsight> out, String analysisDate) {
    int lowBothCount = 0;
    int totalDays = 0;
    for (final d in days) {
      if (d.energyLevels.isNotEmpty) {
        totalDays++;
        if (d.exerciseMinutes < 15 && d.avgEnergy < 3) {
          lowBothCount++;
        }
      }
    }
    if (totalDays < 3 || lowBothCount < 2) return;

    final ratio = lowBothCount / totalDays;
    out.add(PatternInsight(
      id: 'low_activity_low_energy',
      titleEn: 'Possible low activity & energy link',
      titleHu: 'Lehetséges alacsony aktivitás és energia kapcsolat',
      descriptionEn:
          'On $lowBothCount of $totalDays days, both your activity and energy were low. A short walk may help.',
      descriptionHu:
          '$totalDays napból $lowBothCount napon az aktivitásod és az energiaszinted is alacsony volt. Egy rövid séta segíthet.',
      confidence: (ratio * 0.8).clamp(0.0, 1.0),
      relatedSignals: ['activity', 'energy'],
      domain: PatternDomain.energy,
      severity: PatternSeverity.gentle,
      analysisDate: analysisDate,
      dataPoints: totalDays,
    ));
  }

  /// Hydration → Energy: "Hydration seems lower on high stress days."
  void _detectHydrationEnergyCorrelation(
      List<_DaySignals> days, List<PatternInsight> out, String analysisDate) {
    final paired = <_Pair>[];
    for (final d in days) {
      if (d.waterLiters > 0 && d.energyLevels.isNotEmpty) {
        paired.add(_Pair(d.waterLiters, d.avgEnergy));
      }
    }
    if (paired.length < 3) return;

    final corr = _correlation(paired);
    if (corr > 0.25) {
      out.add(PatternInsight(
        id: 'hydration_energy_link',
        titleEn: 'Hydration may affect your energy',
        titleHu: 'A folyadékbevitel befolyásolhatja az energiádat',
        descriptionEn:
            'Your energy seems higher on days when you drink more water.',
        descriptionHu:
            'Az energiaszinted magasabbnak tűnik azokon a napokon, amikor több vizet iszol.',
        confidence: (corr * 0.8).clamp(0.0, 1.0),
        relatedSignals: ['hydration', 'energy'],
        domain: PatternDomain.hydration,
        severity: PatternSeverity.gentle,
        analysisDate: analysisDate,
        dataPoints: paired.length,
      ));
    }
  }

  /// Hydration → Mood: Mood drop on low-hydration days.
  void _detectHydrationMoodCorrelation(
      List<_DaySignals> days, List<PatternInsight> out, String analysisDate) {
    int lowWaterLowMood = 0;
    int totalDays = 0;
    for (final d in days) {
      if (d.hasMood && d.waterLiters > 0) {
        totalDays++;
        if (d.waterLiters < 1.0 && d.avgMood < 3) {
          lowWaterLowMood++;
        }
      }
    }
    if (totalDays < 3 || lowWaterLowMood < 2) return;

    final ratio = lowWaterLowMood / totalDays;
    out.add(PatternInsight(
      id: 'hydration_mood_low',
      titleEn: 'Hydration seems lower on tough days',
      titleHu: 'A folyadékbevitel alacsonyabbnak tűnik a nehezebb napokon',
      descriptionEn:
          'On $lowWaterLowMood days, both your hydration and mood were low. Staying hydrated may help.',
      descriptionHu:
          '$lowWaterLowMood napon a folyadékbeviteled és a hangulatod is alacsony volt. A rendszeres ivás segíthet.',
      confidence: (ratio * 0.75).clamp(0.0, 1.0),
      relatedSignals: ['hydration', 'mood'],
      domain: PatternDomain.hydration,
      severity: PatternSeverity.gentle,
      analysisDate: analysisDate,
      dataPoints: totalDays,
    ));
  }

  /// Finance → Mood: "Spending increases on low mood days."
  void _detectSpendingMoodCorrelation(
      List<_DaySignals> days, List<PatternInsight> out, String analysisDate) {
    final daysWithBoth = days.where((d) => d.hasMood && d.expenseCount > 0).toList();
    if (daysWithBoth.length < 3) return;

    int lowMoodHighSpend = 0;
    for (final d in daysWithBoth) {
      if (d.avgMood < 3 && d.expenseCount >= 2) {
        lowMoodHighSpend++;
      }
    }

    if (lowMoodHighSpend < 2) return;

    final ratio = lowMoodHighSpend / daysWithBoth.length;
    out.add(PatternInsight(
      id: 'spending_mood_link',
      titleEn: 'Spending may increase on tough days',
      titleHu: 'A kiadások nőhetnek a nehezebb napokon',
      descriptionEn:
          'On $lowMoodHighSpend days, spending was higher when your mood was lower. This is a common pattern.',
      descriptionHu:
          '$lowMoodHighSpend napon a kiadások magasabbak voltak, amikor a hangulatod alacsonyabb volt. Ez gyakori minta.',
      confidence: (ratio * 0.7).clamp(0.0, 1.0),
      relatedSignals: ['finance', 'mood'],
      domain: PatternDomain.finance,
      severity: PatternSeverity.notable,
      analysisDate: analysisDate,
      dataPoints: daysWithBoth.length,
    ));
  }

  // ─── Single-domain Patterns ───────────────────────────────

  /// Notes: "You tend to write notes late at night."
  void _detectLateNotePattern(
      List<_DaySignals> days, List<PatternInsight> out, String analysisDate) {
    int lateNotes = 0;
    int totalNotes = 0;
    for (final d in days) {
      for (final h in d.noteHours) {
        totalNotes++;
        if (h >= 22 || h < 5) lateNotes++;
      }
    }
    if (totalNotes < 5 || lateNotes < 3) return;

    final ratio = lateNotes / totalNotes;
    if (ratio > 0.3) {
      out.add(PatternInsight(
        id: 'late_night_notes',
        titleEn: 'You tend to write notes late at night',
        titleHu: 'Hajlamos vagy éjszaka jegyzetelni',
        descriptionEn:
            '${(ratio * 100).round()}% of your notes are written between 22:00 and 05:00.',
        descriptionHu:
            'A jegyzeteid ${(ratio * 100).round()}%-a 22:00 és 05:00 között készül.',
        confidence: (ratio * 0.75).clamp(0.0, 1.0),
        relatedSignals: ['notes'],
        domain: PatternDomain.notes,
        severity: PatternSeverity.info,
        analysisDate: analysisDate,
        dataPoints: totalNotes,
      ));
    }
  }

  /// Sleep: Consistent low sleep pattern.
  void _detectLowSleepPattern(
      List<_DaySignals> days, List<PatternInsight> out, String analysisDate) {
    final sleepDays = days.where((d) => d.hasSleep).toList();
    if (sleepDays.length < 3) return;

    final lowSleepDays = sleepDays.where((d) => d.sleepHours < 6).length;
    final ratio = lowSleepDays / sleepDays.length;

    if (ratio > 0.4 && lowSleepDays >= 3) {
      final avgSleep = sleepDays.map((d) => d.sleepHours).reduce((a, b) => a + b) / sleepDays.length;
      out.add(PatternInsight(
        id: 'low_sleep_pattern',
        titleEn: 'Sleep may be consistently low',
        titleHu: 'Az alvásod tartósan alacsony lehet',
        descriptionEn:
            'On $lowSleepDays of ${sleepDays.length} days you slept less than 6 hours. Your average is ${avgSleep.toStringAsFixed(1)}h.',
        descriptionHu:
            '${sleepDays.length} napból $lowSleepDays napon 6 óránál kevesebbet aludtál. Az átlagod ${avgSleep.toStringAsFixed(1)} óra.',
        confidence: (ratio * 0.85).clamp(0.0, 1.0),
        relatedSignals: ['sleep'],
        domain: PatternDomain.sleep,
        severity: PatternSeverity.notable,
        analysisDate: analysisDate,
        dataPoints: sleepDays.length,
      ));
    }
  }

  /// Hydration: Overall low hydration.
  void _detectLowHydrationPattern(
      List<_DaySignals> days, List<PatternInsight> out, String analysisDate) {
    final hydrationDays = days.where((d) => d.waterLiters > 0).toList();
    if (hydrationDays.length < 3) return;

    final lowDays = hydrationDays.where((d) => d.waterLiters < 1.5).length;
    final ratio = lowDays / hydrationDays.length;

    if (ratio > 0.5 && lowDays >= 3) {
      final avg = hydrationDays.map((d) => d.waterLiters).reduce((a, b) => a + b) / hydrationDays.length;
      out.add(PatternInsight(
        id: 'low_hydration_pattern',
        titleEn: 'Hydration may need attention',
        titleHu: 'A folyadékbevitelre érdemes odafigyelni',
        descriptionEn:
            'On $lowDays of ${hydrationDays.length} days your water intake was below 1.5L. Average: ${avg.toStringAsFixed(1)}L.',
        descriptionHu:
            '${hydrationDays.length} napból $lowDays napon a folyadékbeviteled 1.5L alatt volt. Átlag: ${avg.toStringAsFixed(1)}L.',
        confidence: (ratio * 0.8).clamp(0.0, 1.0),
        relatedSignals: ['hydration'],
        domain: PatternDomain.hydration,
        severity: PatternSeverity.gentle,
        analysisDate: analysisDate,
        dataPoints: hydrationDays.length,
      ));
    }
  }

  /// Activity: High activity days = better overall signals.
  void _detectHighActivityDays(
      List<_DaySignals> days, List<PatternInsight> out, String analysisDate) {
    final activeDays = days.where((d) => d.hasActivity && d.hasMood).toList();
    if (activeDays.length < 3) return;

    final highActivity = activeDays.where((d) => d.exerciseMinutes >= 30).toList();
    if (highActivity.isEmpty) return;

    final avgMoodActive = highActivity.map((d) => d.avgMood).reduce((a, b) => a + b) / highActivity.length;
    final lowActivity = activeDays.where((d) => d.exerciseMinutes < 15).toList();
    if (lowActivity.isEmpty) return;

    final avgMoodInactive = lowActivity.map((d) => d.avgMood).reduce((a, b) => a + b) / lowActivity.length;

    if (avgMoodActive - avgMoodInactive > 0.5) {
      out.add(PatternInsight(
        id: 'high_activity_better_mood',
        titleEn: 'Active days seem brighter',
        titleHu: 'Az aktív napok jobbnak tűnnek',
        descriptionEn:
            'Your mood averages ${avgMoodActive.toStringAsFixed(1)}/5 on active days vs ${avgMoodInactive.toStringAsFixed(1)}/5 on rest days.',
        descriptionHu:
            'A hangulatod átlaga ${avgMoodActive.toStringAsFixed(1)}/5 aktív napokon, szemben ${avgMoodInactive.toStringAsFixed(1)}/5-tel a pihenőnapokon.',
        confidence: 0.7,
        relatedSignals: ['activity', 'mood'],
        domain: PatternDomain.activity,
        severity: PatternSeverity.gentle,
        analysisDate: analysisDate,
        dataPoints: activeDays.length,
      ));
    }
  }

  /// Finance: Spending clusters (3+ expenses in a day).
  void _detectSpendingClusters(
      List<_DaySignals> days, List<PatternInsight> out, String analysisDate) {
    final spendingDays = days.where((d) => d.expenseCount > 0).toList();
    if (spendingDays.length < 3) return;

    final clusterDays = spendingDays.where((d) => d.expenseCount >= 3).length;
    if (clusterDays < 2) return;

    final ratio = clusterDays / spendingDays.length;
    out.add(PatternInsight(
      id: 'spending_clusters',
      titleEn: 'Spending may come in clusters',
      titleHu: 'A kiadások csoportosulhatnak',
      descriptionEn:
          '$clusterDays days had 3 or more expenses. This may indicate impulse spending patterns.',
      descriptionHu:
          '$clusterDays napon 3 vagy több kiadás volt. Ez impulzív költekezési mintára utalhat.',
      confidence: (ratio * 0.7).clamp(0.0, 1.0),
      relatedSignals: ['finance'],
      domain: PatternDomain.finance,
      severity: PatternSeverity.notable,
      analysisDate: analysisDate,
      dataPoints: spendingDays.length,
    ));
  }

  /// Steps → Sleep: correlation between daily step count and sleep quality.
  void _detectStepsSleepCorrelation(
      List<_DaySignals> days, List<PatternInsight> out, String analysisDate) {
    final paired = <_Pair>[];
    for (int i = 1; i < days.length; i++) {
      final prev = days[i - 1];
      final curr = days[i];
      if (prev.steps > 0 && curr.hasSleep) {
        paired.add(_Pair(prev.steps.toDouble(), curr.sleepHours));
      }
    }
    if (paired.length < 3) return;

    final corr = _correlation(paired);
    if (corr.abs() > 0.25) {
      final direction = corr > 0 ? 'more' : 'less';
      final directionHu = corr > 0 ? 'több' : 'kevesebb';
      out.add(PatternInsight(
        id: 'steps_sleep_correlation',
        titleEn: 'Steps may affect your sleep',
        titleHu: 'A lépések befolyásolhatják az alvásod',
        descriptionEn:
            'Days with more steps tend to be followed by $direction sleep.',
        descriptionHu:
            'A több lépéses napok után általában $directionHu alvás következik.',
        confidence: (corr.abs() * 0.85).clamp(0.0, 1.0),
        relatedSignals: ['steps', 'sleep'],
        domain: PatternDomain.sleep,
        severity: PatternSeverity.gentle,
        analysisDate: analysisDate,
        dataPoints: paired.length,
      ));
    }
  }

  // ─── Helpers ──────────────────────────────────────────────

  /// Pearson correlation coefficient for a list of (x, y) pairs.
  double _correlation(List<_Pair> pairs) {
    if (pairs.length < 3) return 0;

    final n = pairs.length;
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0, sumY2 = 0;
    for (final p in pairs) {
      sumX += p.x;
      sumY += p.y;
      sumXY += p.x * p.y;
      sumX2 += p.x * p.x;
      sumY2 += p.y * p.y;
    }
    final numerator = n * sumXY - sumX * sumY;
    final denominator = math.sqrt(
        (n * sumX2 - sumX * sumX) * (n * sumY2 - sumY * sumY));
    if (denominator == 0) return 0;
    return (numerator / denominator).clamp(-1.0, 1.0);
  }

  Future<bool> _hasRunToday() async {
    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getString(_lastAnalysisKey);
    if (last == null) return false;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return last == today;
  }

  Future<void> _markRanToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await prefs.setString(_lastAnalysisKey, today);
  }
}

class _Pair {
  final double x;
  final double y;
  const _Pair(this.x, this.y);
}
