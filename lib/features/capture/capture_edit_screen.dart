import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hopeos/l10n/app_localizations.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/capture_entry.dart';
import 'capture_provider.dart';

class CaptureEditScreen extends StatefulWidget {
  final CaptureEntry entry;

  const CaptureEditScreen({super.key, required this.entry});

  @override
  State<CaptureEditScreen> createState() => _CaptureEditScreenState();
}

class _CaptureEditScreenState extends State<CaptureEditScreen> {
  late TextEditingController _textController;
  late TextEditingController _amountController;
  late String _category;
  late int _moodLevel;
  late int _energyLevel;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.entry.text ?? '');
    _amountController = TextEditingController(
        text: widget.entry.amount?.toString() ?? '');
    _category = widget.entry.category ?? 'general';
    _moodLevel = widget.entry.moodLevel ?? 3;
    _energyLevel = widget.entry.energyLevel ?? 3;
  }

  @override
  void dispose() {
    _textController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entry = widget.entry;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(entry.typeEmoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              _typeLabel(entry.type),
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _save,
              child: Text(AppLocalizations.of(context)?.save ?? 'Save'),
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _delete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Metadata
            Row(
              children: [
                Icon(Icons.access_time,
                    size: 14, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  AppDateUtils.formatDateTime(entry.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (entry.isCompleted) ...[
                  const SizedBox(width: 12),
                  Icon(Icons.check_circle, size: 14, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(
                    AppLocalizations.of(context)?.completed ?? 'Completed',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.green,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),

            // Type-specific edit fields
            _buildEditFields(theme, entry),
          ],
        ),
      ),
    );
  }

  Widget _buildEditFields(ThemeData theme, CaptureEntry entry) {
    switch (entry.type) {
      case CaptureType.note:
      case CaptureType.moment:
        return _buildTextEdit(theme, entry.type == CaptureType.note
            ? (AppLocalizations.of(context)?.editNote ?? 'Edit note')
            : (AppLocalizations.of(context)?.editMoment ?? 'Edit moment'));

      case CaptureType.voice:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.mic, color: Colors.deepPurple, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.audioPath != null
                          ? (AppLocalizations.of(context)?.audioRecordingSaved ?? 'Audio recording saved')
                          : (AppLocalizations.of(context)?.noAudioRecorded ?? 'No audio recorded'),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildTextEdit(theme, AppLocalizations.of(context)?.editTranscriptionNote ?? 'Edit transcription note'),
          ],
        );

      case CaptureType.emotion:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)?.mood ?? 'Mood', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(5, (i) {
                final level = i + 1;
                final emojis = ['😢', '😔', '😐', '😊', '😄'];
                return GestureDetector(
                  onTap: () => setState(() {
                    _moodLevel = level;
                    _hasChanges = true;
                  }),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _moodLevel == level
                          ? Colors.amber.withValues(alpha: 0.2)
                          : Colors.transparent,
                      border: _moodLevel == level
                          ? Border.all(color: Colors.amber, width: 2)
                          : null,
                    ),
                    child: Text(emojis[i], style: const TextStyle(fontSize: 28)),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            Text(AppLocalizations.of(context)?.energy ?? 'Energy', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Slider(
              value: _energyLevel.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: '$_energyLevel / 5',
              onChanged: (v) => setState(() {
                _energyLevel = v.round();
                _hasChanges = true;
              }),
            ),
            const SizedBox(height: 16),
            _buildTextEdit(theme, AppLocalizations.of(context)?.editNote ?? 'Edit note'),
          ],
        );

      case CaptureType.drink:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)?.amount ?? 'Amount', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)?.liters ?? 'Liters',
                suffixText: 'L',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() => _hasChanges = true),
            ),
            const SizedBox(height: 16),
            _buildTextEdit(theme, AppLocalizations.of(context)?.editDrinkType ?? 'Edit drink type'),
          ],
        );

      case CaptureType.meal:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: () {
                  final l10n = AppLocalizations.of(context);
                  final categories = {
                    'Breakfast': l10n?.breakfast ?? 'Breakfast',
                    'Lunch': l10n?.lunch ?? 'Lunch',
                    'Dinner': l10n?.dinner ?? 'Dinner',
                    'Snack': l10n?.snack ?? 'Snack',
                  };
                  return categories.entries.map((e) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(e.value),
                        selected: _category == e.key,
                        onSelected: (_) => setState(() {
                          _category = e.key;
                          _hasChanges = true;
                        }),
                      ),
                    );
                  }).toList();
                }(),
              ),
            ),
            const SizedBox(height: 16),
            _buildTextEdit(theme, AppLocalizations.of(context)?.editMealDescription ?? 'Edit meal description'),
          ],
        );

      case CaptureType.expense:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)?.amount ?? 'Amount',
                prefixText: '\$ ',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() => _hasChanges = true),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: () {
                  final l10n = AppLocalizations.of(context);
                  final categories = {
                    'Food': l10n?.food ?? 'Food',
                    'Transport': l10n?.transport ?? 'Transport',
                    'Shopping': l10n?.shopping ?? 'Shopping',
                    'Health': l10n?.health ?? 'Health',
                    'Bills': l10n?.bills ?? 'Bills',
                    'Other': l10n?.other ?? 'Other',
                  };
                  return categories.entries.map((e) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(e.value),
                        selected: _category == e.key,
                        onSelected: (_) => setState(() {
                          _category = e.key;
                          _hasChanges = true;
                        }),
                      ),
                    );
                  }).toList();
                }(),
              ),
            ),
            const SizedBox(height: 16),
            _buildTextEdit(theme, AppLocalizations.of(context)?.editDescription ?? 'Edit description'),
          ],
        );

      case CaptureType.photo:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (entry.imagePath != null)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.cyan.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.photo, size: 48, color: Colors.cyan),
                ),
              ),
            const SizedBox(height: 16),
            _buildTextEdit(theme, AppLocalizations.of(context)?.editCaption ?? 'Edit caption'),
          ],
        );
    }
  }

  Widget _buildTextEdit(ThemeData theme, String hint) {
    return TextField(
      controller: _textController,
      decoration: InputDecoration(hintText: hint),
      maxLines: 5,
      onChanged: (_) => setState(() => _hasChanges = true),
    );
  }

  Future<void> _save() async {
    final capture = context.read<CaptureProvider>();
    var updated = widget.entry.copyWith(
      text: _textController.text.isNotEmpty ? _textController.text.trim() : null,
      updatedAt: DateTime.now(),
    );

    if (widget.entry.type == CaptureType.emotion) {
      updated = updated.copyWith(
        moodLevel: _moodLevel,
        energyLevel: _energyLevel,
      );
    }

    if (widget.entry.type == CaptureType.expense ||
        widget.entry.type == CaptureType.drink) {
      final parsedAmount = double.tryParse(_amountController.text.trim());
      updated = updated.copyWith(
        amount: parsedAmount ?? updated.amount,
        category: _category,
      );
    }

    if (widget.entry.type == CaptureType.meal) {
      updated = updated.copyWith(category: _category);
    }

    await capture.updateEntry(updated);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)?.entryUpdated ?? 'Entry updated'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _delete() async {
    final capture = context.read<CaptureProvider>();
    final id = await capture.deleteEntry(widget.entry.id);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)?.entryDeleted ?? 'Entry deleted'),
          action: SnackBarAction(
            label: AppLocalizations.of(context)?.undo ?? 'Undo',
            onPressed: () => capture.undoDelete(id),
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  String _typeLabel(CaptureType type) {
    final l10n = AppLocalizations.of(context);
    switch (type) {
      case CaptureType.note:
        return l10n?.note ?? 'Note';
      case CaptureType.voice:
        return l10n?.voiceNoteLabel ?? 'Voice Note';
      case CaptureType.emotion:
        return l10n?.emotion ?? 'Emotion';
      case CaptureType.drink:
        return l10n?.drink ?? 'Drink';
      case CaptureType.meal:
        return l10n?.meal ?? 'Meal';
      case CaptureType.expense:
        return l10n?.expense ?? 'Expense';
      case CaptureType.moment:
        return l10n?.moment ?? 'Moment';
      case CaptureType.photo:
        return l10n?.photo ?? 'Photo';
    }
  }
}
