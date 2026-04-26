import 'package:flutter/material.dart';
import 'package:hopeos/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'core/permissions/permission_handler.dart';
import 'core/utils/navigation_provider.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/capture/capture_screen.dart';
import 'features/timeline/timeline_screen.dart';
import 'features/insights/insights_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/help/help_button.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const _screens = [
    DashboardScreen(),
    CaptureScreen(),
    TimelineScreen(),
    InsightsScreen(),
    ProfileScreen(),
  ];

  bool _permissionsChecked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_permissionsChecked) {
      _permissionsChecked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          PermissionHandler.requestPermissionsIfNeeded(context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: nav.currentIndex,
            children: _screens,
          ),
          const HelpFloatingButton(),
        ],
      ),
      bottomNavigationBar: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context);
          return NavigationBar(
            selectedIndex: nav.currentIndex,
            onDestinationSelected: nav.navigateTo,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home),
                label: l10n?.home ?? 'Home',
              ),
              NavigationDestination(
                icon: const Icon(Icons.add_circle_outline),
                selectedIcon: const Icon(Icons.add_circle),
                label: l10n?.capture ?? 'Capture',
              ),
              NavigationDestination(
                icon: const Icon(Icons.timeline_outlined),
                selectedIcon: const Icon(Icons.timeline),
                label: l10n?.timeline ?? 'Timeline',
              ),
              NavigationDestination(
                icon: const Icon(Icons.insights_outlined),
                selectedIcon: const Icon(Icons.insights),
                label: l10n?.insights ?? 'Insights',
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline),
                selectedIcon: const Icon(Icons.person),
                label: l10n?.profile ?? 'Profile',
              ),
            ],
          );
        },
      ),
    );
  }
}
