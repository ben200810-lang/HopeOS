import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/navigation_provider.dart';
import '../actions/action_provider.dart';
import '../health/health_provider.dart';
import '../mental/mental_provider.dart';
import '../journal/journal_provider.dart';
import '../settings/settings_provider.dart';
import 'widgets/life_score_card.dart';
import 'widgets/next_step_card.dart';
import 'widgets/quick_actions_row.dart';
import 'widgets/life_signals_card.dart';

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
    final settings = context.watch<SettingsProvider>();
    final actions = context.watch<ActionProvider>();
    final mental = context.watch<MentalProvider>();
    final health = context.watch<HealthProvider>();
    final journal = context.watch<JournalProvider>();

    final greeting = AppDateUtils.greeting();

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
          // 1. Greeting
          SliverAppBar(
            floating: true,
            title: Text(
              greeting,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            toolbarHeight: 56,
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),

                // 2. Life Score
                LifeScoreCard(
                  score: lifeScore,
                  label: lifeScoreLabel(lifeScore),
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
                          content: const Text('Done! Nice work.'),
                          action: SnackBarAction(
                            label: 'Undo',
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
                    await health.addWater(0.25);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('+250ml water logged'),
                          duration: Duration(seconds: 2),
                        ),
                      );
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
        const SnackBar(
          content: Text('Take a moment for yourself'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _showVoiceNote(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Voice Notes'),
        content: const Text(
          'Voice recording is coming soon.\n\n'
          'For now, try the Note button to jot down your thoughts quickly.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _navigateToTab(2); // Journal
            },
            child: const Text('Open Notes'),
          ),
        ],
      ),
    );
  }

  void _showExpenseNote(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Expense Tracking'),
        content: const Text(
          'Expense tracking is coming soon.\n\n'
          'This will let you quickly log daily spending '
          'to keep your finances in check.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
