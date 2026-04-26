import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../settings/settings_provider.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = context.watch<SettingsProvider>().language;
    final isHu = locale == 'hu';

    return Scaffold(
      appBar: AppBar(
        title: Text(isHu ? 'Az alkalmazásról' : 'About'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 16),
          // App icon and name
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.favorite,
                    size: 40,
                    color: theme.colorScheme.primary,
                  ),
                ),
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
                  isHu
                      ? 'Személyes élet operációs rendszer'
                      : 'A personal life operating system',
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
                        isHu ? 'Alapító' : 'Founder',
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
                        isHu ? 'Küldetés' : 'Mission',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isHu
                        ? 'A HopeOS azért született, hogy segítsen az embereknek megérteni saját életüket. Nem egy újabb produktivitási alkalmazás – hanem egy személyes élet operációs rendszer, amely segít meglátni a mintákat, megérteni a szokásokat, és tudatos döntéseket hozni.'
                        : 'HopeOS was born to help people understand their own lives. It is not another productivity app — it is a personal life operating system that helps you see patterns, understand habits, and make conscious decisions.',
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
                        isHu ? 'Motiváció' : 'Motivation',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isHu
                        ? 'Az ADHD-val élő embereknek különösen nehéz lehet nyomon követni a mindennapi életüket. A HopeOS-t azért építettem, mert személyesen is megtapasztaltam ezeket a kihívásokat. Az alkalmazás célja, hogy egy biztonságos, privát teret nyújtson, ahol az ember megismerheti saját mintáit – ítélet nélkül.'
                        : 'People living with ADHD can find it especially challenging to track their daily lives. I built HopeOS because I have personally experienced these challenges. The app aims to provide a safe, private space where you can understand your own patterns — without judgment.',
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
                        isHu ? 'Alapértékek' : 'Core Values',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _ValueRow(
                    emoji: '🔒',
                    text: isHu
                        ? 'Adatvédelem – Az adataid soha nem hagyják el a telefonodat'
                        : 'Privacy — Your data never leaves your phone',
                    theme: theme,
                  ),
                  const SizedBox(height: 8),
                  _ValueRow(
                    emoji: '🧠',
                    text: isHu
                        ? 'Megértés – Nem ítélkezünk, segítünk megérteni'
                        : 'Understanding — No judgment, just insight',
                    theme: theme,
                  ),
                  const SizedBox(height: 8),
                  _ValueRow(
                    emoji: '💚',
                    text: isHu
                        ? 'Empátia – ADHD-barát dizájn és gondolkodásmód'
                        : 'Empathy — ADHD-friendly design and mindset',
                    theme: theme,
                  ),
                  const SizedBox(height: 8),
                  _ValueRow(
                    emoji: '🌱',
                    text: isHu
                        ? 'Növekedés – Apró lépések, nagy változás'
                        : 'Growth — Small steps, big change',
                    theme: theme,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              isHu ? 'Készítve szeretettel 💚' : 'Made with love 💚',
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
