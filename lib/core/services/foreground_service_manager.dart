import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Controls the Android foreground service that keeps HopeOS alive
/// in the background for persistent quick-capture notifications.
class ForegroundServiceManager {
  static final ForegroundServiceManager _instance =
      ForegroundServiceManager._();
  factory ForegroundServiceManager() => _instance;
  ForegroundServiceManager._();

  static const _channel = MethodChannel('com.hopeos.app/foreground_service');

  /// Start the foreground service. Persists across app restarts
  /// and device reboots.
  Future<bool> startService() async {
    try {
      final result = await _channel.invokeMethod<bool>('startService');
      debugPrint('ForegroundServiceManager: started = $result');
      return result ?? false;
    } catch (e) {
      debugPrint('ForegroundServiceManager: start failed: $e');
      return false;
    }
  }

  /// Stop the foreground service.
  Future<bool> stopService() async {
    try {
      final result = await _channel.invokeMethod<bool>('stopService');
      debugPrint('ForegroundServiceManager: stopped = $result');
      return result ?? false;
    } catch (e) {
      debugPrint('ForegroundServiceManager: stop failed: $e');
      return false;
    }
  }

  /// Check if the foreground service is enabled (will restart on boot).
  Future<bool> isServiceRunning() async {
    try {
      final result = await _channel.invokeMethod<bool>('isServiceRunning');
      return result ?? false;
    } catch (e) {
      debugPrint('ForegroundServiceManager: check failed: $e');
      return false;
    }
  }

  /// Request battery optimization exemption so Android doesn't
  /// kill the service in Doze mode.
  Future<bool> requestBatteryOptimizationExemption() async {
    try {
      final result = await _channel
          .invokeMethod<bool>('requestBatteryOptimizationExemption');
      return result ?? false;
    } catch (e) {
      debugPrint('ForegroundServiceManager: battery opt failed: $e');
      return false;
    }
  }

  /// Check if the app is already exempt from battery optimization.
  Future<bool> isBatteryOptimizationExempt() async {
    try {
      final result =
          await _channel.invokeMethod<bool>('isBatteryOptimizationExempt');
      return result ?? false;
    } catch (e) {
      debugPrint('ForegroundServiceManager: battery check failed: $e');
      return false;
    }
  }

  /// Start or stop the service based on the [enabled] flag.
  Future<void> toggle(bool enabled) async {
    if (enabled) {
      await startService();
    } else {
      await stopService();
    }
  }
}
