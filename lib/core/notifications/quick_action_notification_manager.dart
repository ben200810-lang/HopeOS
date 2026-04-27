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
  /// Pass localized [title] and [body] from a call site that has l10n access.
  Future<void> show({String? title, String? body}) async {
    try {
      await _notifService.showQuickCaptureNotification(
        enabled: true,
        title: title ?? 'HopeOS',
        body: body ?? 'Quick log actions',
      );
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
  /// Pass localized [title] and [body] when available.
  Future<void> restoreIfEnabled({
    required bool quickCaptureEnabled,
    String? title,
    String? body,
  }) async {
    if (quickCaptureEnabled) {
      await show(title: title, body: body);
    } else {
      _isShowing = false;
    }
  }

  /// Toggle the notification on/off and return the new state.
  Future<bool> toggle({
    required bool enabled,
    String? title,
    String? body,
  }) async {
    if (enabled) {
      await show(title: title, body: body);
    } else {
      await hide();
    }
    return _isShowing;
  }
}
