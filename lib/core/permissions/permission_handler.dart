import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hopeos/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../notifications/notification_service.dart';
import '../../features/activity/data/health_connect_service.dart';

class PermissionHandler {
  static const _notificationAskedKey = 'notification_permission_asked';
  static const _healthAskedKey = 'health_permission_asked';
  static const _activityAskedKey = 'activity_permission_asked';
  static const _usageAskedKey = 'usage_permission_asked';

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

  static Future<bool> hasAskedActivity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_activityAskedKey) ?? false;
  }

  static Future<void> markActivityAsked() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_activityAskedKey, true);
  }

  static Future<bool> hasAskedUsage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_usageAskedKey) ?? false;
  }

  static Future<void> markUsageAsked() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_usageAskedKey, true);
  }

  static Future<void> requestPermissionsIfNeeded(BuildContext context) async {
    // 1. Activity Recognition
    final activityAsked = await hasAskedActivity();
    if (!activityAsked && context.mounted) {
      await _showActivityRecognitionDialog(context);
      await markActivityAsked();
    }

    // 2. Notifications
    final notifAsked = await hasAskedNotification();
    if (!notifAsked && context.mounted) {
      await _showNotificationDialog(context);
      await markNotificationAsked();
    }

    // 3. Usage Stats (screen time)
    final usageAsked = await hasAskedUsage();
    if (!usageAsked && context.mounted) {
      await _showUsageAccessDialog(context);
      await markUsageAsked();
    }

    // 4. Health Connect
    final healthAsked = await hasAskedHealth();
    if (!healthAsked && context.mounted) {
      await _showHealthDialog(context);
      await markHealthAsked();
    }
  }

  /// Request only permissions NOT covered by the permission onboarding screen.
  /// Activity Recognition and Notifications are handled during onboarding.
  static Future<void> requestRemainingPermissions(BuildContext context) async {
    // Usage Stats (screen time)
    final usageAsked = await hasAskedUsage();
    if (!usageAsked && context.mounted) {
      await _showUsageAccessDialog(context);
      await markUsageAsked();
    }

    // Health Connect
    final healthAsked = await hasAskedHealth();
    if (!healthAsked && context.mounted) {
      await _showHealthDialog(context);
      await markHealthAsked();
    }
  }

  static Future<void> _showActivityRecognitionDialog(
      BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.directions_walk, size: 48),
        title: Text(l10n?.activityRecognition ?? 'Activity Recognition'),
        content: Text(
          l10n?.activityRecognitionExplanation ??
              'HopeOS uses activity data to detect patterns in your energy and habits.\n\nThis helps identify when you\'re most productive and suggests better times for tasks.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n?.skipForNow ?? 'Skip for now'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                Text(l10n?.allowActivityTracking ?? 'Allow Activity Tracking'),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      try {
        const platform = MethodChannel('com.hopeos.app/permissions');
        final granted =
            await platform.invokeMethod<bool>('requestActivityRecognition');
        if (granted != true && context.mounted) {
          await _showDeniedExplanation(
            context,
            l10n?.activityDeniedExplanation ??
                'You can enable activity tracking later in Settings. HopeOS will still work without it.',
          );
        }
      } catch (_) {
        // Platform channel not available (running on non-Android)
      }
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
              'HopeOS needs notification permission to send you gentle reminders for water, sleep, and daily reflections.\n\nYou can also get quick capture buttons on your lock screen.',
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
        await _showDeniedExplanation(
          context,
          l10n?.notificationDeniedExplanation ??
              'You can enable notifications later in Settings to receive helpful reminders.',
        );
      }
    }
  }

  static Future<void> _showUsageAccessDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.screen_lock_landscape_outlined, size: 48),
        title: Text(l10n?.usageAccessPermission ?? 'Usage Access'),
        content: Text(
          l10n?.usageAccessExplanation ??
              'HopeOS can track your screen time to detect late-night usage patterns and help you build healthier digital habits.\n\nThis data stays on your device and is never shared.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n?.skipForNow ?? 'Skip for now'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                Text(l10n?.allowUsageAccess ?? 'Allow Usage Access'),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      try {
        const platform = MethodChannel('com.hopeos.app/permissions');
        await platform.invokeMethod('openUsageAccessSettings');
      } catch (_) {
        // Platform channel not available
      }
    }
  }

  static Future<void> _showHealthDialog(BuildContext context) async {
    final healthService = HealthConnectService();
    await healthService.initialize();

    if (!healthService.isAvailable || !healthService.isInitialized) return;
    if (!context.mounted) return;

    final l10n = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.favorite_outline, size: 48),
        title: Text(l10n?.healthPermission ?? 'Health Permission'),
        content: Text(
          l10n?.healthPermissionExplanation ??
              'HopeOS can read your steps, active minutes, and activity sessions from Health Connect for a complete picture of your day.',
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
        await _showDeniedExplanation(
          context,
          l10n?.healthDeniedExplanation ??
              'You can connect Health Connect later in Settings to track your activity automatically.',
        );
      }
    }
  }

  static Future<void> _showDeniedExplanation(
      BuildContext context, String message) async {
    final l10n = AppLocalizations.of(context);
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.info_outline,
            size: 40, color: Theme.of(ctx).colorScheme.primary),
        title: Text(l10n?.permissionDenied ?? 'Permission Denied'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n?.gotIt ?? 'Got it'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _openAppSettings();
            },
            child: Text(l10n?.openAppSettings ?? 'Open App Settings'),
          ),
        ],
      ),
    );
  }

  static Future<void> _openAppSettings() async {
    try {
      const platform = MethodChannel('com.hopeos.app/permissions');
      await platform.invokeMethod('openAppSettings');
    } catch (_) {
      // Platform channel not available
    }
  }
}
