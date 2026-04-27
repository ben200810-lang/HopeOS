import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Reads steps from the device's built-in step counter sensor
/// via a native MethodChannel. Works on virtually all modern
/// Android devices without requiring Health Connect.
class StepCounterService {
  static final StepCounterService _instance = StepCounterService._();
  factory StepCounterService() => _instance;
  StepCounterService._();

  static const _channel = MethodChannel('com.hopeos.app/step_counter');

  /// Whether the hardware step counter sensor is available.
  Future<bool> get isAvailable async {
    try {
      final result = await _channel.invokeMethod<bool>('isAvailable');
      return result ?? false;
    } catch (e) {
      debugPrint('StepCounterService: availability check failed: $e');
      return false;
    }
  }

  /// Today's step count from the device sensor.
  Future<int> getTodaySteps() async {
    try {
      final result = await _channel.invokeMethod<int>('getTodaySteps');
      return result ?? 0;
    } catch (e) {
      debugPrint('StepCounterService: getTodaySteps failed: $e');
      return 0;
    }
  }
}
