import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../domain/activity_entry.dart';

enum HealthPermissionStatus { granted, denied, unavailable }

class HealthConnectService {
  static final HealthConnectService _instance = HealthConnectService._();
  factory HealthConnectService() => _instance;
  HealthConnectService._();

  bool _initialized = false;
  HealthPermissionStatus _permissionStatus = HealthPermissionStatus.unavailable;

  bool get isInitialized => _initialized;
  HealthPermissionStatus get permissionStatus => _permissionStatus;
  bool get isAvailable =>
      _permissionStatus != HealthPermissionStatus.unavailable;
  bool get hasPermission =>
      _permissionStatus == HealthPermissionStatus.granted;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Check platform availability
      // The `health` package handles Health Connect / Google Fit detection.
      // For now this is a scaffold — actual integration requires running
      // on a real Android device with Health Connect installed.
      _permissionStatus = HealthPermissionStatus.unavailable;
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
      // TODO: Implement actual Health Connect permission request
      // using the `health` package when running on Android.
      //
      // Example (to be activated on real device):
      // final health = HealthFactory();
      // final types = [
      //   HealthDataType.STEPS,
      //   HealthDataType.DISTANCE_DELTA,
      //   HealthDataType.ACTIVE_ENERGY_BURNED,
      //   HealthDataType.WORKOUT,
      // ];
      // final granted = await health.requestAuthorization(types);
      _permissionStatus = HealthPermissionStatus.unavailable;
      return false;
    } catch (e) {
      debugPrint('HealthConnect permission request failed: $e');
      return false;
    }
  }

  Future<ActivityDailySummary?> fetchDailySummary(DateTime date) async {
    if (!hasPermission) return null;

    try {
      // TODO: Fetch real data from Health Connect / Google Fit
      // For now return null — scaffold only
      return null;
    } catch (e) {
      debugPrint('HealthConnect fetch failed: $e');
      return null;
    }
  }

  Future<List<ActivityEntry>> fetchActivities(
      DateTime start, DateTime end) async {
    if (!hasPermission) return [];

    try {
      // TODO: Fetch workout data from Health Connect / Google Fit
      // and convert to ActivityEntry list
      return [];
    } catch (e) {
      debugPrint('HealthConnect fetch activities failed: $e');
      return [];
    }
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
