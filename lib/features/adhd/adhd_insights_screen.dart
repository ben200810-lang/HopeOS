import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../features/capture/capture_provider.dart';
import '../../features/health/health_provider.dart';
import '../../features/mental/mental_provider.dart';
import '../../features/timeline/timeline_provider.dart';
import '../../features/settings/settings_provider.dart';
import 'adhd_insight_engine.dart';

class AdhdInsightsScreen extends StatefulWidget {
  const AdhdInsightsScreen({super.key});

  @override
  State<AdhdInsightsScreen> createState() => _AdhdInsightsScreenState();
}

class _AdhdInsightsScreenState extends State<AdhdInsightsScreen> {
  List<DetectedPattern> _patterns = [];
  bool _isAnalyzing = true;
  Map<String, dynamic>? _symptoms;
  Map<String, dynamic>? _strategies;

  @override
  void initState() {
    super.initState();
    _loadDataAndAnalyze();
  }

  Future<void> _loadDataAndAnalyze() async {
    // Load ADHD knowledge data
    final results = await Future.wait([
      rootBundle.loadString('assets/knowledge/adhd_symptoms.json'),
      rootBundle.loadString('assets/knowledge/adhd_strategies.json'),
    ]);

    final symptoms = jsonDecode(results[0]) as Map<String, dynamic>;
    final strategies = jsonDecode(results[1]) as Map<String, dynamic>;

    if (!mounted) return;

    final health = context.read<HealthProvider>();
    final mental = context.read<MentalProvider>();
    final capture = context.read<CaptureProvider>();
    final timeline = context.read<TimelineProvider>();

    final engine = AdhdInsightEngine();
    final patterns = engine.analyze(
      healthEntries: health.weekEntries,
      moodEntries: mental.recentEntries,
      captureEntries: capture.entries,
      timelineEvents: timeline.events,
    );

    setState(() {
      _symptoms = symptoms;
      _strategies = strategies;
      _patterns = patterns;
      _isAnalyzing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<SettingsProvider>();
    final locale = settings.language;

    return Scaffold(
      appBar: AppBar(
        title: Text(locale == 'hu' ? 'ADHD Meglátások' : 'ADHD Insights'),
      ),
      body: _isAnalyzing
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildDisclaimerCard(theme, locale),
                const SizedBox(height: 16),
                _buildPatternsSection(theme, locale),
                const SizedBox(height: 24),
                _buildSymptomsSection(theme, locale),
                const SizedBox(height: 24),
                _buildStrategiesSection(theme, locale),
                const SizedBox(height: 24),
                _buildSourcesSection(theme, locale),
              ],
            ),
    );
  }

  Widget _buildDisclaimerCard(ThemeData theme, String locale) {
    return Card(
      color: theme.colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline,
                color: theme.colorScheme.onTertiaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                locale == 'hu'
                    ? 'Ez a rendszer NEM diagnosztizálja az ADHD-t. Csak olyan mintákat jelenít meg, amelyeket a kutatások gyakran társítanak az ADHD-val. Megfelelő értékeléshez forduljon szakemberhez.'
                    : 'This system does NOT diagnose ADHD. It only displays patterns that research often associates with ADHD. Consult a professional for proper evaluation.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onTertiaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternsSection(ThemeData theme, String locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          locale == 'hu' ? 'Észlelt minták' : 'Detected Patterns',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          locale == 'hu'
              ? 'Az Ön adatainak elemzése alapján'
              : 'Based on analysis of your data',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        if (_patterns.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 48, color: theme.colorScheme.primary),
                    const SizedBox(height: 12),
                    Text(
                      locale == 'hu'
                          ? 'Nem találtunk figyelemre méltó mintákat. Folytassa az adatok rögzítését a pontosabb elemzésért.'
                          : 'No notable patterns detected. Keep logging data for more accurate analysis.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          )
        else ...[
          Card(
            color: theme.colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.psychology,
                      color: theme.colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      locale == 'hu'
                          ? 'Egyes minták gyakran társulnak az ADHD-val.'
                          : 'Some patterns are often associated with ADHD.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          ..._patterns.map((p) => _buildPatternCard(p, theme, locale)),
        ],
      ],
    );
  }

  Widget _buildPatternCard(
      DetectedPattern pattern, ThemeData theme, String locale) {
    final confidencePercent = (pattern.confidence * 100).toInt();
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(pattern.emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    pattern.localizedName(locale),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _confidenceColor(pattern.confidence)
                        .withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$confidencePercent%',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _confidenceColor(pattern.confidence),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              pattern.localizedDescription(locale),
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Color _confidenceColor(double confidence) {
    if (confidence >= 0.7) return Colors.orange;
    if (confidence >= 0.5) return Colors.amber.shade700;
    return Colors.grey;
  }

  Widget _buildSymptomsSection(ThemeData theme, String locale) {
    if (_symptoms == null) return const SizedBox.shrink();

    final categories = _symptoms!['categories'] as List? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          locale == 'hu' ? 'ADHD tünetek áttekintése' : 'ADHD Symptoms Overview',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          locale == 'hu'
              ? 'DSM-5 és ICD-11 alapján'
              : 'Based on DSM-5 and ICD-11',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        ...categories.map((cat) {
          final c = cat as Map<String, dynamic>;
          final nameMap = c['name'] as Map<String, dynamic>;
          final descMap = c['description'] as Map<String, dynamic>;
          final items = c['items'] as List? ?? [];
          final emoji = c['emoji'] as String? ?? '';

          return ExpansionTile(
            leading: Text(emoji, style: const TextStyle(fontSize: 24)),
            title: Text(
              (nameMap[locale] ?? nameMap['en'] ?? '') as String,
              style: theme.textTheme.titleSmall,
            ),
            subtitle: Text(
              (descMap[locale] ?? descMap['en'] ?? '') as String,
              style: theme.textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            children: items.map((item) {
              final i = item as Map<String, dynamic>;
              final iName = i['name'] as Map<String, dynamic>;
              final iDesc = i['description'] as Map<String, dynamic>;
              return ListTile(
                dense: true,
                title: Text(
                  (iName[locale] ?? iName['en'] ?? '') as String,
                  style: theme.textTheme.bodyMedium,
                ),
                subtitle: Text(
                  (iDesc[locale] ?? iDesc['en'] ?? '') as String,
                  style: theme.textTheme.bodySmall,
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildStrategiesSection(ThemeData theme, String locale) {
    if (_strategies == null) return const SizedBox.shrink();

    final categories = _strategies!['categories'] as List? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          locale == 'hu' ? 'Stratégiák és tippek' : 'Strategies & Tips',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        ...categories.map((cat) {
          final c = cat as Map<String, dynamic>;
          final nameMap = c['name'] as Map<String, dynamic>;
          final emoji = c['emoji'] as String? ?? '';
          final strategies = c['strategies'] as List? ?? [];

          return ExpansionTile(
            leading: Text(emoji, style: const TextStyle(fontSize: 24)),
            title: Text(
              (nameMap[locale] ?? nameMap['en'] ?? '') as String,
              style: theme.textTheme.titleSmall,
            ),
            children: strategies.map((s) {
              final strategy = s as Map<String, dynamic>;
              final sName = strategy['name'] as Map<String, dynamic>;
              final sDesc = strategy['description'] as Map<String, dynamic>;
              final difficulty = strategy['difficulty'] as String? ?? 'medium';

              return ListTile(
                dense: true,
                title: Text(
                  (sName[locale] ?? sName['en'] ?? '') as String,
                  style: theme.textTheme.bodyMedium,
                ),
                subtitle: Text(
                  (sDesc[locale] ?? sDesc['en'] ?? '') as String,
                  style: theme.textTheme.bodySmall,
                ),
                trailing: _difficultyChip(difficulty, theme, locale),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _difficultyChip(String difficulty, ThemeData theme, String locale) {
    final Color color;
    final String label;
    switch (difficulty) {
      case 'easy':
        color = Colors.green;
        label = locale == 'hu' ? 'Könnyű' : 'Easy';
      case 'hard':
        color = Colors.orange;
        label = locale == 'hu' ? 'Nehéz' : 'Hard';
      default:
        color = Colors.blue;
        label = locale == 'hu' ? 'Közepes' : 'Medium';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSourcesSection(ThemeData theme, String locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          locale == 'hu' ? 'Források' : 'Sources',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sourceRow(theme,
                    'American Psychiatric Association (2013). DSM-5.'),
                const SizedBox(height: 8),
                _sourceRow(theme,
                    'World Health Organization (2019). ICD-11.'),
                const SizedBox(height: 8),
                _sourceRow(theme,
                    'National Institute of Mental Health (NIMH). ADHD.'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _sourceRow(ThemeData theme, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.menu_book, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: theme.textTheme.bodySmall),
        ),
      ],
    );
  }
}
