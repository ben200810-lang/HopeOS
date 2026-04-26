import 'package:flutter/material.dart';
import 'package:hopeos/l10n/app_localizations.dart';
import '../../core/widgets/hope_logo.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.about ?? 'About'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 16),
          // App icon and name
          Center(
            child: Column(
              children: [
                const HopeLogo(size: 80, showText: false),
                const SizedBox(height: 12),
                Text(
                  'HopeOS',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'v1.0.0',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n?.personalLifeOS ?? 'A personal life operating system',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Founder section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Text(
                        l10n?.founderLabel ?? 'Founder',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Balogh Bence',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Mission
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.flag, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Text(
                        l10n?.missionLabel ?? 'Mission',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n?.missionText ?? 'HopeOS was born to help people understand their own lives. It is not another productivity app \u2014 it is a personal life operating system that helps you see patterns, understand habits, and make conscious decisions.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Motivation
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline,
                          color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Text(
                        l10n?.motivationLabel ?? 'Motivation',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n?.motivationText ?? 'People living with ADHD can find it especially challenging to track their daily lives. I built HopeOS because I have personally experienced these challenges. The app aims to provide a safe, private space where you can understand your own patterns \u2014 without judgment.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Core values
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star_outline,
                          color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Text(
                        l10n?.coreValuesLabel ?? 'Core Values',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _ValueRow(
                    emoji: '🔒',
                    text: l10n?.valuePrivacy ?? 'Privacy \u2014 Your data never leaves your phone',
                    theme: theme,
                  ),
                  const SizedBox(height: 8),
                  _ValueRow(
                    emoji: '🧠',
                    text: l10n?.valueUnderstanding ?? 'Understanding \u2014 No judgment, just insight',
                    theme: theme,
                  ),
                  const SizedBox(height: 8),
                  _ValueRow(
                    emoji: '💚',
                    text: l10n?.valueEmpathy ?? 'Empathy \u2014 ADHD-friendly design and mindset',
                    theme: theme,
                  ),
                  const SizedBox(height: 8),
                  _ValueRow(
                    emoji: '🌱',
                    text: l10n?.valueGrowth ?? 'Growth \u2014 Small steps, big change',
                    theme: theme,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              l10n?.madeWithLove ?? 'Made with love \u{1F49A}',
              style: theme.textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ValueRow extends StatelessWidget {
  final String emoji;
  final String text;
  final ThemeData theme;

  const _ValueRow({
    required this.emoji,
    required this.text,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: theme.textTheme.bodyMedium),
        ),
      ],
    );
  }
}
