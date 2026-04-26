import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../settings/settings_provider.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = context.watch<SettingsProvider>().language;
    final isHu = locale == 'hu';

    return Scaffold(
      appBar: AppBar(
        title: Text(isHu ? 'Adatvédelem' : 'Privacy'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionCard(
            icon: Icons.phone_android,
            title: isHu ? 'Helyi adattárolás' : 'Local-First Data',
            body: isHu
                ? 'A HopeOS minden adatot kizárólag az Ön eszközén tárol. A naplóbejegyzések, hangulati adatok, egészségügyi nyomkövetés és rögzítések soha nem hagyják el a telefonját.'
                : 'HopeOS stores all data exclusively on your device. Journal entries, mood data, health tracking, and captures never leave your phone.',
            theme: theme,
          ),
          const SizedBox(height: 12),
          _SectionCard(
            icon: Icons.cloud_off,
            title: isHu ? 'Nincs felhő szinkronizálás' : 'No Cloud Sync',
            body: isHu
                ? 'Jelenleg nincs felhő szinkronizálás vagy távoli szerver. Az Ön adatai az Ön tulajdonában vannak, és az Ön eszközén maradnak.'
                : 'There is currently no cloud sync or remote server. Your data is owned by you and stays on your device.',
            theme: theme,
          ),
          const SizedBox(height: 12),
          _SectionCard(
            icon: Icons.analytics_outlined,
            title: isHu ? 'Nincs nyomkövetés' : 'No Tracking',
            body: isHu
                ? 'A HopeOS nem gyűjt analitikai adatokat, nem küld felhasználási statisztikákat, és nem tartalmaz harmadik fél nyomkövetőket.'
                : 'HopeOS does not collect analytics, send usage statistics, or include third-party trackers.',
            theme: theme,
          ),
          const SizedBox(height: 12),
          _SectionCard(
            icon: Icons.health_and_safety,
            title: isHu ? 'Egészségügyi adatok' : 'Health Data',
            body: isHu
                ? 'Ha engedélyezi a Health Connect integrációt, az egészségügyi adatokat (lépések, távolság, aktív percek) közvetlenül az Ön eszközéről olvassuk. Ezek az adatok soha nem kerülnek megosztásra.'
                : 'If you enable Health Connect integration, health data (steps, distance, active minutes) is read directly from your device. This data is never shared.',
            theme: theme,
          ),
          const SizedBox(height: 12),
          _SectionCard(
            icon: Icons.psychology_outlined,
            title: isHu ? 'ADHD meglátások' : 'ADHD Insights',
            body: isHu
                ? 'Az ADHD minta-elemzés teljes egészében az Ön eszközén fut. A rendszer nem diagnosztizál és nem küld adatokat senkinek. A minták kizárólag az Ön helyi adatain alapulnak.'
                : 'ADHD pattern analysis runs entirely on your device. The system does not diagnose and does not send data to anyone. Patterns are based solely on your local data.',
            theme: theme,
          ),
          const SizedBox(height: 12),
          _SectionCard(
            icon: Icons.delete_outline,
            title: isHu ? 'Adatok törlése' : 'Data Deletion',
            body: isHu
                ? 'Bármikor törölheti adatait az alkalmazás adatainak törlésével vagy az alkalmazás eltávolításával. Mivel nincs felhő mentés, a törlés végleges.'
                : 'You can delete your data at any time by clearing app data or uninstalling the app. Since there is no cloud backup, deletion is permanent.',
            theme: theme,
          ),
          const SizedBox(height: 24),
          Text(
            isHu
                ? 'Utolsó frissítés: 2026. április'
                : 'Last updated: April 2026',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final ThemeData theme;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(title, style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            Text(body, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
