import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hopeos/l10n/app_localizations.dart';

import '../../core/utils/date_utils.dart';
import '../../core/widgets/hope_card.dart';
import '../../data/models/capture_entry.dart';
import '../../data/models/journal_entry.dart';
import '../../data/models/timeline_event.dart';
import '../capture/capture_edit_screen.dart';
import '../capture/capture_provider.dart';
import '../journal/journal_editor_screen.dart';
import '../journal/journal_provider.dart';
import '../journal/recycle_bin_screen.dart';
import '../settings/settings_provider.dart';
import 'timeline_provider.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final symbol = context.read<SettingsProvider>().currencySymbol;
      context.read<TimelineProvider>().loadAll(currencySymbol: symbol);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeline = context.watch<TimelineProvider>();
    final l10n = AppLocalizations.of(context);

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        SliverAppBar(
          floating: true,
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: l10n?.searchTimeline ?? 'Search timeline...',
                    border: InputBorder.none,
                  ),
                  onChanged: (query) => timeline.search(query),
                )
              : Text(l10n?.lifeTimeline ?? 'Life Timeline'),
          actions: [
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchController.clear();
                    timeline.clearSearch();
                  }
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Recycle Bin',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RecycleBinScreen()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _createNewEntry(context),
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 8),

              // Stats row
              _StatsRow(
                totalCount: timeline.totalCount,
                todayCount: timeline.todayCount,
                onNewEntry: () => _createNewEntry(context),
              ),

              const SizedBox(height: 12),

              // Filter chips
              _FilterChipsRow(
                activeFilter: timeline.activeFilter,
                onFilterChanged: timeline.setFilter,
              ),

              const SizedBox(height: 12),

              if (timeline.isLoading)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (timeline.events.isEmpty)
                _buildEmptyState(theme)
              else
                ...timeline.events
                    .map((event) => _buildEventCard(theme, event)),

              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.timeline,
                size: 60,
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            Text(AppLocalizations.of(context)?.noEntriesYet ?? 'No entries yet',
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 4),
            Text(AppLocalizations.of(context)?.yourLifeEventsWillAppear ?? 'Your life events will appear here',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(ThemeData theme, TimelineEvent event) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _DismissibleEventCard(
        event: event,
        child: HopeCard(
          onTap: () => _onEventTap(event),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emoji / icon column
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Text(event.emoji, style: const TextStyle(fontSize: 22)),
              ),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Type badge
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: event.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child:
                              Icon(event.icon, size: 12, color: event.color),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            event.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              decoration: event.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: event.isCompleted
                                  ? theme.colorScheme.onSurfaceVariant
                                  : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppDateUtils.timeAgo(event.timestamp),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    if (event.type == TimelineEventType.capturePhoto &&
                        event.source is CaptureEntry &&
                        (event.source as CaptureEntry).imagePath != null &&
                        File((event.source as CaptureEntry).imagePath!).existsSync()) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File((event.source as CaptureEntry).imagePath!),
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                    if (event.subtitle != null &&
                        event.subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        event.subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          decoration: event.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onEventTap(TimelineEvent event) {
    switch (event.type) {
      case TimelineEventType.journal:
        final entry = event.source as JournalEntry;
        context.read<JournalProvider>().setCurrentEntry(entry);
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const JournalEditorScreen()));

      case TimelineEventType.captureNote:
      case TimelineEventType.captureVoice:
      case TimelineEventType.captureEmotion:
      case TimelineEventType.captureDrink:
      case TimelineEventType.captureMeal:
      case TimelineEventType.captureExpense:
      case TimelineEventType.captureMoment:
      case TimelineEventType.capturePhoto:
        final entry = event.source as CaptureEntry;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CaptureEditScreen(entry: entry),
          ),
        );

      case TimelineEventType.moodLog:
      case TimelineEventType.healthWater:
      case TimelineEventType.healthSleep:
      case TimelineEventType.healthExercise:
      case TimelineEventType.actionCompleted:
      case TimelineEventType.activity:
      case TimelineEventType.rescue:
        // Read-only events -- show a detail snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(event.title),
            duration: const Duration(seconds: 2),
          ),
        );
    }
  }

  Future<void> _createNewEntry(BuildContext context) async {
    final journal = context.read<JournalProvider>();
    await journal.createEntry();
    if (context.mounted) {
      await Navigator.push(context,
          MaterialPageRoute(builder: (_) => const JournalEditorScreen()));
      if (context.mounted) {
        final symbol = context.read<SettingsProvider>().currencySymbol;
        context.read<TimelineProvider>().loadAll(currencySymbol: symbol);
      }
    }
  }
}

// ── Dismissible wrapper for deletable events ──

class _DismissibleEventCard extends StatelessWidget {
  final TimelineEvent event;
  final Widget child;

  const _DismissibleEventCard({
    required this.event,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Only journal and capture events are deletable
    if (event.type != TimelineEventType.journal &&
        !_isCaptureEvent(event.type)) {
      return child;
    }

    return Dismissible(
      key: Key(event.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.delete_outline, color: Colors.red),
            const SizedBox(height: 2),
            Text(AppLocalizations.of(context)?.recycle ?? 'Recycle',
                style: const TextStyle(color: Colors.red, fontSize: 10)),
          ],
        ),
      ),
      onDismissed: (_) => _handleDelete(context),
      child: child,
    );
  }

  void _handleDelete(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    final timeline = context.read<TimelineProvider>();
    final symbol = context.read<SettingsProvider>().currencySymbol;
    final movedLabel = AppLocalizations.of(context)?.movedToRecycleBin ?? 'Moved to recycle bin';
    final undoLabel = AppLocalizations.of(context)?.undo ?? 'Undo';

    if (event.type == TimelineEventType.journal) {
      final entry = event.source as JournalEntry;
      final journal = context.read<JournalProvider>();
      journal.deleteEntry(entry.id).then((_) {
        timeline.loadAll(currencySymbol: symbol);
        messenger.showSnackBar(
          SnackBar(
            content: Text(movedLabel),
            action: SnackBarAction(
              label: undoLabel,
              onPressed: () {
                journal.undoDelete(entry.id);
                timeline.loadAll(currencySymbol: symbol);
              },
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      });
    } else if (_isCaptureEvent(event.type)) {
      final entry = event.source as CaptureEntry;
      final capture = context.read<CaptureProvider>();
      capture.deleteEntry(entry.id).then((_) {
        timeline.loadAll(currencySymbol: symbol);
        messenger.showSnackBar(
          SnackBar(
            content: Text(movedLabel),
            action: SnackBarAction(
              label: undoLabel,
              onPressed: () {
                capture.undoDelete(entry.id);
                timeline.loadAll(currencySymbol: symbol);
              },
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      });
    }
  }

  bool _isCaptureEvent(TimelineEventType type) {
    return type == TimelineEventType.captureNote ||
        type == TimelineEventType.captureVoice ||
        type == TimelineEventType.captureEmotion ||
        type == TimelineEventType.captureDrink ||
        type == TimelineEventType.captureMeal ||
        type == TimelineEventType.captureExpense ||
        type == TimelineEventType.captureMoment ||
        type == TimelineEventType.capturePhoto;
  }
}

// ── Stats Row ──

class _StatsRow extends StatelessWidget {
  final int totalCount;
  final int todayCount;
  final VoidCallback onNewEntry;

  const _StatsRow({
    required this.totalCount,
    required this.todayCount,
    required this.onNewEntry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return HopeCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatColumn(
            value: '$totalCount',
            label: AppLocalizations.of(context)?.total ?? 'Total',
            color: theme.colorScheme.primary,
          ),
          _StatColumn(
            value: '$todayCount',
            label: AppLocalizations.of(context)?.todayLabel ?? 'Today',
            color: Colors.teal,
          ),
          FilledButton.icon(
            onPressed: onNewEntry,
            icon: const Icon(Icons.edit, size: 18),
            label: Text(AppLocalizations.of(context)?.newEntry ?? 'New'),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatColumn({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold, color: color)),
        Text(label,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

// ── Filter Chips ──

class _FilterChipsRow extends StatelessWidget {
  final TimelineFilter activeFilter;
  final ValueChanged<TimelineFilter> onFilterChanged;

  const _FilterChipsRow({
    required this.activeFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChipWidget(
            label: AppLocalizations.of(context)?.all ?? 'All',
            isSelected: activeFilter == TimelineFilter.all,
            onTap: () => onFilterChanged(TimelineFilter.all),
          ),
          const SizedBox(width: 8),
          _FilterChipWidget(
            label: '\u{1F4DD} ${AppLocalizations.of(context)?.notes ?? 'Notes'}',
            isSelected: activeFilter == TimelineFilter.notes,
            onTap: () => onFilterChanged(TimelineFilter.notes),
          ),
          const SizedBox(width: 8),
          _FilterChipWidget(
            label: '\u{1F4B0} ${AppLocalizations.of(context)?.finance ?? 'Finance'}',
            isSelected: activeFilter == TimelineFilter.finance,
            onTap: () => onFilterChanged(TimelineFilter.finance),
          ),
          const SizedBox(width: 8),
          _FilterChipWidget(
            label: '\u{1F4A7} ${AppLocalizations.of(context)?.drinks ?? 'Drinks'}',
            isSelected: activeFilter == TimelineFilter.drinks,
            onTap: () => onFilterChanged(TimelineFilter.drinks),
          ),
          const SizedBox(width: 8),
          _FilterChipWidget(
            label: '\u{1F60A} ${AppLocalizations.of(context)?.moodEnergy ?? 'Mood/Energy'}',
            isSelected: activeFilter == TimelineFilter.moodEnergy,
            onTap: () => onFilterChanged(TimelineFilter.moodEnergy),
          ),
          const SizedBox(width: 8),
          _FilterChipWidget(
            label: '\u{1F634} ${AppLocalizations.of(context)?.sleep ?? 'Sleep'}',
            isSelected: activeFilter == TimelineFilter.sleep,
            onTap: () => onFilterChanged(TimelineFilter.sleep),
          ),
          const SizedBox(width: 8),
          _FilterChipWidget(
            label: '\u{1F3C3} ${AppLocalizations.of(context)?.activity ?? 'Activity'}',
            isSelected: activeFilter == TimelineFilter.activity,
            onTap: () => onFilterChanged(TimelineFilter.activity),
          ),
          const SizedBox(width: 8),
          _FilterChipWidget(
            label: '\u{1F525} ${AppLocalizations.of(context)?.rescue ?? 'Rescue'}',
            isSelected: activeFilter == TimelineFilter.rescue,
            onTap: () => onFilterChanged(TimelineFilter.rescue),
          ),
        ],
      ),
    );
  }
}

class _FilterChipWidget extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChipWidget({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: theme.colorScheme.primaryContainer,
      showCheckmark: false,
    );
  }
}
