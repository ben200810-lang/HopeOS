import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ScreenTimeData {
  final int totalMinutes;
  final int lateNightMinutes;
  final DateTime date;

  const ScreenTimeData({
    required this.totalMinutes,
    required this.lateNightMinutes,
    required this.date,
  });

  bool get hasLateNightUsage => lateNightMinutes > 30;

  String get formattedTotal {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

class ScreenTimeService {
  static final ScreenTimeService _instance = ScreenTimeService._();
  factory ScreenTimeService() => _instance;
  ScreenTimeService._();

  static const _platform = MethodChannel('com.hopeos.app/screen_time');

  bool _hasPermission = false;
  bool get hasPermission => _hasPermission;

  Future<bool> checkPermission() async {
    try {
      final result =
          await _platform.invokeMethod<bool>('hasUsageStatsPermission');
      _hasPermission = result ?? false;
      return _hasPermission;
    } catch (e) {
      debugPrint('ScreenTime permission check failed: $e');
      _hasPermission = false;
      return false;
    }
  }

  Future<void> openUsageSettings() async {
    try {
      await _platform.invokeMethod('openUsageAccessSettings');
    } catch (e) {
      debugPrint('Failed to open usage settings: $e');
    }
  }

  Future<ScreenTimeData?> fetchDailyScreenTime(DateTime date) async {
    if (!_hasPermission) return null;

    try {
      final result = await _platform.invokeMethod<Map>('getDailyScreenTime', {
        'year': date.year,
        'month': date.month,
        'day': date.day,
      });

      if (result == null) return null;

      return ScreenTimeData(
        totalMinutes: (result['totalMinutes'] as int?) ?? 0,
        lateNightMinutes: (result['lateNightMinutes'] as int?) ?? 0,
        date: date,
      );
    } catch (e) {
      debugPrint('ScreenTime fetch failed: $e');
      return null;
    }
  }

  Future<List<ScreenTimeData>> fetchWeeklyScreenTime() async {
    if (!_hasPermission) return [];

    final results = <ScreenTimeData>[];
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final data = await fetchDailyScreenTime(date);
      if (data != null) {
        results.add(data);
      }
    }

    return results;
  }
}
