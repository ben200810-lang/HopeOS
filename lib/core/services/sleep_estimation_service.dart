import 'package:flutter/foundation.dart';
import '../../features/activity/data/screen_time_service.dart';
import '../../features/activity/data/health_connect_service.dart';

class SleepEstimate {
  final double hours;
  final DateTime? estimatedBedtime;
  final DateTime? estimatedWakeTime;
  final SleepConfidence confidence;
  final List<String> dataSources;

  const SleepEstimate({
    required this.hours,
    this.estimatedBedtime,
    this.estimatedWakeTime,
    required this.confidence,
    required this.dataSources,
  });

  String get formattedHours {
    final h = hours.floor();
    final m = ((hours - h) * 60).round();
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }
}

enum SleepConfidence { high, medium, low }

class SleepEstimationService {
  static final SleepEstimationService _instance = SleepEstimationService._();
  factory SleepEstimationService() => _instance;
  SleepEstimationService._();

  final ScreenTimeService _screenTime = ScreenTimeService();
  final HealthConnectService _healthConnect = HealthConnectService();

  Future<SleepEstimate?> estimateSleep(DateTime date) async {
    double? screenBasedHours;
    double? movementBasedHours;
    final sources = <String>[];

    // 1. Screen time based estimation
    screenBasedHours = await _estimateFromScreenTime(date);
    if (screenBasedHours != null) sources.add('screen_time');

    // 2. Movement/steps based estimation
    movementBasedHours = await _estimateFromMovement(date);
    if (movementBasedHours != null) sources.add('movement');

    if (sources.isEmpty) return null;

    // Combine estimates with weighted average
    double estimatedHours;
    SleepConfidence confidence;

    if (screenBasedHours != null && movementBasedHours != null) {
      // Both sources available — weighted average (screen time is more reliable)
      estimatedHours = screenBasedHours * 0.6 + movementBasedHours * 0.4;
      confidence = SleepConfidence.high;
    } else if (screenBasedHours != null) {
      estimatedHours = screenBasedHours;
      confidence = SleepConfidence.medium;
    } else {
      estimatedHours = movementBasedHours!;
      confidence = SleepConfidence.low;
    }

    // Clamp to reasonable range
    estimatedHours = estimatedHours.clamp(0.0, 14.0);

    // Round to nearest 0.5
    estimatedHours = (estimatedHours * 2).roundToDouble() / 2;

    // Estimate bed/wake times
    final bedtime = _estimateBedtime(date, estimatedHours);
    final wakeTime = bedtime?.add(Duration(minutes: (estimatedHours * 60).round()));

    return SleepEstimate(
      hours: estimatedHours,
      estimatedBedtime: bedtime,
      estimatedWakeTime: wakeTime,
      confidence: confidence,
      dataSources: sources,
    );
  }

  Future<double?> _estimateFromScreenTime(DateTime date) async {
    if (!_screenTime.hasPermission) {
      final granted = await _screenTime.checkPermission();
      if (!granted) return null;
    }

    try {
      // Get screen time for the target date and previous day
      final todayData = await _screenTime.fetchDailyScreenTime(date);
      final yesterdayData = await _screenTime.fetchDailyScreenTime(
        date.subtract(const Duration(days: 1)),
      );

      if (todayData == null && yesterdayData == null) return null;

      final totalScreenMinutes = todayData?.totalMinutes ?? 0;
      final lateNightMinutes = yesterdayData?.lateNightMinutes ?? 0;

      // Heuristic: 24h minus total screen time gives inactive time.
      // Late night usage reduces sleep estimate (using phone instead of sleeping).
      // Assume ~4h of non-screen non-sleep activity (eating, showering, etc.)
      final inactiveHours = (24 * 60 - totalScreenMinutes) / 60.0;
      final nonSleepHours = 4.0 + (lateNightMinutes / 60.0);
      final estimatedSleep = inactiveHours - nonSleepHours;

      if (estimatedSleep < 2 || estimatedSleep > 14) return null;
      return estimatedSleep;
    } catch (e) {
      debugPrint('Sleep estimation from screen time failed: $e');
      return null;
    }
  }

  Future<double?> _estimateFromMovement(DateTime date) async {
    if (!_healthConnect.shouldAttemptFetch) return null;

    try {
      final summary = await _healthConnect.fetchDailySummary(date);
      if (summary == null) return null;

      final steps = summary.steps;
      final activeMinutes = summary.activeMinutes;

      // Heuristic: people who move very little were probably sleeping longer.
      // Average person takes ~6000-8000 steps when awake for 16h.
      // Fewer steps → more time sleeping.
      // Active minutes directly indicate awake-and-moving time.
      final stepsPerWakingHour = 450; // ~7200 steps / 16 waking hours
      final estimatedWakingHoursFromSteps = steps / stepsPerWakingHour;
      final estimatedSleepFromSteps = 24 - estimatedWakingHoursFromSteps;

      // Also factor in active minutes
      double estimatedSleepFromActivity;
      if (activeMinutes > 0) {
        // Active people tend to sleep about 7-9h
        // More active → better sleep quality but similar duration
        estimatedSleepFromActivity = 24 - (activeMinutes / 60.0) - 14.0;
        estimatedSleepFromActivity = estimatedSleepFromActivity.clamp(6.0, 10.0);
      } else {
        estimatedSleepFromActivity = estimatedSleepFromSteps;
      }

      final estimate = (estimatedSleepFromSteps + estimatedSleepFromActivity) / 2;

      if (estimate < 2 || estimate > 14) return null;
      return estimate;
    } catch (e) {
      debugPrint('Sleep estimation from movement failed: $e');
      return null;
    }
  }

  DateTime? _estimateBedtime(DateTime date, double sleepHours) {
    // Default bedtime assumption: wake at 7:00, so bedtime = 7:00 - sleepHours
    final wakeHour = 7;
    final sleepMinutes = (sleepHours * 60).round();
    final wakeTime = DateTime(date.year, date.month, date.day, wakeHour);
    return wakeTime.subtract(Duration(minutes: sleepMinutes));
  }
}
