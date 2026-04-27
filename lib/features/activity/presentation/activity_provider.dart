import 'package:flutter/foundation.dart';
import '../data/activity_repository.dart';
import '../data/health_connect_service.dart';
import '../domain/activity_entry.dart';

class ActivityProvider extends ChangeNotifier {
  final ActivityRepository _repository = ActivityRepository();
  final HealthConnectService _healthConnect = HealthConnectService();

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

  Future<void> initialize() async {
    await _healthConnect.initialize();
    _healthPermissionStatus = _healthConnect.permissionStatus;
    _healthDataAvailable = _healthConnect.isAvailable;
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

  Future<void> syncFromHealthConnect({DateTime? date}) async {
    if (!_healthConnect.hasPermission) {
      _healthDataAvailable = false;
      notifyListeners();
      return;
    }

    try {
      final targetDate = date ?? DateTime.now();
      final summary = await _healthConnect.fetchDailySummary(targetDate);
      if (summary == null) {
        _healthDataAvailable = false;
        notifyListeners();
        return;
      }

      _healthDataAvailable = true;

      final dailySummary = DailyHealthSummary(
        date: _dateKey(targetDate),
        steps: summary.steps,
        distanceKm: summary.distanceMeters / 1000.0,
        activeMinutes: summary.activeMinutes,
      );
      await _repository.upsertDailySummary(dailySummary);
      _todaySummary = dailySummary;

      // Also store as activity entry for backward compatibility
      await _healthConnect.syncTodayData();
      await loadEntries();

      // Check step milestones
      _checkStepMilestones(summary.steps);
    } catch (e) {
      debugPrint('Failed to sync from Health Connect: $e');
      _healthDataAvailable = false;
      notifyListeners();
    }
  }

  /// Step milestone callback — set by main.dart to create timeline events.
  static void Function(int steps, int milestone)? onStepMilestone;

  static const _stepMilestones = [5000, 10000];

  void _checkStepMilestones(int steps) {
    for (final milestone in _stepMilestones) {
      if (steps >= milestone) {
        final key = '${_dateKey(DateTime.now())}_$milestone';
        if (!_firedMilestones.contains(key)) {
          _firedMilestones.add(key);
          onStepMilestone?.call(steps, milestone);
        }
      }
    }
  }

  final Set<String> _firedMilestones = {};

  List<ActivityEntry> getEntriesForDate(DateTime date) {
    return _entries.where((e) {
      return e.startTime.year == date.year &&
          e.startTime.month == date.month &&
          e.startTime.day == date.day;
    }).toList();
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
