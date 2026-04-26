import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/id_generator.dart';
import '../../data/models/journal_entry.dart';
import '../../data/repositories/journal_repository.dart';

class JournalProvider extends ChangeNotifier {
  final JournalRepository _repository = JournalRepository();

  List<JournalEntry> _entries = [];
  JournalEntry? _currentEntry;
  int _totalCount = 0;
  bool _isLoading = true;
  Timer? _autosaveTimer;
  Timer? _titleSaveTimer;

  List<JournalEntry> get entries => _entries;
  JournalEntry? get currentEntry => _currentEntry;
  int get totalCount => _totalCount;
  bool get isLoading => _isLoading;

  Future<void> loadEntries() async {
    _isLoading = true;
    notifyListeners();

    _entries = await _repository.getAll();
    _totalCount = await _repository.getTotalCount();

    _isLoading = false;
    notifyListeners();
  }

  Future<JournalEntry> createEntry() async {
    _autosaveTimer?.cancel();
    _titleSaveTimer?.cancel();
    final now = DateTime.now();
    final entry = JournalEntry(
      id: IdGenerator.generate(),
      content: '',
      createdAt: now,
      updatedAt: now,
    );
    await _repository.insert(entry);
    _currentEntry = entry;
    await loadEntries();
    return entry;
  }

  void setCurrentEntry(JournalEntry entry) {
    _autosaveTimer?.cancel();
    _titleSaveTimer?.cancel();
    _currentEntry = entry;
    notifyListeners();
  }

  void autosaveContent(String content) {
    _autosaveTimer?.cancel();
    final entryId = _currentEntry?.id;
    _autosaveTimer = Timer(AppConstants.autosaveDelay, () async {
      if (_currentEntry != null && _currentEntry!.id == entryId) {
        final updated = _currentEntry!.copyWith(
          content: content,
          updatedAt: DateTime.now(),
        );
        await _repository.update(updated);
        _currentEntry = updated;
        await loadEntries();
      }
    });
  }

  void updateTitle(String title) {
    _titleSaveTimer?.cancel();
    final entryId = _currentEntry?.id;
    _titleSaveTimer = Timer(AppConstants.autosaveDelay, () async {
      if (_currentEntry != null && _currentEntry!.id == entryId) {
        final updated = _currentEntry!.copyWith(
          title: title,
          updatedAt: DateTime.now(),
        );
        await _repository.update(updated);
        _currentEntry = updated;
        await loadEntries();
      }
    });
  }

  Future<void> updateTags(List<String> tags) async {
    if (_currentEntry == null) return;
    final updated = _currentEntry!.copyWith(
      tags: tags,
      updatedAt: DateTime.now(),
    );
    await _repository.update(updated);
    _currentEntry = updated;
    await loadEntries();
  }

  Future<String> deleteEntry(String id) async {
    await _repository.delete(id);
    if (_currentEntry?.id == id) _currentEntry = null;
    await loadEntries();
    return id;
  }

  Future<bool> undoDelete(String id) async {
    final result = await _repository.undoDelete(id);
    if (result) await loadEntries();
    return result;
  }

  Future<void> searchEntries(String query) async {
    if (query.isEmpty) {
      await loadEntries();
      return;
    }
    _entries = await _repository.search(query);
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> getDeletedItems() async {
    return _repository.getDeletedItems();
  }

  Future<void> permanentlyDelete(String id) async {
    await _repository.permanentlyDelete(id);
  }

  Future<void> purgeExpiredItems() async {
    await _repository.purgeExpiredItems();
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    _titleSaveTimer?.cancel();
    super.dispose();
  }
}
