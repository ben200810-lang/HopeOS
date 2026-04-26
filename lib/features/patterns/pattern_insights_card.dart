import 'package:flutter/material.dart';
import 'pattern_engine.dart';

class PatternInsightsCard extends StatelessWidget {
  final List<DetectedPattern> patterns;
  final String locale;

  const PatternInsightsCard({
    super.key,
    required this.patterns,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHu = locale == 'hu';

    if (patterns.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withAlpha(100),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.auto_awesome, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isHu
                    ? 'Folytasd az adatgyűjtést a mintáid felfedezéséhez.'
                    : 'Keep logging data to discover your patterns.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isHu ? 'Minta betekintések' : 'Pattern Insights',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...patterns.map((p) => _PatternCard(pattern: p, locale: locale)),
      ],
    );
  }
}

class _PatternCard extends StatelessWidget {
  final DetectedPattern pattern;
  final String locale;

  const _PatternCard({required this.pattern, required this.locale});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _categoryColor(pattern.category);
    final icon = _categoryIcon(pattern.icon);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        pattern.title(locale),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _ConfidenceBadge(confidence: pattern.confidence),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  pattern.description(locale),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _categoryColor(PatternCategory category) {
    switch (category) {
      case PatternCategory.sleep:
        return Colors.indigo;
      case PatternCategory.hydration:
        return Colors.blue;
      case PatternCategory.spending:
        return Colors.red;
      case PatternCategory.activity:
        return Colors.deepPurple;
      case PatternCategory.mood:
        return Colors.amber.shade700;
    }
  }

  IconData _categoryIcon(IconType icon) {
    switch (icon) {
      case IconType.sleep:
        return Icons.bedtime;
      case IconType.water:
        return Icons.water_drop;
      case IconType.money:
        return Icons.attach_money;
      case IconType.activity:
        return Icons.nightlight;
      case IconType.mood:
        return Icons.trending_down;
      case IconType.info:
        return Icons.info;
    }
  }
}

class _ConfidenceBadge extends StatelessWidget {
  final double confidence;

  const _ConfidenceBadge({required this.confidence});

  @override
  Widget build(BuildContext context) {
    final percent = (confidence * 100).round();
    final color = confidence >= 0.6
        ? Colors.green
        : confidence >= 0.3
            ? Colors.orange
            : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$percent%',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
