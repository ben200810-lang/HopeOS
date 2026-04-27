import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:uuid/uuid.dart';
import '../domain/activity_entry.dart';
import 'activity_repository.dart';

enum HealthPermissionStatus { granted, denied, unavailable }

class HealthConnectService {
  static final HealthConnectService _instance = HealthConnectService._();
  factory HealthConnectService() => _instance;
  HealthConnectService._();

  final Health _health = Health();
  final ActivityRepository _repository = ActivityRepository();

  bool _initialized = false;
  HealthPermissionStatus _permissionStatus = HealthPermissionStatus.unavailable;

  bool get isInitialized => _initialized;
  HealthPermissionStatus get permissionStatus => _permissionStatus;
  bool get isAvailable =>
      _permissionStatus != HealthPermissionStatus.unavailable;
  bool get hasPermission =>
      _permissionStatus == HealthPermissionStatus.granted;

  static const _dataTypes = [
    HealthDataType.STEPS,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.WORKOUT,
  ];

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await _health.configure();
      final hasPermissions = await _health.hasPermissions(_dataTypes);
      if (hasPermissions == true) {
        _permissionStatus = HealthPermissionStatus.granted;
      } else {
        _permissionStatus = HealthPermissionStatus.denied;
      }
      _initialized = true;
    } catch (e) {
      debugPrint('HealthConnect init failed: $e');
      _permissionStatus = HealthPermissionStatus.unavailable;
      _initialized = true;
    }
  }

  Future<bool> requestPermissions() async {
    if (!_initialized) await initialize();

    try {
      final granted = await _health.requestAuthorization(
        _dataTypes,
        permissions: [
          HealthDataAccess.READ,
          HealthDataAccess.READ,
          HealthDataAccess.READ,
          HealthDataAccess.READ,
        ],
      );
      _permissionStatus = granted
          ? HealthPermissionStatus.granted
          : HealthPermissionStatus.denied;
      return granted;
    } catch (e) {
      debugPrint('HealthConnect permission request failed: $e');
      _permissionStatus = HealthPermissionStatus.denied;
      return false;
    }
  }

  Future<ActivityDailySummary?> fetchDailySummary(DateTime date) async {
    if (!hasPermission) return null;

    try {
      final start = DateTime(date.year, date.month, date.day);
      final end = DateTime(date.year, date.month, date.day, 23, 59, 59);

      // Fetch steps
      final stepsTotal = await _health.getTotalStepsInInterval(start, end);
      final steps = stepsTotal ?? 0;

      // Fetch active energy
      final energyData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
        startTime: start,
        endTime: end,
      );
      double caloriesBurned = 0;
      for (final point in energyData) {
        final value = point.value;
        if (value is NumericHealthValue) {
          caloriesBurned += value.numericValue.toDouble();
        }
      }

      // Fetch distance
      final distanceData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.DISTANCE_DELTA],
        startTime: start,
        endTime: end,
      );
      double distanceMeters = 0;
      for (final point in distanceData) {
        final value = point.value;
        if (value is NumericHealthValue) {
          distanceMeters += value.numericValue.toDouble();
        }
      }

      // Fetch workouts for active minutes
      final workoutData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.WORKOUT],
        startTime: start,
        endTime: end,
      );
      int activeMinutes = 0;
      for (final point in workoutData) {
        final duration =
            point.dateTo.difference(point.dateFrom).inMinutes;
        activeMinutes += duration;
      }

      return ActivityDailySummary(
        steps: steps,
        distanceMeters: distanceMeters,
        activeMinutes: activeMinutes,
        caloriesBurned: caloriesBurned.round(),
      );
    } catch (e) {
      debugPrint('HealthConnect fetch failed: $e');
      return null;
    }
  }

  Future<List<ActivityEntry>> fetchActivities(
      DateTime start, DateTime end) async {
    if (!hasPermission) return [];

    try {
      final workoutData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.WORKOUT],
        startTime: start,
        endTime: end,
      );

      return workoutData.map((point) {
        final duration =
            point.dateTo.difference(point.dateFrom).inMinutes;
        return ActivityEntry(
          id: const Uuid().v4(),
          activityType: point.type.name,
          durationMinutes: duration,
          source: 'health_connect',
          startTime: point.dateFrom,
          endTime: point.dateTo,
          createdAt: DateTime.now(),
        );
      }).toList();
    } catch (e) {
      debugPrint('HealthConnect fetch activities failed: $e');
      return [];
    }
  }

  Future<void> syncTodayData() async {
    if (!hasPermission) return;

    final today = DateTime.now();
    final summary = await fetchDailySummary(today);
    if (summary == null) return;

    final entry = _createDailySummaryEntry(summary, today);
    await _repository.insert(entry);
  }

  ActivityEntry _createDailySummaryEntry(
      ActivityDailySummary summary, DateTime date) {
    return ActivityEntry(
      id: const Uuid().v4(),
      activityType: 'daily_summary',
      durationMinutes: summary.activeMinutes,
      steps: summary.steps,
      distanceMeters: summary.distanceMeters,
      caloriesBurned: summary.caloriesBurned,
      source: 'health_connect',
      startTime: DateTime(date.year, date.month, date.day),
      endTime: DateTime(date.year, date.month, date.day, 23, 59, 59),
      createdAt: DateTime.now(),
    );
  }
}

class ActivityDailySummary {
  final int steps;
  final double distanceMeters;
  final int activeMinutes;
  final int caloriesBurned;

  const ActivityDailySummary({
    required this.steps,
    required this.distanceMeters,
    required this.activeMinutes,
    required this.caloriesBurned,
  });
}
