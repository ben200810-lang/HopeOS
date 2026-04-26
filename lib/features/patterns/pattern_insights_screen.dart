import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../settings/settings_provider.dart';
import '../timeline/timeline_provider.dart';
import 'pattern_engine.dart';
import 'pattern_insights_card.dart';

class PatternInsightsScreen extends StatelessWidget {
  const PatternInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<SettingsProvider>();
    final timeline = context.watch<TimelineProvider>();
    final isHu = settings.language == 'hu';

    final engine = PatternEngine();
    final patterns = engine.analyze(timeline.allEvents);

    return Scaffold(
      appBar: AppBar(
        title: Text(isHu ? 'Minta betekintések' : 'Pattern Insights'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            isHu
                ? 'Az idővonal adataid alapján felismert minták'
                : 'Patterns detected from your timeline data',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiaryContainer.withAlpha(80),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    size: 18, color: theme.colorScheme.tertiary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isHu
                        ? 'Ez nem orvosi diagnózis. Csak mintákat mutat az adataidból.'
                        : 'This is not a medical diagnosis. It only shows patterns from your data.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onTertiaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PatternInsightsCard(
            patterns: patterns,
            locale: settings.language,
          ),
        ],
      ),
    );
  }
}
