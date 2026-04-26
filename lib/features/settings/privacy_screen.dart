import 'package:flutter/material.dart';
import 'package:hopeos/l10n/app_localizations.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.privacy ?? 'Privacy'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionCard(
            icon: Icons.phone_android,
            title: l10n?.localFirstData ?? 'Local-First Data',
            body: l10n?.localFirstDataBody ??
                'HopeOS stores all data exclusively on your device. Journal entries, mood data, health tracking, and captures never leave your phone.',
            theme: theme,
          ),
          const SizedBox(height: 12),
          _SectionCard(
            icon: Icons.cloud_off,
            title: l10n?.noCloudSync ?? 'No Cloud Sync',
            body: l10n?.noCloudSyncBody ??
                'There is currently no cloud sync or remote server. Your data is owned by you and stays on your device.',
            theme: theme,
          ),
          const SizedBox(height: 12),
          _SectionCard(
            icon: Icons.analytics_outlined,
            title: l10n?.noTracking ?? 'No Tracking',
            body: l10n?.noTrackingBody ??
                'HopeOS does not collect analytics, send usage statistics, or include third-party trackers.',
            theme: theme,
          ),
          const SizedBox(height: 12),
          _SectionCard(
            icon: Icons.health_and_safety,
            title: l10n?.healthData ?? 'Health Data',
            body: l10n?.healthDataBody ??
                'If you enable Health Connect integration, health data (steps, distance, active minutes) is read directly from your device. This data is never shared.',
            theme: theme,
          ),
          const SizedBox(height: 12),
          _SectionCard(
            icon: Icons.psychology_outlined,
            title: l10n?.adhdInsightsPrivacy ?? 'ADHD Insights',
            body: l10n?.adhdInsightsPrivacyBody ??
                'ADHD pattern analysis runs entirely on your device. The system does not diagnose and does not send data to anyone. Patterns are based solely on your local data.',
            theme: theme,
          ),
          const SizedBox(height: 12),
          _SectionCard(
            icon: Icons.delete_outline,
            title: l10n?.dataDeletion ?? 'Data Deletion',
            body: l10n?.dataDeletionBody ??
                'You can delete your data at any time by clearing app data or uninstalling the app. Since there is no cloud backup, deletion is permanent.',
            theme: theme,
          ),
          const SizedBox(height: 24),
          Text(
            l10n?.lastUpdatedApril2026 ?? 'Last updated: April 2026',
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
