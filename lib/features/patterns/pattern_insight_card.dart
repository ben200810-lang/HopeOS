import 'package:flutter/material.dart';
import 'package:hopeos/l10n/app_localizations.dart';
import 'pattern_insight.dart';

class PatternInsightCards extends StatelessWidget {
  final List<PatternInsight> insights;
  final String locale;
  final bool isLoading;

  const PatternInsightCards({
    super.key,
    required this.insights,
    required this.locale,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    if (isLoading) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withAlpha(100),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n?.collectingData ?? 'Analyzing your patterns...',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (insights.isEmpty) {
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
                l10n?.noInsightsYet ??
                    'Keep logging data to discover your patterns.',
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
        // Disclaimer
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.tertiaryContainer.withAlpha(80),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline,
                  size: 16, color: theme.colorScheme.tertiary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  locale == 'hu'
                      ? 'Ez nem orvosi diagnózis. Csak lehetséges mintákat mutat az adataidból.'
                      : 'This is not a medical diagnosis. These are possible patterns from your data.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...insights.map((insight) => _InsightCard(
              insight: insight,
              locale: locale,
            )),
      ],
    );
  }
}

class _InsightCard extends StatefulWidget {
  final PatternInsight insight;
  final String locale;

  const _InsightCard({required this.insight, required this.locale});

  @override
  State<_InsightCard> createState() => _InsightCardState();
}

class _InsightCardState extends State<_InsightCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _domainColor(widget.insight.domain);
    final icon = _domainIcon(widget.insight.domain);
    final confidencePct = (widget.insight.confidence * 100).round();
    final suggestion = widget.insight.actionSuggestion(widget.locale);

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withAlpha(18),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.insight.title(widget.locale),
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          _ConfidenceIndicator(confidence: widget.insight.confidence),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.locale == 'hu' ? 'Bizalom' : 'Confidence'}: $confidencePct%',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 12),
              Text(
                widget.insight.description(widget.locale),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              if (suggestion != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withAlpha(12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: color, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          suggestion,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: widget.insight.relatedSignals.map((signal) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      signal,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _domainColor(PatternDomain domain) {
    switch (domain) {
      case PatternDomain.sleep:
        return Colors.indigo;
      case PatternDomain.mood:
        return Colors.amber.shade700;
      case PatternDomain.energy:
        return Colors.orange;
      case PatternDomain.activity:
        return Colors.green;
      case PatternDomain.hydration:
        return Colors.blue;
      case PatternDomain.notes:
        return Colors.deepPurple;
      case PatternDomain.finance:
        return Colors.red;
      case PatternDomain.focus:
        return Colors.teal;
      case PatternDomain.general:
        return Colors.grey;
    }
  }

  IconData _domainIcon(PatternDomain domain) {
    switch (domain) {
      case PatternDomain.sleep:
        return Icons.bedtime;
      case PatternDomain.mood:
        return Icons.mood;
      case PatternDomain.energy:
        return Icons.bolt;
      case PatternDomain.activity:
        return Icons.directions_walk;
      case PatternDomain.hydration:
        return Icons.water_drop;
      case PatternDomain.notes:
        return Icons.edit_note;
      case PatternDomain.finance:
        return Icons.account_balance_wallet;
      case PatternDomain.focus:
        return Icons.center_focus_strong;
      case PatternDomain.general:
        return Icons.auto_awesome;
    }
  }
}

class _ConfidenceIndicator extends StatelessWidget {
  final double confidence;
  const _ConfidenceIndicator({required this.confidence});

  @override
  Widget build(BuildContext context) {
    final color = confidence >= 0.6
        ? Colors.green
        : confidence >= 0.35
            ? Colors.orange
            : Colors.grey;
    final label = confidence >= 0.6
        ? 'Strong'
        : confidence >= 0.35
            ? 'Possible'
            : 'Weak';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
