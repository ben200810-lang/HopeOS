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

  List<ActivityEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  HealthPermissionStatus get healthPermissionStatus =>
      _healthPermissionStatus;
  bool get isHealthConnectAvailable => _healthConnect.isAvailable;
  bool get hasHealthPermission => _healthConnect.hasPermission;

  Future<void> initialize() async {
    await _healthConnect.initialize();
    _healthPermissionStatus = _healthConnect.permissionStatus;
    await loadEntries();
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
    if (!_healthConnect.hasPermission) return;

    try {
      await _healthConnect.syncTodayData();
      await loadEntries();
    } catch (e) {
      debugPrint('Failed to sync from Health Connect: $e');
    }
  }

  List<ActivityEntry> getEntriesForDate(DateTime date) {
    return _entries.where((e) {
      return e.startTime.year == date.year &&
          e.startTime.month == date.month &&
          e.startTime.day == date.day;
    }).toList();
  }

  int get todaySteps {
    final today = DateTime.now();
    return getEntriesForDate(today)
        .fold(0, (sum, e) => sum + (e.steps ?? 0));
  }

  int get todayActiveMinutes {
    final today = DateTime.now();
    return getEntriesForDate(today)
        .fold(0, (sum, e) => sum + e.durationMinutes);
  }
}
