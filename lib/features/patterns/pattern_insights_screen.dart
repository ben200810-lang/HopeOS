import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../settings/settings_provider.dart';
import '../timeline/timeline_provider.dart';
import 'pattern_engine.dart';
import 'pattern_insights_card.dart';
import 'pattern_insight_provider.dart';
import 'pattern_insight_card.dart';

class PatternInsightsScreen extends StatefulWidget {
  const PatternInsightsScreen({super.key});

  @override
  State<PatternInsightsScreen> createState() => _PatternInsightsScreenState();
}

class _PatternInsightsScreenState extends State<PatternInsightsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PatternInsightProvider>().ensureLoaded();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<SettingsProvider>();
    final isHu = settings.language == 'hu';

    return Scaffold(
      appBar: AppBar(
        title: Text(isHu ? 'Minta betekintések' : 'Pattern Insights'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: isHu ? 'Frissítés' : 'Refresh',
            onPressed: () {
              context.read<PatternInsightProvider>().refreshInsights();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            isHu
                ? 'Kereszt-domain minták az adataidból'
                : 'Cross-domain patterns from your life data',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          // v2 Pattern Insights
          Builder(
            builder: (context) {
              final provider = context.watch<PatternInsightProvider>();
              return PatternInsightCards(
                insights: provider.insights,
                locale: settings.language,
                isLoading: provider.isLoading,
              );
            },
          ),

          const SizedBox(height: 24),

          // Legacy v1 insights (from timeline events)
          Builder(
            builder: (context) {
              final timeline = context.watch<TimelineProvider>();
              final engine = PatternEngine();
              final patterns = engine.analyze(timeline.allEvents);
              if (patterns.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isHu ? 'Idővonal minták' : 'Timeline Patterns',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  PatternInsightsCard(
                    patterns: patterns,
                    locale: settings.language,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
