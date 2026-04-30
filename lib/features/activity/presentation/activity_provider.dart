import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/step_counter_service.dart';
import '../data/activity_repository.dart';
import '../data/health_connect_service.dart';
import '../domain/activity_entry.dart';

class ActivityProvider extends ChangeNotifier {
  final ActivityRepository _repository = ActivityRepository();
  final HealthConnectService _healthConnect = HealthConnectService();
  final StepCounterService _stepCounter = StepCounterService();
  bool _sensorAvailable = false;

  List<ActivityEntry> _entries = [];
  bool _isLoading = false;
  HealthPermissionStatus _healthPermissionStatus =
      HealthPermissionStatus.unavailable;
  DailyHealthSummary? _todaySummary;
  bool _healthDataAvailable = true;

  List<ActivityEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  HealthPermissionStatus get healthPermissionStatus =>
      _healthPermissionStatus;
  bool get isHealthConnectAvailable => _healthConnect.isAvailable;
  bool get hasHealthPermission => _healthConnect.hasPermission;
  DailyHealthSummary? get todaySummary => _todaySummary;
  bool get healthDataAvailable => _healthDataAvailable;

  bool get sensorAvailable => _sensorAvailable;

  Future<void> initialize() async {
    await _healthConnect.initialize();
    _healthPermissionStatus = _healthConnect.permissionStatus;
    _healthDataAvailable = _healthConnect.isAvailable;
    _sensorAvailable = await _stepCounter.isAvailable;
    await loadEntries();
    await _loadTodaySummary();
  }

  Future<void> _loadTodaySummary() async {
    final todayKey = _dateKey(DateTime.now());
    _todaySummary = await _repository.getDailySummary(todayKey);
    notifyListeners();
  }

  Future<void> loadEntries() async {
    _isLoading = true;
    notifyListeners();

    try {
      _entries = await _repository.getAll();
    } catch (e) {
      debugPrint('Failed to load activity entries: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addManualEntry(ActivityEntry entry) async {
    await _repository.insert(entry);
    await loadEntries();
  }

  Future<void> deleteEntry(String id) async {
    await _repository.delete(id);
    await loadEntries();
  }

  Future<bool> requestHealthPermissions() async {
    final granted = await _healthConnect.requestPermissions();
    _healthPermissionStatus = _healthConnect.permissionStatus;
    notifyListeners();
    return granted;
  }

  /// Sync data: try Health Connect first, fall back to device sensor.
  Future<void> syncHealthData({DateTime? date}) async {
    final targetDate = date ?? DateTime.now();

    // Try Health Connect first (attempt even when permission status is
    // indeterminate — Health Connect's hasPermissions often returns null).
    if (_healthConnect.shouldAttemptFetch) {
      try {
        final summary = await _healthConnect.fetchDailySummary(targetDate);
        if (summary != null) {
          _healthDataAvailable = true;

          final dailySummary = DailyHealthSummary(
            date: _dateKey(targetDate),
            steps: summary.steps,
            distanceKm: summary.distanceMeters / 1000.0,
            activeMinutes: summary.activeMinutes,
          );
          await _repository.upsertDailySummary(dailySummary);
          _todaySummary = dailySummary;
          await loadEntries();
          _checkStepMilestones(summary.steps);
          return;
        }
      } catch (e) {
        debugPrint('Health Connect sync failed, trying sensor: $e');
      }
    }

    // Fall back to device step counter sensor
    if (_sensorAvailable) {
      try {
        final sensorSteps = await _stepCounter.getTodaySteps();
        // Sensor exists → health data is available regardless of count.
        _healthDataAvailable = true;

        if (sensorSteps > 0) {
          final dailySummary = DailyHealthSummary(
            date: _dateKey(targetDate),
            steps: sensorSteps,
            distanceKm: _estimateDistanceKm(sensorSteps),
            activeMinutes: 0,
          );
          await _repository.upsertDailySummary(dailySummary);
          _todaySummary = dailySummary;
          _checkStepMilestones(sensorSteps);
        }
        notifyListeners();
        return;
      } catch (e) {
        debugPrint('Sensor step count failed: $e');
      }
    }

    // No data source available
    _healthDataAvailable = _todaySummary != null;
    notifyListeners();
  }

  /// Kept for backward compatibility.
  Future<void> syncFromHealthConnect({DateTime? date}) => syncHealthData(date: date);

  /// Estimate distance from step count (avg stride ~0.75m).
  double _estimateDistanceKm(int steps) => (steps * 0.75) / 1000.0;

  /// Step milestone callback — set by main.dart to create timeline events.
  static void Function(int steps, int milestone)? onStepMilestone;

  static const _stepMilestones = [5000, 10000];
  static const _firedMilestonesKey = 'fired_step_milestones';

  Future<void> _checkStepMilestones(int steps) async {
    final prefs = await SharedPreferences.getInstance();
    final fired = prefs.getStringList(_firedMilestonesKey) ?? [];
    final firedSet = fired.toSet();

    for (final milestone in _stepMilestones) {
      if (steps >= milestone) {
        final key = '${_dateKey(DateTime.now())}_$milestone';
        if (!firedSet.contains(key)) {
          firedSet.add(key);
          onStepMilestone?.call(steps, milestone);
        }
      }
    }

    // Prune old entries (keep only today's)
    final todayPrefix = _dateKey(DateTime.now());
    firedSet.removeWhere((k) => !k.startsWith(todayPrefix));
    await prefs.setStringList(_firedMilestonesKey, firedSet.toList());
  }

  List<ActivityEntry> getEntriesForDate(DateTime date) {
    return _entries.where((e) {
      return e.startTime.year == date.year &&
          e.startTime.month == date.month &&
          e.startTime.day == date.day;
    }).toList();
  }

  /// Fetch steps from device sensor (fallback when Health Connect unavailable).
  Future<int> getSensorSteps() async {
    if (!_sensorAvailable) return 0;
    return _stepCounter.getTodaySteps();
  }

  int get todaySteps {
    if (_todaySummary != null) return _todaySummary!.steps;
    final today = DateTime.now();
    return getEntriesForDate(today)
        .fold(0, (sum, e) => sum + (e.steps ?? 0));
  }

  double get todayDistanceKm {
    if (_todaySummary != null) return _todaySummary!.distanceKm;
    final today = DateTime.now();
    final meters = getEntriesForDate(today)
        .fold(0.0, (sum, e) => sum + (e.distanceMeters ?? 0));
    return meters / 1000.0;
  }

  int get todayActiveMinutes {
    if (_todaySummary != null) return _todaySummary!.activeMinutes;
    final today = DateTime.now();
    return getEntriesForDate(today)
        .fold(0, (sum, e) => sum + e.durationMinutes);
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
