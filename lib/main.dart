import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/actions/action_provider.dart';
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

  runApp(HopeOSApp(settingsProvider: settingsProvider));
}

class HopeOSApp extends StatelessWidget {
  final SettingsProvider settingsProvider;

  const HopeOSApp({super.key, required this.settingsProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider(create: (_) => ActionProvider()..loadActions()),
        ChangeNotifierProvider(create: (_) => MentalProvider()..loadEntries()),
        ChangeNotifierProvider(create: (_) => HealthProvider()..loadData()),
        ChangeNotifierProvider(create: (_) => JournalProvider()..loadEntries()),
        ChangeNotifierProvider(create: (_) => CaptureProvider()..loadEntries()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => TimelineProvider()),
      ],
      child: Consumer<SettingsProvider>(
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
