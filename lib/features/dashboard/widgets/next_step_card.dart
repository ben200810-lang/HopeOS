import 'package:flutter/material.dart';
import 'package:hopeos/l10n/app_localizations.dart';
import '../../../data/models/action_item.dart';

class NextStepCard extends StatelessWidget {
  final ActionItem? nextAction;
  final String smartSuggestion;
  final IconData smartSuggestionIcon;
  final Function(String)? onCompleteAction;
  final VoidCallback? onSuggestionTap;

  const NextStepCard({
    super.key,
    this.nextAction,
    required this.smartSuggestion,
    required this.smartSuggestionIcon,
    this.onCompleteAction,
    this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: nextAction != null
              ? () => onCompleteAction?.call(nextAction!.id)
              : onSuggestionTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: theme.colorScheme.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n?.nextSmallStep ?? 'NEXT SMALL STEP',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (nextAction != null) ...[
                  Text(
                    nextAction!.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      FilledButton.icon(
                        onPressed: () =>
                            onCompleteAction?.call(nextAction!.id),
                        icon: const Icon(Icons.check, size: 18),
                        label: Text(l10n?.done ?? 'Done'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        l10n?.tapToComplete ?? 'Tap to complete',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    children: [
                      Icon(
                        smartSuggestionIcon,
                        size: 22,
                        color: theme.colorScheme.onPrimaryContainer
                            .withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          smartSuggestion,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n?.tapToGetStarted ?? 'Tap to get started',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer
                          .withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SmartSuggestion {
  final String text;
  final IconData icon;

  const SmartSuggestion(this.text, this.icon);
}

SmartSuggestion getSmartSuggestion({
  required double waterLiters,
  required double waterGoal,
  required bool hasMoodToday,
  required int journalCount,
  required double sleepHours,
  required int exerciseMinutes,
}) {
  final hour = DateTime.now().hour;

  // Morning suggestions
  if (hour < 10) {
    if (waterLiters < 0.25) {
      return const SmartSuggestion(
        'Drink a glass of water',
        Icons.water_drop_outlined,
      );
    }
    if (!hasMoodToday) {
      return const SmartSuggestion(
        'How are you feeling today?',
        Icons.emoji_emotions_outlined,
      );
    }
  }

  // Hydration reminders throughout the day
  if (waterGoal > 0 && waterLiters / waterGoal < 0.3 && hour > 10) {
    return const SmartSuggestion(
      'Drink something',
      Icons.local_cafe_outlined,
    );
  }

  // Afternoon
  if (hour >= 12 && hour < 14 && exerciseMinutes == 0) {
    return const SmartSuggestion(
      'Take a short walk',
      Icons.directions_walk_outlined,
    );
  }

  // Mid-afternoon break
  if (hour >= 14 && hour < 16) {
    return const SmartSuggestion(
      'Take a short break',
      Icons.self_improvement_outlined,
    );
  }

  // Evening reflection
  if (hour >= 18 && journalCount == 0) {
    return const SmartSuggestion(
      'Log a note about your day',
      Icons.edit_note_outlined,
    );
  }

  // No mood logged yet
  if (!hasMoodToday) {
    return const SmartSuggestion(
      'Check in with yourself',
      Icons.favorite_outline,
    );
  }

  // Default
  if (waterGoal > 0 && waterLiters / waterGoal < 0.6) {
    return const SmartSuggestion(
      'Drink something',
      Icons.water_drop_outlined,
    );
  }

  return const SmartSuggestion(
    'Take a deep breath',
    Icons.self_improvement_outlined,
  );
}
