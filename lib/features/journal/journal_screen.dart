import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hopeos/l10n/app_localizations.dart';
import '../../core/utils/date_utils.dart';
import '../../core/widgets/hope_card.dart';
import '../../data/models/capture_entry.dart';
import '../capture/capture_provider.dart';
import '../capture/capture_edit_screen.dart';
import '../settings/settings_provider.dart';
import 'journal_provider.dart';
import 'journal_editor_screen.dart';
import 'recycle_bin_screen.dart';

/// Unified timeline item for both journal entries and captures.
class _TimelineItem {
  final String id;
  final String title;
  final String? subtitle;
  final String emoji;
  final IconData typeIcon;
  final Color typeColor;
  final DateTime createdAt;
  final bool isJournal;
  final bool isCompleted;
  final bool hasAudio;
  final bool hasImage;
  final dynamic source;

  _TimelineItem({
    required this.id,
    required this.title,
    this.subtitle,
    required this.emoji,
    required this.typeIcon,
    required this.typeColor,
    required this.createdAt,
    required this.isJournal,
    this.isCompleted = false,
    this.hasAudio = false,
    this.hasImage = false,
    required this.source,
  });
}

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;
  String _filter = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final journal = context.watch<JournalProvider>();
    final capture = context.watch<CaptureProvider>();

    final items = _buildTimeline(journal, capture);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          floating: true,
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)?.searchEntries ?? 'Search entries...',
                    border: InputBorder.none,
                  ),
                  onChanged: (query) => journal.searchEntries(query),
                )
              : Text(AppLocalizations.of(context)?.timeline ?? 'Timeline'),
          actions: [
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchController.clear();
                    journal.loadEntries();
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
              onPressed: () => _createNewEntry(context, journal),
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 8),

              // Stats row
              HopeCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatColumn(
                      value: '${journal.totalCount}',
                      label: AppLocalizations.of(context)?.notes ?? 'Notes',
                      color: theme.colorScheme.primary,
                    ),
                    _StatColumn(
                      value: '${capture.todayCount}',
                      label: AppLocalizations.of(context)?.todayLabel ?? 'Today',
                      color: Colors.teal,
                    ),
                    _StatColumn(
                      value: '${capture.totalCount}',
                      label: AppLocalizations.of(context)?.captures ?? 'Captures',
                      color: Colors.orange,
                    ),
                    FilledButton.icon(
                      onPressed: () => _createNewEntry(context, journal),
                      icon: const Icon(Icons.edit, size: 18),
                      label: Text(AppLocalizations.of(context)?.newEntry ?? 'New'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                        label: AppLocalizations.of(context)?.all ?? 'All',
                        isSelected: _filter == 'all',
                        onTap: () => setState(() => _filter = 'all')),
                    const SizedBox(width: 8),
                    _FilterChip(
                        label: '📝 ${AppLocalizations.of(context)?.notes ?? 'Notes'}',
                        isSelected: _filter == 'journal',
                        onTap: () => setState(() => _filter = 'journal')),
                    const SizedBox(width: 8),
                    _FilterChip(
                        label: '🎙️ ${AppLocalizations.of(context)?.voice ?? 'Voice'}',
                        isSelected: _filter == 'voice',
                        onTap: () => setState(() => _filter = 'voice')),
                    const SizedBox(width: 8),
                    _FilterChip(
                        label: '📷 ${AppLocalizations.of(context)?.photos ?? 'Photos'}',
                        isSelected: _filter == 'photo',
                        onTap: () => setState(() => _filter = 'photo')),
                    const SizedBox(width: 8),
                    _FilterChip(
                        label: '😊 ${AppLocalizations.of(context)?.emotions ?? 'Emotions'}',
                        isSelected: _filter == 'emotion',
                        onTap: () => setState(() => _filter = 'emotion')),
                    const SizedBox(width: 8),
                    _FilterChip(
                        label: '💧 ${AppLocalizations.of(context)?.drinks ?? 'Drinks'}',
                        isSelected: _filter == 'drink',
                        onTap: () => setState(() => _filter = 'drink')),
                    const SizedBox(width: 8),
                    _FilterChip(
                        label: '🍽️ ${AppLocalizations.of(context)?.meals ?? 'Meals'}',
                        isSelected: _filter == 'meal',
                        onTap: () => setState(() => _filter = 'meal')),
                    const SizedBox(width: 8),
                    _FilterChip(
                        label: '💰 ${AppLocalizations.of(context)?.expenses ?? 'Expenses'}',
                        isSelected: _filter == 'expense',
                        onTap: () => setState(() => _filter = 'expense')),
                    const SizedBox(width: 8),
                    _FilterChip(
                        label: '✨ ${AppLocalizations.of(context)?.moments ?? 'Moments'}',
                        isSelected: _filter == 'moment',
                        onTap: () => setState(() => _filter = 'moment')),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              if (items.isEmpty)
                _buildEmptyState(theme)
              else
                ...items.map((item) =>
                    _buildTimelineItem(theme, item, journal, capture)),

              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }

  List<_TimelineItem> _buildTimeline(
      JournalProvider journal, CaptureProvider capture) {
    final items = <_TimelineItem>[];

    if (_filter == 'all' || _filter == 'journal') {
      for (final entry in journal.entries) {
        items.add(_TimelineItem(
          id: entry.id,
          title: entry.title ?? (AppLocalizations.of(context)?.untitledNote ?? 'Untitled note'),
          subtitle: entry.content.isNotEmpty ? entry.preview : null,
          emoji: '📝',
          typeIcon: Icons.edit_note,
          typeColor: Colors.teal,
          createdAt: entry.createdAt,
          isJournal: true,
          source: entry,
        ));
      }
    }

    for (final entry in capture.entries) {
      if (_filter != 'all' && _filter != 'journal') {
        if (entry.type.name != _filter) continue;
      }
      if (_filter == 'journal') continue;

      items.add(_TimelineItem(
        id: entry.id,
        title: entry.formattedTitle(context.read<SettingsProvider>().currencySymbol),
        subtitle: entry.text != null ? entry.preview : null,
        emoji: entry.typeEmoji,
        typeIcon: _iconForType(entry.type),
        typeColor: _colorForType(entry.type),
        createdAt: entry.createdAt,
        isJournal: false,
        isCompleted: entry.isCompleted,
        hasAudio: entry.audioPath != null,
        hasImage: entry.imagePath != null,
        source: entry,
      ));
    }

    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.timeline, size: 60,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            Text(AppLocalizations.of(context)?.noEntriesYet ?? 'No entries yet',
                style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 4),
            Text(AppLocalizations.of(context)?.yourCapturesAndNotesWillAppear ?? 'Your captures and notes will appear here',
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(ThemeData theme, _TimelineItem item,
      JournalProvider journal, CaptureProvider capture) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: Key(item.id),
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
              Text(AppLocalizations.of(context)?.recycle ?? 'Recycle', style: const TextStyle(color: Colors.red, fontSize: 10)),
            ],
          ),
        ),
        onDismissed: (_) async {
          final messenger = ScaffoldMessenger.of(context);
          if (item.isJournal) {
            final id = await journal.deleteEntry(item.id);
            messenger.showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)?.movedToRecycleBin ?? 'Moved to recycle bin'),
                action: SnackBarAction(
                  label: AppLocalizations.of(context)?.undo ?? 'Undo',
                  onPressed: () => journal.undoDelete(id),
                ),
                duration: const Duration(seconds: 5),
              ),
            );
          } else {
            final id = await capture.deleteEntry(item.id);
            messenger.showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)?.movedToRecycleBin ?? 'Moved to recycle bin'),
                action: SnackBarAction(
                  label: AppLocalizations.of(context)?.undo ?? 'Undo',
                  onPressed: () => capture.undoDelete(id),
                ),
                duration: const Duration(seconds: 5),
              ),
            );
          }
        },
        child: HopeCard(
          onTap: () {
            if (item.isJournal) {
              journal.setCurrentEntry(item.source);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const JournalEditorScreen()));
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CaptureEditScreen(entry: item.source as CaptureEntry),
                ),
              );
            }
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Completed checkbox for captures
              if (!item.isJournal)
                GestureDetector(
                  onTap: () => capture.toggleCompleted(item.id),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10, top: 2),
                    child: Icon(
                      item.isCompleted
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: item.isCompleted ? Colors.green : Colors.grey,
                      size: 22,
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Text(item.emoji, style: const TextStyle(fontSize: 22)),
                ),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Type indicator icon
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: item.typeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(item.typeIcon,
                              size: 12, color: item.typeColor),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              decoration: item.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: item.isCompleted
                                  ? theme.colorScheme.onSurfaceVariant
                                  : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Entry type badges
                        if (item.hasAudio)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Icon(Icons.mic, size: 14,
                                color: Colors.deepPurple.withValues(alpha: 0.6)),
                          ),
                        if (item.hasImage)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Icon(Icons.image, size: 14,
                                color: Colors.cyan.withValues(alpha: 0.6)),
                          ),
                        const SizedBox(width: 4),
                        Text(
                          AppDateUtils.timeAgo(item.createdAt),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    if (item.subtitle != null &&
                        item.subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          decoration: item.isCompleted
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

  Future<void> _createNewEntry(
      BuildContext context, JournalProvider journal) async {
    await journal.createEntry();
    if (context.mounted) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const JournalEditorScreen()));
    }
  }

  IconData _iconForType(CaptureType type) {
    switch (type) {
      case CaptureType.note:
        return Icons.edit_note;
      case CaptureType.voice:
        return Icons.mic;
      case CaptureType.emotion:
        return Icons.mood;
      case CaptureType.drink:
        return Icons.water_drop;
      case CaptureType.meal:
        return Icons.restaurant;
      case CaptureType.expense:
        return Icons.receipt_long;
      case CaptureType.moment:
        return Icons.auto_awesome;
      case CaptureType.photo:
        return Icons.camera_alt;
    }
  }

  Color _colorForType(CaptureType type) {
    switch (type) {
      case CaptureType.note:
        return Colors.teal;
      case CaptureType.voice:
        return Colors.deepPurple;
      case CaptureType.emotion:
        return Colors.amber.shade700;
      case CaptureType.drink:
        return Colors.blue;
      case CaptureType.meal:
        return Colors.orange;
      case CaptureType.expense:
        return Colors.red.shade400;
      case CaptureType.moment:
        return Colors.pink;
      case CaptureType.photo:
        return Colors.cyan;
    }
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
            style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold, color: color)),
        Text(label,
            style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
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
