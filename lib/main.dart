import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy;
import 'core/knowledge/knowledge_service.dart';
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
import 'app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  final settingsProvider = SettingsProvider();
  await settingsProvider.loadSettings();

  // Load bundled knowledge database
  final knowledge = KnowledgeService();
  await knowledge.initialize();

  runApp(
    ProviderScope(
      child: HopeOSApp(settingsProvider: settingsProvider),
    ),
  );
}

class HopeOSApp extends StatelessWidget {
  final SettingsProvider settingsProvider;

  const HopeOSApp({super.key, required this.settingsProvider});

  @override
  Widget build(BuildContext context) {
    return legacy.MultiProvider(
      providers: [
        legacy.ChangeNotifierProvider.value(value: settingsProvider),
        legacy.ChangeNotifierProvider(
            create: (_) => ActionProvider()..loadActions()),
        legacy.ChangeNotifierProvider(
            create: (_) => MentalProvider()..loadEntries()),
        legacy.ChangeNotifierProvider(
            create: (_) => HealthProvider()..loadData()),
        legacy.ChangeNotifierProvider(
            create: (_) => JournalProvider()..loadEntries()),
        legacy.ChangeNotifierProvider(
            create: (_) => CaptureProvider()..loadEntries()),
        legacy.ChangeNotifierProvider(create: (_) => NavigationProvider()),
        legacy.ChangeNotifierProvider(create: (_) => TimelineProvider()),
        legacy.ChangeNotifierProvider(
            create: (_) => ActivityProvider()..initialize()),
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
            home: const AppShell(),
          );
        },
      ),
    );
  }
}
