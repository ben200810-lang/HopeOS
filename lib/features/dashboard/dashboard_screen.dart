import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hopeos/l10n/app_localizations.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/navigation_provider.dart';
import '../../core/widgets/hope_logo.dart';
import '../actions/action_provider.dart';
import '../health/health_provider.dart';
import '../mental/mental_provider.dart';
import '../journal/journal_provider.dart';
import '../../data/models/journal_entry.dart';
import '../settings/settings_provider.dart';
import '../timeline/timeline_provider.dart';
import 'widgets/life_score_card.dart';
import 'widgets/next_step_card.dart';
import 'widgets/quick_actions_row.dart';
import 'widgets/drink_capture_dialog.dart';
import 'widgets/life_signals_card.dart';
import '../capture/capture_provider.dart';
import '../../data/models/capture_entry.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      context.read<ActionProvider>().loadActions(),
      context.read<MentalProvider>().loadEntries(),
      context.read<HealthProvider>().loadData(),
      context.read<JournalProvider>().loadEntries(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final settings = context.watch<SettingsProvider>();
    final actions = context.watch<ActionProvider>();
    final mental = context.watch<MentalProvider>();
    final health = context.watch<HealthProvider>();
    final journal = context.watch<JournalProvider>();
    final timeline = context.watch<TimelineProvider>();

    final greeting = AppDateUtils.greeting();

    // Life Score threshold: 3+ distinct days OR 20+ timeline events
    final allEvents = timeline.allEvents;
    final distinctDays = allEvents
        .map((e) =>
            '${e.timestamp.year}-${e.timestamp.month}-${e.timestamp.day}')
        .toSet()
        .length;
    final hasEnoughData = distinctDays >= 3 || allEvents.length >= 20;

    // Calculate Life Score
    final lifeScore = calculateLifeScore(
      actionsCompleted: actions.todayCompleted,
      pendingActions: actions.pendingActions.length,
      waterLiters: health.waterLiters,
      waterGoal: settings.waterGoal,
      sleepHours: health.sleepHours,
      sleepGoal: settings.sleepGoal,
      exerciseMinutes: health.exerciseMinutes,
      exerciseGoal: settings.exerciseGoal,
      moodAverage: mental.weeklyAverage,
      hasMoodEntry: mental.todayEntries.isNotEmpty,
    );

    // Smart suggestion
    final suggestion = getSmartSuggestion(
      waterLiters: health.waterLiters,
      waterGoal: settings.waterGoal,
      hasMoodToday: mental.todayEntries.isNotEmpty,
      journalCount: journal.totalCount,
      sleepHours: health.sleepHours,
      exerciseMinutes: health.exerciseMinutes,
      l10n: l10n,
    );

    // Life Signals data from week entries
    final hydrationData = health.weekEntries
        .map((e) => e.waterLiters)
        .toList();
    final activityData = health.weekEntries
        .map((e) => (e.exerciseMinutes ?? 0).toDouble())
        .toList();
    final sleepData = health.weekEntries
        .map((e) => e.sleepHours ?? 0.0)
        .toList();
    final moodData = mental.recentEntries
        .take(7)
        .toList()
        .reversed
        .map((e) => e.moodLevel.toDouble())
        .toList();

    return RefreshIndicator(
      onRefresh: _loadData,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          // 1. Greeting + Logo
          SliverAppBar(
            floating: true,
            title: Row(
              children: [
                const HopeLogo(size: 32, showText: false),
                const SizedBox(width: 12),
                Text(
                  greeting,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            toolbarHeight: 56,
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),

                // 2. Life Score (or collecting message)
                if (hasEnoughData)
                  LifeScoreCard(
                    score: lifeScore,
                    label: lifeScoreLabel(lifeScore, l10n),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withAlpha(120),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant
                            .withAlpha(40),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.hourglass_top,
                            color: theme.colorScheme.primary, size: 32),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n?.lifeScore ?? 'Life Score',
                                  style: theme.textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(
                                l10n?.collectingData ?? 'Collecting your data to understand your patterns.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                // 3. Next Small Step
                NextStepCard(
                  nextAction: actions.nextAction,
                  smartSuggestion: suggestion.text,
                  smartSuggestionIcon: suggestion.icon,
                  onCompleteAction: (id) async {
                    await actions.completeAction(id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n?.doneNiceWork ?? 'Done! Nice work.'),
                          action: SnackBarAction(
                            label: l10n?.undo ?? 'Undo',
                            onPressed: () => actions.uncompleteAction(id),
                          ),
                          duration: const Duration(seconds: 5),
                        ),
                      );
                    }
                  },
                  onSuggestionTap: () =>
                      _handleSuggestionTap(suggestion, health),
                ),

                const SizedBox(height: 20),

                // 4. Quick Actions
                QuickActionsRow(
                  onNote: () => _navigateToTab(2),
                  onVoice: () => _showVoiceNote(context),
                  onFeeling: () => _navigateToTab(1),
                  onDrink: () async {
                    final result = await showDialog<DrinkResult>(
                      context: context,
                      builder: (_) => const DrinkCaptureDialog(),
                    );
                    if (result != null && context.mounted) {
                      await health.addWater(result.hydrationLiters);
                      if (context.mounted) {
                        final capture = context.read<CaptureProvider>();
                        capture.startDraft(CaptureType.drink);
                        capture.updateDraft(
                          amount: result.hydrationLiters,
                          text: result.drinkName,
                          category: result.drinkName,
                        );
                        await capture.finalizeDraft();
                      }
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '${result.emoji} ${result.drinkName} — ${result.amountMl.round()}ml logged'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  },
                  onExpense: () => _showExpenseNote(context),
                ),

                const SizedBox(height: 20),

                // 5. Life Signals
                LifeSignalsCard(
                  hydrationData: hydrationData,
                  activityData: activityData,
                  sleepData: sleepData,
                  moodData: moodData,
                ),

                // 6. Latest Note Preview
                if (journal.entries.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _LatestNoteCard(
                    entry: journal.entries.first,
                    onTap: () => _navigateToTab(2),
                  ),
                ],

                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToTab(int index) {
    context.read<NavigationProvider>().navigateTo(index);
  }

  void _handleSuggestionTap(
      SmartSuggestion suggestion, HealthProvider health) {
    if (suggestion.icon == Icons.water_drop_outlined ||
        suggestion.icon == Icons.local_cafe_outlined) {
      health.addWater(0.25);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('+250ml water logged'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else if (suggestion.icon == Icons.emoji_emotions_outlined ||
        suggestion.icon == Icons.favorite_outline) {
      _navigateToTab(1); // Capture → Feeling
    } else if (suggestion.icon == Icons.edit_note_outlined) {
      _navigateToTab(2); // Journal
    } else if (suggestion.icon == Icons.directions_walk_outlined ||
        suggestion.icon == Icons.self_improvement_outlined) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)?.takeAMomentForYourself ?? 'Take a moment for yourself'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showVoiceNote(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.voiceNotes ?? 'Voice Notes'),
        content: Text(
          AppLocalizations.of(context)?.voiceNotesComingSoon ?? 'Voice recording is coming soon.\n\nFor now, try the Note button to jot down your thoughts quickly.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)?.gotIt ?? 'Got it'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _navigateToTab(2); // Journal
            },
            child: Text(AppLocalizations.of(context)?.openNotes ?? 'Open Notes'),
          ),
        ],
      ),
    );
  }

  void _showExpenseNote(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.expenseTracking ?? 'Expense Tracking'),
        content: Text(
          AppLocalizations.of(context)?.expenseTrackingComingSoon ?? 'Expense tracking is coming soon.\n\nThis will let you quickly log daily spending to keep your finances in check.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)?.gotIt ?? 'Got it'),
          ),
        ],
      ),
    );
  }
}

class _LatestNoteCard extends StatelessWidget {
  final JournalEntry entry;
  final VoidCallback onTap;

  const _LatestNoteCard({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final preview = entry.content.length > 100
        ? '${entry.content.substring(0, 100)}...'
        : entry.content;

    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.edit_note, size: 16,
                      color: theme.colorScheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    l10n?.latestNote ?? 'Latest Note',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                preview.isEmpty
                    ? (entry.title ?? (l10n?.emptyNote ?? 'Empty note'))
                    : '\u201C$preview\u201D',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
