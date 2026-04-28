import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hopeos/l10n/app_localizations.dart';
import '../../core/utils/date_utils.dart';
import '../../core/widgets/hope_logo.dart';
import '../actions/action_provider.dart';
import '../health/health_provider.dart';
import '../mental/mental_provider.dart';
import '../journal/journal_provider.dart';
import '../../data/models/journal_entry.dart';
import '../settings/settings_provider.dart';
import '../timeline/timeline_provider.dart';
import 'widgets/life_score_card.dart';
import 'widgets/quick_actions_row.dart';
import 'widgets/drink_capture_dialog.dart';
import 'widgets/quick_entry_sheets.dart';
import 'widgets/recent_notes_card.dart';
import 'widgets/finance_summary_card.dart';
import 'widgets/note_quick_edit_sheet.dart';

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
      context.read<TimelineProvider>().loadAll(
        currencySymbol: context.read<SettingsProvider>().currencySymbol,
      ),
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

                // 2. Quick Actions (floating sheets)
                QuickActionsRow(
                  onNote: () => _showNoteSheet(context),
                  onMood: () => _showMoodSheet(context),
                  onDrink: () => _showDrinkSheet(context, health),
                  onIncome: () => _showFinanceSheet(context, isIncome: true),
                  onExpense: () => _showFinanceSheet(context),
                ),

                const SizedBox(height: 20),

                // 3. Recent Notes (last 3) — opens quick edit
                if (journal.entries.isNotEmpty)
                  RecentNotesCard(
                    recentNotes: journal.entries.take(3).toList(),
                    onNoteTap: (entry) => _showNoteQuickEdit(context, entry),
                  ),

                const SizedBox(height: 20),

                // 4. Finance Summary
                FinanceSummaryCard(
                  recentExpenses: context
                      .watch<CaptureProvider>()
                      .entries
                      .where((e) => e.type == CaptureType.expense)
                      .toList(),
                  onAddIncome: () => _showFinanceSheet(context, isIncome: true),
                  onAddExpense: () => _showFinanceSheet(context),
                ),

                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showNoteQuickEdit(BuildContext context, JournalEntry entry) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => NoteQuickEditSheet(entry: entry),
    );
    if (result == true && context.mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.noteSaved ?? 'Note saved'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showDrinkSheet(BuildContext context, HealthProvider health) async {
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
          amount: result.amountMl / 1000,
          text: result.drinkName,
          category: result.drinkName,
        );
        await capture.finalizeDraft();
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${result.emoji} ${result.drinkName} — ${result.amountMl.round()}ml'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showMoodSheet(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const MoodQuickSheet(),
    );
    if (result == true && context.mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.moodLogged ?? 'Mood logged'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showNoteSheet(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const NoteQuickSheet(),
    );
    if (result == true && context.mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.noteSaved ?? 'Note saved'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showFinanceSheet(BuildContext context, {bool isIncome = false}) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => FinanceQuickSheet(initialIsIncome: isIncome),
    );
    if (result == true && context.mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.transactionLogged ?? 'Transaction logged'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}


