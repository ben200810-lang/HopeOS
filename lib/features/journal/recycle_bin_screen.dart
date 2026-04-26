import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hopeos/l10n/app_localizations.dart';
import '../../core/utils/date_utils.dart';
import '../../core/widgets/hope_card.dart';
import '../capture/capture_provider.dart';
import 'journal_provider.dart';

class RecycleBinScreen extends StatefulWidget {
  const RecycleBinScreen({super.key});

  @override
  State<RecycleBinScreen> createState() => _RecycleBinScreenState();
}

class _RecycleBinScreenState extends State<RecycleBinScreen> {
  List<_DeletedItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);

    final journal = context.read<JournalProvider>();
    final capture = context.read<CaptureProvider>();

    // Purge expired items first
    await journal.purgeExpiredItems();
    await capture.purgeExpiredItems();

    final journalDeleted = await journal.getDeletedItems();
    final captureDeleted = await capture.getDeletedItems();

    final items = <_DeletedItem>[];

    for (final item in journalDeleted) {
      final data = jsonDecode(item['data'] as String) as Map<String, dynamic>;
      final deletedAt = DateTime.parse(item['deletedAt'] as String);
      final expiresAt = deletedAt.add(const Duration(days: 30));
      final daysLeft = expiresAt.difference(DateTime.now()).inDays;

      items.add(_DeletedItem(
        id: item['id'] as String,
        title: (data['title'] as String?) ?? 'Untitled note',
        subtitle: data['content'] as String? ?? '',
        emoji: '📝',
        tableName: 'journal_entries',
        deletedAt: deletedAt,
        daysLeft: daysLeft,
      ));
    }

    for (final item in captureDeleted) {
      final data = jsonDecode(item['data'] as String) as Map<String, dynamic>;
      final deletedAt = DateTime.parse(item['deletedAt'] as String);
      final expiresAt = deletedAt.add(const Duration(days: 30));
      final daysLeft = expiresAt.difference(DateTime.now()).inDays;
      final type = data['type'] as String? ?? 'note';

      items.add(_DeletedItem(
        id: item['id'] as String,
        title: data['text'] as String? ?? type,
        subtitle: 'Type: $type',
        emoji: _emojiForType(type),
        tableName: 'captures',
        deletedAt: deletedAt,
        daysLeft: daysLeft,
      ));
    }

    items.sort((a, b) => b.deletedAt.compareTo(a.deletedAt));

    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  String _emojiForType(String type) {
    switch (type) {
      case 'note':
        return '📝';
      case 'voice':
        return '🎙️';
      case 'emotion':
        return '😊';
      case 'drink':
        return '💧';
      case 'meal':
        return '🍽️';
      case 'expense':
        return '💰';
      case 'moment':
        return '✨';
      case 'photo':
        return '📷';
      default:
        return '📄';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.recycleBin ?? 'Recycle Bin'),
        actions: [
          if (_items.isNotEmpty)
            TextButton(
              onPressed: _emptyBin,
              child: Text(
                AppLocalizations.of(context)?.empty ?? 'Empty',
                style: TextStyle(color: Colors.red.shade400),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? _buildEmptyState(theme)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  itemBuilder: (context, index) =>
                      _buildDeletedItem(theme, _items[index]),
                ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.delete_outline,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)?.recycleBinEmpty ?? 'Recycle bin is empty',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.of(context)?.deletedItemsKept ?? 'Deleted items are kept for 30 days',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeletedItem(ThemeData theme, _DeletedItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: HopeCard(
        child: Row(
          children: [
            Text(item.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.daysLeft} days left · Deleted ${AppDateUtils.timeAgo(item.deletedAt)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: item.daysLeft <= 3
                          ? Colors.red
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.restore, color: Colors.teal),
              tooltip: 'Restore',
              onPressed: () => _restoreItem(item),
            ),
            IconButton(
              icon: Icon(Icons.delete_forever, color: Colors.red.shade400),
              tooltip: 'Delete permanently',
              onPressed: () => _permanentlyDeleteItem(item),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _restoreItem(_DeletedItem item) async {
    if (item.tableName == 'journal_entries') {
      await context.read<JournalProvider>().undoDelete(item.id);
    } else {
      await context.read<CaptureProvider>().undoDelete(item.id);
    }
    await _loadItems();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)?.itemRestored ?? 'Item restored'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _permanentlyDeleteItem(_DeletedItem item) async {
    final journalProvider = context.read<JournalProvider>();
    final captureProvider = context.read<CaptureProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.deletePermanently ?? 'Delete permanently?'),
        content: Text(AppLocalizations.of(context)?.cannotBeUndone ?? 'This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppLocalizations.of(context)?.delete ?? 'Delete', style: TextStyle(color: Colors.red.shade400)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (item.tableName == 'journal_entries') {
      await journalProvider.permanentlyDelete(item.id);
    } else {
      await captureProvider.permanentlyDelete(item.id);
    }
    await _loadItems();
  }

  Future<void> _emptyBin() async {
    final journalProvider = context.read<JournalProvider>();
    final captureProvider = context.read<CaptureProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.emptyRecycleBin ?? 'Empty recycle bin?'),
        content: Text(AppLocalizations.of(context)?.allItemsWillBeDeleted(_items.length) ?? 'All ${_items.length} items will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Empty', style: TextStyle(color: Colors.red.shade400)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    for (final item in _items) {
      if (item.tableName == 'journal_entries') {
        await journalProvider.permanentlyDelete(item.id);
      } else {
        await captureProvider.permanentlyDelete(item.id);
      }
    }
    await _loadItems();
  }
}

class _DeletedItem {
  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final String tableName;
  final DateTime deletedAt;
  final int daysLeft;

  _DeletedItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.tableName,
    required this.deletedAt,
    required this.daysLeft,
  });
}
