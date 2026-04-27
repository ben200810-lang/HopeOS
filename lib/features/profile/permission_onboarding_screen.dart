import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hopeos/l10n/app_localizations.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/notifications/quick_action_notification_manager.dart';
import '../settings/settings_provider.dart';

enum _PermissionState { pending, granted, denied, skipped }

class PermissionOnboardingScreen extends StatefulWidget {
  const PermissionOnboardingScreen({super.key});

  @override
  State<PermissionOnboardingScreen> createState() =>
      _PermissionOnboardingScreenState();
}

class _PermissionOnboardingScreenState
    extends State<PermissionOnboardingScreen> {
  _PermissionState _activityState = _PermissionState.pending;
  _PermissionState _notificationState = _PermissionState.pending;

  bool get _allHandled =>
      _activityState != _PermissionState.pending &&
      _notificationState != _PermissionState.pending;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 48),

              // Header
              Icon(
                Icons.security,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 20),
              Text(
                l10n?.permissionSetup ?? 'Permission Setup',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                l10n?.permissionSetupSubtitle ??
                    'HopeOS needs a few permissions to work at its best. You can skip any of these and enable them later in Settings.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Permission cards
              Expanded(
                child: ListView(
                  children: [
                    // Activity Recognition
                    _PermissionCard(
                      icon: Icons.directions_walk,
                      title: l10n?.activityRecognition ??
                          'Activity Recognition',
                      description: l10n?.activityRecognitionExplanation ??
                          'HopeOS uses activity data to detect patterns in your energy and habits.',
                      state: _activityState,
                      onRequest: _requestActivityPermission,
                      onSkip: () => setState(() {
                        _activityState = _PermissionState.skipped;
                      }),
                    ),

                    const SizedBox(height: 16),

                    // Notifications
                    _PermissionCard(
                      icon: Icons.notifications_outlined,
                      title: l10n?.notificationPermission ??
                          'Notification Permission',
                      description:
                          l10n?.notificationPermissionExplanation ??
                              'HopeOS needs notification permission to send you gentle reminders.',
                      state: _notificationState,
                      onRequest: _requestNotificationPermission,
                      onSkip: () => setState(() {
                        _notificationState = _PermissionState.skipped;
                      }),
                    ),
                  ],
                ),
              ),

              // Continue button
              Padding(
                padding: const EdgeInsets.only(bottom: 32, top: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _allHandled ? _completePermissionSetup : null,
                    child: Text(
                      l10n?.continueButton ?? 'Continue',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _requestActivityPermission() async {
    try {
      const platform = MethodChannel('com.hopeos.app/permissions');
      final granted =
          await platform.invokeMethod<bool>('requestActivityRecognition');
      if (mounted) {
        if (granted == true) {
          setState(() => _activityState = _PermissionState.granted);
          context.read<SettingsProvider>().setActivityPermissionGranted(true);
        } else {
          setState(() => _activityState = _PermissionState.denied);
          _showDeniedExplanation();
        }
      }
    } on PlatformException {
      // Platform channel not available (non-Android)
      if (mounted) {
        setState(() => _activityState = _PermissionState.granted);
        context.read<SettingsProvider>().setActivityPermissionGranted(true);
      }
    } on MissingPluginException {
      if (mounted) {
        setState(() => _activityState = _PermissionState.granted);
        context.read<SettingsProvider>().setActivityPermissionGranted(true);
      }
    }
  }

  Future<void> _requestNotificationPermission() async {
    final notifService = NotificationService();
    final l10n = AppLocalizations.of(context);
    final granted = await notifService.requestPermissions();
    if (mounted) {
      if (granted) {
        setState(() => _notificationState = _PermissionState.granted);
        context.read<SettingsProvider>().setNotificationPermissionGranted(true);

        // Auto-enable persistent quick capture notification
        final settings = context.read<SettingsProvider>();
        await settings.setQuickCaptureEnabled(true);
        await QuickActionNotificationManager().show(
          title: l10n?.quickCaptureNotificationTitle,
          body: l10n?.quickCaptureNotificationBody,
        );
      } else {
        setState(() => _notificationState = _PermissionState.denied);
        _showDeniedExplanation();
      }
    }
  }

  void _showDeniedExplanation() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.info_outline,
            size: 40, color: Theme.of(ctx).colorScheme.primary),
        title: Text(l10n?.permissionDeniedTitle ?? 'Permission Not Granted'),
        content: Text(l10n?.permissionDeniedBody ??
            'This permission was denied. You can enable it later from your device\'s app settings.'),
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

  Future<void> _openAppSettings() async {
    try {
      const platform = MethodChannel('com.hopeos.app/permissions');
      await platform.invokeMethod('openAppSettings');
    } catch (_) {
      // Platform channel not available
    }
  }

  Future<void> _completePermissionSetup() async {
    final settings = context.read<SettingsProvider>();
    await settings.setHasCompletedPermissionOnboarding(true);
  }
}

class _PermissionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final _PermissionState state;
  final VoidCallback onRequest;
  final VoidCallback onSkip;

  const _PermissionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.state,
    required this.onRequest,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final isHandled = state != _PermissionState.pending;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isHandled
            ? (state == _PermissionState.granted
                ? Colors.green.withValues(alpha: 0.08)
                : theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.4))
            : theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: state == _PermissionState.granted
              ? Colors.green.withValues(alpha: 0.3)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: state == _PermissionState.granted
                      ? Colors.green.withValues(alpha: 0.12)
                      : theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: state == _PermissionState.granted
                      ? Colors.green
                      : theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isHandled) ...[
                      const SizedBox(height: 2),
                      Text(
                        state == _PermissionState.granted
                            ? (l10n?.permissionGranted ?? 'Granted')
                            : (l10n?.permissionSkipped ?? 'Skipped'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: state == _PermissionState.granted
                              ? Colors.green
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isHandled)
                Icon(
                  state == _PermissionState.granted
                      ? Icons.check_circle
                      : Icons.remove_circle_outline,
                  color: state == _PermissionState.granted
                      ? Colors.green
                      : theme.colorScheme.onSurfaceVariant,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (!isHandled) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onSkip,
                    child: Text(l10n?.skipForNow ?? 'Skip for now'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: onRequest,
                    child: Text(l10n?.tapToEnable ?? 'Tap to enable'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
