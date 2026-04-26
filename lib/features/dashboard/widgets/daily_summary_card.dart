import 'package:flutter/material.dart';
import 'package:hopeos/l10n/app_localizations.dart';
import '../../../core/widgets/progress_ring.dart';
import '../../../data/models/mood_entry.dart';

class DailySummaryCard extends StatelessWidget {
  final int actionsCompleted;
  final int pendingActions;
  final MoodEntry? latestMood;
  final double waterLiters;
  final double waterGoal;
  final int exerciseMinutes;
  final int exerciseGoal;

  const DailySummaryCard({
    super.key,
    required this.actionsCompleted,
    required this.pendingActions,
    required this.latestMood,
    required this.waterLiters,
    required this.waterGoal,
    required this.exerciseMinutes,
    required this.exerciseGoal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.todaysProgress ?? 'Today\'s Progress',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SummaryItem(
                ring: ProgressRing(
                  progress: pendingActions > 0
                      ? actionsCompleted /
                          (actionsCompleted + pendingActions)
                      : 1.0,
                  size: 52,
                  color: theme.colorScheme.primary,
                  child: Text(
                    '$actionsCompleted',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                label: l10n?.actions ?? 'Actions',
              ),
              _SummaryItem(
                ring: ProgressRing(
                  progress: waterGoal > 0 ? waterLiters / waterGoal : 0,
                  size: 52,
                  color: Colors.blue,
                  child: Text(
                    '${waterLiters.toStringAsFixed(1)}L',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                label: l10n?.water ?? 'Water',
              ),
              _SummaryItem(
                ring: ProgressRing(
                  progress: exerciseGoal > 0
                      ? exerciseMinutes / exerciseGoal
                      : 0,
                  size: 52,
                  color: Colors.green,
                  child: Text(
                    '${exerciseMinutes}m',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                label: l10n?.exercise ?? 'Exercise',
              ),
              _SummaryItem(
                ring: SizedBox(
                  width: 52,
                  height: 52,
                  child: Center(
                    child: Text(
                      latestMood?.moodEmoji ?? '—',
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                label: l10n?.mood ?? 'Mood',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final Widget ring;
  final String label;

  const _SummaryItem({
    required this.ring,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ring,
        const SizedBox(height: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
