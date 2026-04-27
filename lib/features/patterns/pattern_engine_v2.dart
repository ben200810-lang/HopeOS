import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/health_entry.dart';
import '../../data/models/mood_entry.dart';
import '../../data/models/capture_entry.dart';
import '../../data/repositories/health_repository.dart';
import '../../data/repositories/mood_repository.dart';
import '../../data/repositories/capture_repository.dart';
import 'day_signals.dart';
import 'pattern_insight.dart';
import 'pattern_insight_repository.dart';
import 'user_baseline_profile.dart';
import 'pattern_modules/sleep_analyzer.dart';
import 'pattern_modules/mood_analyzer.dart';
import 'pattern_modules/hydration_analyzer.dart';
import 'pattern_modules/activity_analyzer.dart';
import 'pattern_modules/finance_analyzer.dart';
import 'pattern_modules/focus_analyzer.dart';
import 'pattern_modules/pattern_analyzer_base.dart';

/// Pattern Engine v2: modular, multi-window, baseline-aware intelligence.
///
/// Runs entirely on-device. Never sends data externally.
/// Does NOT diagnose ADHD — only surfaces behavioral patterns.
class PatternEngineV2 {
  static const _lastAnalysisKey = 'pattern_engine_v2_last_analysis';
  static const _lastOpenKey = 'pattern_engine_v2_last_open';
  static const _maxActiveInsights = 5;
  static const _analysisWindows = [7, 14, 30];
  static const _minCorrelation = 0.4;
  static const _minConfidence = 0.6;
  static const _reopenThresholdHours = 12;

  final HealthRepository _healthRepo = HealthRepository();
  final MoodRepository _moodRepo = MoodRepository();
  final CaptureRepository _captureRepo = CaptureRepository();
  final PatternInsightRepository _insightRepo = PatternInsightRepository();

  final List<PatternAnalyzerBase> _analyzers = [
    SleepPatternAnalyzer(),
    MoodPatternAnalyzer(),
    HydrationPatternAnalyzer(),
    ActivityPatternAnalyzer(),
    FinancePatternAnalyzer(),
    FocusPatternAnalyzer(),
  ];

  /// Returns cached insights or runs analysis based on run frequency rules.
  Future<List<PatternInsight>> getInsights({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final shouldRun = await _shouldRunAnalysis();
      if (!shouldRun) {
        final cached = await _insightRepo.getAll();
        if (cached.isNotEmpty) return cached.take(_maxActiveInsights).toList();
      }
    }
    return runAnalysis();
  }

  /// Full analysis pipeline across multiple time windows.
  Future<List<PatternInsight>> runAnalysis() async {
    try {
      final now = DateTime.now();
      final analysisDate = now.toIso8601String().substring(0, 10);

      // Load all raw data for the longest window
      final maxWindow = _analysisWindows.last;
      final start = now.subtract(Duration(days: maxWindow));

      final healthEntries = await _healthRepo.getByDateRange(start, now);
      final moodEntries = await _moodRepo.getAll();
      final captureEntries = await _captureRepo.getAll();

      // Update baseline if needed
      final baseline = await _updateBaselineIfNeeded(
        healthEntries, moodEntries, captureEntries, maxWindow,
      );

      // Run analyzers across all windows
      final allInsights = <PatternInsight>[];

      for (final windowDays in _analysisWindows) {
        final windowStart = now.subtract(Duration(days: windowDays));

        final moodInWindow =
            moodEntries.where((m) => m.createdAt.isAfter(windowStart)).toList();
        final captureInWindow =
            captureEntries.where((c) => c.createdAt.isAfter(windowStart)).toList();
        final healthInWindow =
            healthEntries.where((h) => h.date.isAfter(windowStart)).toList();

        final days = _aggregateByDay(healthInWindow, moodInWindow, captureInWindow, windowDays);
        if (days.length < 3) continue;

        for (final analyzer in _analyzers) {
          allInsights.addAll(analyzer.analyze(days, analysisDate, windowDays, baseline));
        }
      }

      // Filter: correlation > 0.4 and confidence > 0.6
      final filtered = allInsights.where((i) {
        if (i.correlationStrength != 0 && i.correlationStrength.abs() < _minCorrelation) {
          return false;
        }
        return i.confidence >= _minConfidence;
      }).toList();

      // Deduplicate: keep the best per base pattern id (strip window suffix)
      final bestByPattern = <String, PatternInsight>{};
      for (final insight in filtered) {
        final baseId = _basePatternId(insight.id);
        final existing = bestByPattern[baseId];
        if (existing == null || insight.confidence > existing.confidence) {
          bestByPattern[baseId] = insight;
        }
      }

      // Sort by confidence, limit to max active
      final results = bestByPattern.values.toList()
        ..sort((a, b) => b.confidence.compareTo(a.confidence));
      final topInsights = results.take(_maxActiveInsights).toList();

      // Persist & mark done
      await _insightRepo.replaceAll(topInsights);
      await _markRanToday();

      return topInsights;
    } catch (e) {
      debugPrint('PatternEngineV2 analysis failed: $e');
      return [];
    }
  }

  /// Detect significant behavioral changes and return event descriptions.
  Future<List<String>> detectBehavioralChanges() async {
    final events = <String>[];
    final baseline = await UserBaselineProfile.load();
    if (baseline == null) return events;

    final now = DateTime.now();
    final weekStart = now.subtract(const Duration(days: 7));

    final healthEntries = await _healthRepo.getByDateRange(weekStart, now);
    final moodEntries = await _moodRepo.getAll();

    // Check energy drop
    final recentMoods = moodEntries.where((m) => m.createdAt.isAfter(weekStart)).toList();
    if (recentMoods.length >= 3) {
      final avgEnergy = recentMoods.map((m) => m.energyLevel).reduce((a, b) => a + b) /
          recentMoods.length;
      if (avgEnergy < baseline.averageEnergy * 0.7) {
        events.add('Energy drop detected this week');
      }
    }

    // Check sleep drop
    final sleepEntries = healthEntries.where((h) => (h.sleepHours ?? 0) > 0).toList();
    if (sleepEntries.length >= 3) {
      final avgSleep = sleepEntries.map((h) => h.sleepHours ?? 0.0).reduce((a, b) => a + b) /
          sleepEntries.length;
      if (avgSleep < baseline.averageSleep * 0.75) {
        events.add('Sleep quality declining this week');
      }
    }

    // Check mood drop
    if (recentMoods.length >= 3) {
      final avgMood = recentMoods.map((m) => m.moodLevel).reduce((a, b) => a + b) /
          recentMoods.length;
      if (avgMood < baseline.averageMood * 0.7) {
        events.add('Mood trending lower than usual');
      }
    }

    return events;
  }

  /// Record that the app was opened (for 12-hour reopen trigger).
  Future<void> recordAppOpen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastOpenKey, DateTime.now().toIso8601String());
  }

  // ─── Private helpers ─────────────────────────────────────

  String _basePatternId(String id) {
    return id.replaceAll(RegExp(r'_\d+d$'), '');
  }

  Future<bool> _shouldRunAnalysis() async {
    final prefs = await SharedPreferences.getInstance();

    // Check daily run
    final lastAnalysis = prefs.getString(_lastAnalysisKey);
    if (lastAnalysis == null) return true;
    final lastDate = DateTime.tryParse(lastAnalysis);
    if (lastDate == null) return true;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (lastAnalysis.substring(0, 10) != today) return true;

    // Check 12-hour reopen
    final lastOpen = prefs.getString(_lastOpenKey);
    if (lastOpen != null) {
      final lastOpenDate = DateTime.tryParse(lastOpen);
      if (lastOpenDate != null) {
        final hoursSinceOpen = DateTime.now().difference(lastOpenDate).inHours;
        if (hoursSinceOpen >= _reopenThresholdHours) return true;
      }
    }

    return false;
  }

  Future<void> _markRanToday() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastAnalysisKey, DateTime.now().toIso8601String());
  }

  Future<UserBaselineProfile?> _updateBaselineIfNeeded(
    List<HealthEntry> healthEntries,
    List<MoodEntry> moodEntries,
    List<CaptureEntry> captureEntries,
    int windowDays,
  ) async {
    var baseline = await UserBaselineProfile.load();
    if (!UserBaselineProfile.needsUpdate(baseline)) return baseline;

    final days = _aggregateByDay(healthEntries, moodEntries, captureEntries, windowDays);
    if (days.length < 3) return baseline;

    final sleepDays = days.where((d) => d.hasSleep).toList();
    final moodDays = days.where((d) => d.hasMood).toList();
    final energyDays = days.where((d) => d.hasEnergy).toList();
    final stepDays = days.where((d) => d.steps > 0).toList();
    final hydDays = days.where((d) => d.hasHydration).toList();

    baseline = UserBaselineProfile(
      averageSleep: sleepDays.isEmpty
          ? 7.0
          : sleepDays.map((d) => d.sleepHours).reduce((a, b) => a + b) / sleepDays.length,
      averageMood: moodDays.isEmpty
          ? 3.0
          : moodDays.map((d) => d.avgMood).reduce((a, b) => a + b) / moodDays.length,
      averageEnergy: energyDays.isEmpty
          ? 3.0
          : energyDays.map((d) => d.avgEnergy).reduce((a, b) => a + b) / energyDays.length,
      averageSteps: stepDays.isEmpty
          ? 5000
          : (stepDays.map((d) => d.steps).reduce((a, b) => a + b) / stepDays.length).round(),
      averageHydration: hydDays.isEmpty
          ? 2.0
          : hydDays.map((d) => d.waterLiters).reduce((a, b) => a + b) / hydDays.length,
      lastUpdated: DateTime.now().toIso8601String().substring(0, 10),
    );
    await baseline.save();

    return baseline;
  }

  List<DaySignals> _aggregateByDay(
    List<HealthEntry> health,
    List<MoodEntry> moods,
    List<CaptureEntry> captures,
    int windowDays,
  ) {
    final now = DateTime.now();
    final dayMap = <String, DaySignals>{};

    for (int i = 0; i < windowDays; i++) {
      final d = now.subtract(Duration(days: i));
      final key = _dayKey(d);
      dayMap[key] = DaySignals(date: DateTime(d.year, d.month, d.day));
    }

    for (final h in health) {
      final key = _dayKey(h.date);
      final day = dayMap[key];
      if (day == null) continue;
      day.sleepHours = h.sleepHours ?? 0;
      day.waterLiters = h.waterLiters;
      day.exerciseMinutes = h.exerciseMinutes ?? 0;
      day.steps = h.steps ?? 0;
    }

    for (final m in moods) {
      final key = _dayKey(m.createdAt);
      final day = dayMap[key];
      if (day == null) continue;
      day.moodLevels.add(m.moodLevel);
      day.energyLevels.add(m.energyLevel);
    }

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
}
