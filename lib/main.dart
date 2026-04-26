import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy;
import 'package:hopeos/l10n/app_localizations.dart';
import 'core/knowledge/knowledge_service.dart';
import 'core/notifications/notification_service.dart';
import 'core/providers/providers.dart';
import 'core/theme/app_theme.dart';
import 'features/actions/action_provider.dart';
import 'features/activity/presentation/activity_provider.dart';
import 'features/mental/mental_provider.dart';
import 'features/health/health_provider.dart';
import 'features/journal/journal_provider.dart';
import 'features/capture/capture_provider.dart';
import 'features/settings/settings_provider.dart';
import 'core/utils/navigation_provider.dart';
import 'features/timeline/timeline_provider.dart';
import 'features/patterns/pattern_insight_provider.dart';
import 'app_shell.dart';
import 'features/profile/onboarding_screen.dart';

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
    if (settings.notificationsEnabled) {
      await notifications.scheduleDrinkReminder(enabled: true);
      await notifications.scheduleSleepReminder(enabled: true);
      await notifications.scheduleDailyReflection(enabled: true);
    }
  } catch (e) {
    debugPrint('Notification init failed: $e');
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
            home: settings.onboarded
                ? const AppShell()
                : const OnboardingScreen(),
          );
        },
      ),
    );
  }
}
