import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hopeos/l10n/app_localizations.dart';
import '../../../core/widgets/energy_selector.dart';
import '../../capture/capture_provider.dart';
import '../../mental/mental_provider.dart' show MentalProvider;
import '../../journal/journal_provider.dart';
import '../../../data/models/capture_entry.dart';

// ── Mood Quick Entry Sheet ──

class MoodQuickSheet extends StatefulWidget {
  const MoodQuickSheet({super.key});

  @override
  State<MoodQuickSheet> createState() => _MoodQuickSheetState();
}

class _MoodQuickSheetState extends State<MoodQuickSheet> {
  int _moodLevel = 3;
  int _energyLevel = 5;

  static const _moodEmojis = ['😞', '😔', '😐', '🙂', '😄'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n?.howAreYouFeeling ?? 'How are you feeling?',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Mood selector
          Text(
            l10n?.mood ?? 'Mood',
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (i) {
              final level = i + 1;
              final isSelected = _moodLevel == level;
              return GestureDetector(
                onTap: () => setState(() => _moodLevel = level),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primaryContainer
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    _moodEmojis[i],
                    style: TextStyle(fontSize: isSelected ? 36 : 28),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),

          // Energy selector
          Text(
            l10n?.energyLevel ?? 'Energy level',
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          EnergySelector(
            selectedLevel: _energyLevel,
            onChanged: (level) => setState(() => _energyLevel = level),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () async {
                final capture = context.read<CaptureProvider>();
                final mental = context.read<MentalProvider>();
                capture.startDraft(CaptureType.emotion);
                capture.updateDraft(
                  moodLevel: _moodLevel,
                  energyLevel: _energyLevel,
                );
                await capture.finalizeDraft();
                await mental.logMood(
                  moodLevel: _moodLevel,
                  energyLevel: _energyLevel,
                );
                if (context.mounted) Navigator.pop(context, true);
              },
              child: Text(l10n?.logEmotion ?? 'Log Emotion'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Note Quick Entry Sheet ──

class NoteQuickSheet extends StatefulWidget {
  const NoteQuickSheet({super.key});

  @override
  State<NoteQuickSheet> createState() => _NoteQuickSheetState();
}

class _NoteQuickSheetState extends State<NoteQuickSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n?.quickThought ?? 'Quick thought',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: l10n?.whatsOnYourMind ?? 'What\'s on your mind?',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () async {
                final text = _controller.text.trim();
                if (text.isEmpty) return;
                final capture = context.read<CaptureProvider>();
                capture.startDraft(CaptureType.note);
                capture.updateDraft(text: text);
                await capture.finalizeDraft();

                // Also create in JournalProvider so it appears in Recent Notes
                if (context.mounted) {
                  final journal = context.read<JournalProvider>();
                  await journal.createEntry();
                  journal.autosaveContent(text);
                  journal.updateTitle(text.length > 40
                      ? '${text.substring(0, 40)}...'
                      : text);
                }
                if (context.mounted) Navigator.pop(context, true);
              },
              child: Text(l10n?.saveNote ?? 'Save Note'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Finance Quick Entry Sheet ──

class FinanceQuickSheet extends StatefulWidget {
  final bool initialIsIncome;

  const FinanceQuickSheet({super.key, this.initialIsIncome = false});

  @override
  State<FinanceQuickSheet> createState() => _FinanceQuickSheetState();
}

class _FinanceQuickSheetState extends State<FinanceQuickSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  late bool _isIncome = widget.initialIsIncome;
  String _category = 'food';

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final categories = {
      'food': l10n?.food ?? 'Food',
      'transport': l10n?.transport ?? 'Transport',
      'shopping': l10n?.shopping ?? 'Shopping',
      'health': l10n?.health ?? 'Health',
      'bills': l10n?.bills ?? 'Bills',
      'income': l10n?.income ?? 'Income',
      'other': l10n?.other ?? 'Other',
    };

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n?.finance ?? 'Finance',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Income / Expense toggle
          Row(
            children: [
              Expanded(
                child: _ToggleChip(
                  label: '− ${l10n?.expense ?? 'Expense'}',
                  isSelected: !_isIncome,
                  color: Colors.red,
                  onTap: () => setState(() => _isIncome = false),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ToggleChip(
                  label: '+ ${l10n?.income ?? 'Income'}',
                  isSelected: _isIncome,
                  color: Colors.green,
                  onTap: () => setState(() => _isIncome = true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Amount
          TextField(
            controller: _amountController,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: l10n?.amount ?? 'Amount',
              prefixIcon: Icon(
                _isIncome ? Icons.add : Icons.remove,
                color: _isIncome ? Colors.green : Colors.red,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Category chips
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: categories.entries.map((e) {
              final isSelected = _category == e.key;
              return ChoiceChip(
                label: Text(e.value, style: const TextStyle(fontSize: 12)),
                selected: isSelected,
                onSelected: (_) => setState(() => _category = e.key),
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Note
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              hintText: l10n?.descriptionOptional ?? 'Description (optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () async {
                final amountText = _amountController.text.trim();
                if (amountText.isEmpty) return;
                final amount = double.tryParse(amountText);
                if (amount == null || amount <= 0) return;

                final capture = context.read<CaptureProvider>();
                capture.startDraft(CaptureType.expense);
                capture.updateDraft(
                  amount: _isIncome ? amount : -amount,
                  category: _category,
                  text: _noteController.text.trim().isNotEmpty
                      ? _noteController.text.trim()
                      : null,
                );
                await capture.finalizeDraft();
                if (context.mounted) Navigator.pop(context, true);
              },
              child: Text(_isIncome
                  ? (l10n?.logIncome ?? 'Log Income')
                  : (l10n?.logExpense ?? 'Log Expense')),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? color : Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
