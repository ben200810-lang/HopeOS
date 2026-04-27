import 'package:flutter/foundation.dart';
import 'notification_service.dart';

/// Manages the persistent quick-capture notification lifecycle.
///
/// Responsibilities:
/// - Show / hide the ongoing notification based on user preference.
/// - Re-show after app restart if the setting is still enabled.
/// - Coordinate with the Android boot receiver to re-show after reboot.
class QuickActionNotificationManager {
  static final QuickActionNotificationManager _instance =
      QuickActionNotificationManager._();
  factory QuickActionNotificationManager() => _instance;
  QuickActionNotificationManager._();

  final NotificationService _notifService = NotificationService();

  bool _isShowing = false;
  bool get isShowing => _isShowing;

  /// Show the persistent notification with all 5 quick-action buttons.
  /// Called on app start (if enabled) and after permission grant.
  Future<void> show() async {
    try {
      await _notifService.showQuickCaptureNotification(enabled: true);
      _isShowing = true;
      debugPrint('QuickActionNotificationManager: notification shown');
    } catch (e) {
      debugPrint('QuickActionNotificationManager: show failed: $e');
    }
  }

  /// Hide the persistent notification.
  Future<void> hide() async {
    try {
      await _notifService.showQuickCaptureNotification(enabled: false);
      _isShowing = false;
      debugPrint('QuickActionNotificationManager: notification hidden');
    } catch (e) {
      debugPrint('QuickActionNotificationManager: hide failed: $e');
    }
  }

  /// Restore the notification if the user's preference says it should be on.
  /// Called during app initialization and after device reboot.
  Future<void> restoreIfEnabled({required bool quickCaptureEnabled}) async {
    if (quickCaptureEnabled) {
      await show();
    } else {
      _isShowing = false;
    }
  }

  /// Toggle the notification on/off and return the new state.
  Future<bool> toggle({required bool enabled}) async {
    if (enabled) {
      await show();
    } else {
      await hide();
    }
    return _isShowing;
  }
}
