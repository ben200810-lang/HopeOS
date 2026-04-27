import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy;
import 'package:hopeos/l10n/app_localizations.dart';
import 'core/knowledge/knowledge_service.dart';
import 'core/notifications/notification_service.dart';
import 'core/notifications/quick_action_notification_manager.dart';
import 'core/notifications/notification_action_router.dart';
import 'core/providers/providers.dart';
import 'core/theme/app_theme.dart';
import 'features/actions/action_provider.dart';
import 'features/activity/presentation/activity_provider.dart';
import 'features/mental/mental_provider.dart';
import 'features/health/health_provider.dart';
import 'features/journal/journal_provider.dart';
import 'data/models/capture_entry.dart';
import 'features/capture/capture_provider.dart';
import 'features/settings/settings_provider.dart';
import 'core/utils/navigation_provider.dart';
import 'features/timeline/timeline_provider.dart';
import 'features/patterns/pattern_insight_provider.dart';
import 'app_shell.dart';
import 'features/profile/onboarding_screen.dart';
import 'features/profile/permission_onboarding_screen.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
    };

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    // Create all provider instances once — shared between legacy Provider and Riverpod
    final settings = SettingsProvider();
    await settings.loadSettings();

    final actions = ActionProvider()..loadActions();
    final mental = MentalProvider()..loadEntries();
    final health = HealthProvider()..loadData();
    final journal = JournalProvider()..loadEntries();
    final capture = CaptureProvider()..loadEntries();
    final navigation = NavigationProvider();
    final timeline = TimelineProvider();
    final activity = ActivityProvider()..initialize();
    final patternInsights = PatternInsightProvider();

    // Load bundled knowledge database
    try {
      final knowledge = KnowledgeService();
      await knowledge.initialize();
    } catch (e) {
      debugPrint('Knowledge init failed: $e');
    }

    // Initialize notification system (non-blocking for app startup)
    _initNotifications(settings);

    // Sync Health Connect data on launch
    _syncHealthData(activity, capture);

    runApp(
      ProviderScope(
        overrides: [
          settingsRiverpod.overrideWith((_) => settings),
          actionRiverpod.overrideWith((_) => actions),
          mentalRiverpod.overrideWith((_) => mental),
          healthRiverpod.overrideWith((_) => health),
          journalRiverpod.overrideWith((_) => journal),
          captureRiverpod.overrideWith((_) => capture),
          navigationRiverpod.overrideWith((_) => navigation),
          timelineRiverpod.overrideWith((_) => timeline),
        ],
        child: HopeOSApp(
          settings: settings,
          actions: actions,
          mental: mental,
          health: health,
          journal: journal,
          capture: capture,
          navigation: navigation,
          timeline: timeline,
          activity: activity,
          patternInsights: patternInsights,
        ),
      ),
    );
  }, (error, stack) {
    debugPrint('Uncaught error: $error\n$stack');
  });
}

Future<void> _initNotifications(SettingsProvider settings) async {
  try {
    final notifications = NotificationService();
    await notifications.initialize();

    // Wire notification actions → capture modals via router
    final router = NotificationActionRouter(navigatorKey);
    router.attach();

    if (settings.notificationsEnabled) {
      await notifications.scheduleDrinkReminder(enabled: true);
      await notifications.scheduleSleepReminder(enabled: true);
      await notifications.scheduleDailyReflection(enabled: true);
    }

    // Restore persistent quick capture notification if enabled
    final manager = QuickActionNotificationManager();
    await manager.restoreIfEnabled(
      quickCaptureEnabled: settings.quickCaptureEnabled,
    );
  } catch (e) {
    debugPrint('Notification init failed: $e');
  }
}

Future<void> _syncHealthData(
  ActivityProvider activity,
  CaptureProvider capture,
) async {
  try {
    // Wire step milestone callback
    ActivityProvider.onStepMilestone = (steps, milestone) {
      final formattedMilestone = milestone >= 1000
          ? '${(milestone / 1000).toStringAsFixed(0)},000'
          : '$milestone';
      capture.quickCapture(
        type: CaptureType.note,
        text: 'Reached $formattedMilestone steps today! ($steps steps total)',
      );
    };

    await activity.initialize();
    if (activity.hasHealthPermission) {
      await activity.syncFromHealthConnect();
    }
  } catch (e) {
    debugPrint('Health data sync failed: $e');
  }
}

class HopeOSApp extends StatelessWidget {
  final SettingsProvider settings;
  final ActionProvider actions;
  final MentalProvider mental;
  final HealthProvider health;
  final JournalProvider journal;
  final CaptureProvider capture;
  final NavigationProvider navigation;
  final TimelineProvider timeline;
  final ActivityProvider activity;
  final PatternInsightProvider patternInsights;

  const HopeOSApp({
    super.key,
    required this.settings,
    required this.actions,
    required this.mental,
    required this.health,
    required this.journal,
    required this.capture,
    required this.navigation,
    required this.timeline,
    required this.activity,
    required this.patternInsights,
  });

  @override
  Widget build(BuildContext context) {
    return legacy.MultiProvider(
      providers: [
        legacy.ChangeNotifierProvider.value(value: settings),
        legacy.ChangeNotifierProvider.value(value: actions),
        legacy.ChangeNotifierProvider.value(value: mental),
        legacy.ChangeNotifierProvider.value(value: health),
        legacy.ChangeNotifierProvider.value(value: journal),
        legacy.ChangeNotifierProvider.value(value: capture),
        legacy.ChangeNotifierProvider.value(value: navigation),
        legacy.ChangeNotifierProvider.value(value: timeline),
        legacy.ChangeNotifierProvider.value(value: activity),
        legacy.ChangeNotifierProvider.value(value: patternInsights),
      ],
      child: legacy.Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          final seed = settings.seedColor;
          return MaterialApp(
            title: 'HopeOS',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.buildTheme(Brightness.light, seed),
            darkTheme: AppTheme.buildTheme(Brightness.dark, seed),
            themeMode: settings.themeMode,
            locale: Locale(settings.language),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            navigatorKey: navigatorKey,
            home: !settings.hasCompletedOnboarding
                ? const OnboardingScreen()
                : !settings.hasCompletedPermissionOnboarding
                    ? const PermissionOnboardingScreen()
                    : const AppShell(),
          );
        },
      ),
    );
  }
}
