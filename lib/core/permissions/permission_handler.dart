import 'package:flutter/material.dart';
import 'package:hopeos/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../notifications/notification_service.dart';
import '../../features/activity/data/health_connect_service.dart';

class PermissionHandler {
  static const _notificationAskedKey = 'notification_permission_asked';
  static const _healthAskedKey = 'health_permission_asked';

  static Future<bool> hasAskedNotification() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationAskedKey) ?? false;
  }

  static Future<void> markNotificationAsked() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationAskedKey, true);
  }

  static Future<bool> hasAskedHealth() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_healthAskedKey) ?? false;
  }

  static Future<void> markHealthAsked() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_healthAskedKey, true);
  }

  static Future<void> requestPermissionsIfNeeded(BuildContext context) async {
    final notifAsked = await hasAskedNotification();
    if (!notifAsked && context.mounted) {
      await _showNotificationDialog(context);
      await markNotificationAsked();
    }

    final healthAsked = await hasAskedHealth();
    if (!healthAsked && context.mounted) {
      await _showHealthDialog(context);
      await markHealthAsked();
    }
  }

  static Future<void> _showNotificationDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.notifications_outlined, size: 48),
        title: Text(l10n?.notificationPermission ?? 'Notification Permission'),
        content: Text(
          l10n?.notificationPermissionExplanation ??
              'HopeOS needs notification permission to send you gentle reminders for water, sleep, and daily reflections.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n?.skipForNow ?? 'Skip for now'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n?.allowNotifications ?? 'Allow Notifications'),
          ),
        ],
      ),
    );

    if (result == true) {
      final notifService = NotificationService();
      final granted = await notifService.requestPermissions();
      if (!granted && context.mounted) {
        _showDeniedExplanation(
          context,
          l10n?.notificationDeniedExplanation ??
              'You can enable notifications later in Settings to receive helpful reminders.',
        );
      }
    }
  }

  static Future<void> _showHealthDialog(BuildContext context) async {
    final healthService = HealthConnectService();
    await healthService.initialize();

    if (!healthService.isAvailable && !healthService.isInitialized) return;
    if (!context.mounted) return;

    final l10n = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.directions_walk_outlined, size: 48),
        title: Text(l10n?.healthPermission ?? 'Health Permission'),
        content: Text(
          l10n?.healthPermissionExplanation ??
              'HopeOS can track your steps and activity using Health Connect for a more complete picture of your day.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n?.skipForNow ?? 'Skip for now'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n?.connectHealth ?? 'Connect Health'),
          ),
        ],
      ),
    );

    if (result == true) {
      final granted = await healthService.requestPermissions();
      if (!granted && context.mounted) {
        _showDeniedExplanation(
          context,
          l10n?.healthDeniedExplanation ??
              'You can connect Health Connect later in Settings to track your activity automatically.',
        );
      }
    }
  }

  static void _showDeniedExplanation(BuildContext context, String message) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.info_outline, size: 40,
            color: Theme.of(ctx).colorScheme.primary),
        title: Text(l10n?.permissionDenied ?? 'Permission Denied'),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n?.gotIt ?? 'Got it'),
          ),
        ],
      ),
    );
  }
}
