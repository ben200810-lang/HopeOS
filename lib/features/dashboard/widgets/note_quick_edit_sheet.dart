import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hopeos/l10n/app_localizations.dart';
import '../../../data/models/journal_entry.dart';
import '../../journal/journal_provider.dart';

class NoteQuickEditSheet extends StatefulWidget {
  final JournalEntry entry;

  const NoteQuickEditSheet({super.key, required this.entry});

  @override
  State<NoteQuickEditSheet> createState() => _NoteQuickEditSheetState();
}

class _NoteQuickEditSheetState extends State<NoteQuickEditSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry.title ?? '');
    _contentController = TextEditingController(text: widget.entry.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
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
            l10n?.editNote ?? 'Edit Note',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: l10n?.title ?? 'Title',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _contentController,
            autofocus: true,
            maxLines: 5,
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
              onPressed: () {
                final title = _titleController.text.trim();
                final content = _contentController.text.trim();
                if (content.isEmpty) return;

                final journal = context.read<JournalProvider>();
                journal.setCurrentEntry(widget.entry);
                journal.autosaveContent(content);
                if (title.isNotEmpty) {
                  journal.updateTitle(title);
                }

                Navigator.pop(context, true);
              },
              child: Text(l10n?.save ?? 'Save'),
            ),
          ),
        ],
      ),
    );
  }
}
