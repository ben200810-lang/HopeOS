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
    _category = widget.entry.category ?? 'General';
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
            ? 'Edit note'
            : 'Edit moment');

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
                          ? 'Audio recording saved'
                          : 'No audio recorded',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildTextEdit(theme, 'Edit transcription note'),
          ],
        );

      case CaptureType.emotion:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mood', style: theme.textTheme.titleSmall),
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
            Text('Energy', style: theme.textTheme.titleSmall),
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
            _buildTextEdit(theme, 'Edit note'),
          ],
        );

      case CaptureType.drink:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                hintText: 'Liters',
                suffixText: 'L',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() => _hasChanges = true),
            ),
            const SizedBox(height: 16),
            _buildTextEdit(theme, 'Edit drink type'),
          ],
        );

      case CaptureType.meal:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Breakfast', 'Lunch', 'Dinner', 'Snack'].map((c) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(c),
                      selected: _category == c,
                      onSelected: (_) => setState(() {
                        _category = c;
                        _hasChanges = true;
                      }),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            _buildTextEdit(theme, 'Edit meal description'),
          ],
        );

      case CaptureType.expense:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                hintText: 'Amount',
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
                children: [
                  'Food',
                  'Transport',
                  'Shopping',
                  'Health',
                  'Bills',
                  'Other'
                ].map((c) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(c),
                      selected: _category == c,
                      onSelected: (_) => setState(() {
                        _category = c;
                        _hasChanges = true;
                      }),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            _buildTextEdit(theme, 'Edit description'),
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
            _buildTextEdit(theme, 'Edit caption'),
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
        const SnackBar(
          content: Text('Entry updated'),
          duration: Duration(seconds: 2),
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
          content: const Text('Entry deleted'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => capture.undoDelete(id),
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  String _typeLabel(CaptureType type) {
    switch (type) {
      case CaptureType.note:
        return 'Note';
      case CaptureType.voice:
        return 'Voice Note';
      case CaptureType.emotion:
        return 'Emotion';
      case CaptureType.drink:
        return 'Drink';
      case CaptureType.meal:
        return 'Meal';
      case CaptureType.expense:
        return 'Expense';
      case CaptureType.moment:
        return 'Moment';
      case CaptureType.photo:
        return 'Photo';
    }
  }
}
