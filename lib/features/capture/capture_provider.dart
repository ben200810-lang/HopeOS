import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/id_generator.dart';
import '../../data/models/capture_entry.dart';
import '../../data/repositories/capture_repository.dart';

class CaptureProvider extends ChangeNotifier {
  final CaptureRepository _repository = CaptureRepository();

  List<CaptureEntry> _entries = [];
  List<CaptureEntry> _todayEntries = [];
  int _totalCount = 0;
  int _todayCount = 0;
  bool _isLoading = true;
  Timer? _autosaveTimer;
  CaptureEntry? _draftEntry;
  bool _draftSavedOnce = false;

  List<CaptureEntry> get entries => _entries;
  List<CaptureEntry> get todayEntries => _todayEntries;
  int get totalCount => _totalCount;
  int get todayCount => _todayCount;
  bool get isLoading => _isLoading;
  CaptureEntry? get draftEntry => _draftEntry;

  Future<void> loadEntries() async {
    _isLoading = true;
    notifyListeners();

    _entries = await _repository.getAll();
    _todayEntries = await _repository.getToday();
    _totalCount = await _repository.getTotalCount();
    _todayCount = await _repository.getTodayCount();

    _isLoading = false;
    notifyListeners();
  }

  Future<CaptureEntry> quickCapture({
    required CaptureType type,
    String? text,
    String? audioPath,
    String? imagePath,
    double? amount,
    String? category,
    int? moodLevel,
    int? energyLevel,
    Map<String, dynamic>? metadata,
  }) async {
    final now = DateTime.now();
    final entry = CaptureEntry(
      id: IdGenerator.generate(),
      type: type,
      text: text,
      audioPath: audioPath,
      imagePath: imagePath,
      amount: amount,
      category: category,
      moodLevel: moodLevel,
      energyLevel: energyLevel,
      metadata: metadata,
      createdAt: now,
      updatedAt: now,
    );
    await _repository.insert(entry);
    await loadEntries();
    return entry;
  }

  void startDraft(CaptureType type) {
    _autosaveTimer?.cancel();
    final now = DateTime.now();
    _draftEntry = CaptureEntry(
      id: IdGenerator.generate(),
      type: type,
      createdAt: now,
      updatedAt: now,
    );
    _draftSavedOnce = false;
    notifyListeners();
  }

  void updateDraft({
    String? text,
    String? imagePath,
    double? amount,
    String? category,
    int? moodLevel,
    int? energyLevel,
  }) {
    if (_draftEntry == null) return;
    _draftEntry = _draftEntry!.copyWith(
      text: text ?? _draftEntry!.text,
      imagePath: imagePath ?? _draftEntry!.imagePath,
      amount: amount ?? _draftEntry!.amount,
      category: category ?? _draftEntry!.category,
      moodLevel: moodLevel ?? _draftEntry!.moodLevel,
      energyLevel: energyLevel ?? _draftEntry!.energyLevel,
      updatedAt: DateTime.now(),
    );

    _autosaveTimer?.cancel();
    final draftId = _draftEntry!.id;
    _autosaveTimer = Timer(AppConstants.autosaveDelay, () async {
      if (_draftEntry != null && _draftEntry!.id == draftId) {
        await _saveDraft();
      }
    });

    notifyListeners();
  }

  Future<CaptureEntry?> saveDraftNow() async {
    _autosaveTimer?.cancel();
    return _saveDraft();
  }

  Future<CaptureEntry?> _saveDraft() async {
    if (_draftEntry == null) return null;
    final entry = _draftEntry!.copyWith(updatedAt: DateTime.now());
    if (_draftSavedOnce) {
      await _repository.update(entry);
    } else {
      await _repository.insert(entry);
      _draftSavedOnce = true;
    }
    await loadEntries();
    return entry;
  }

  Future<CaptureEntry?> finalizeDraft() async {
    _autosaveTimer?.cancel();
    final draftId = _draftEntry?.id;
    final saved = await _saveDraft();
    // Only clear if no new draft was started during the async gap
    if (_draftEntry?.id == draftId) {
      _draftEntry = null;
      _draftSavedOnce = false;
      notifyListeners();
    }
    return saved;
  }

  Future<void> discardDraft() async {
    _autosaveTimer?.cancel();
    if (_draftSavedOnce && _draftEntry != null) {
      await _repository.hardDelete(_draftEntry!.id);
    }
    _draftEntry = null;
    _draftSavedOnce = false;
    await loadEntries();
  }

  Future<void> updateEntry(CaptureEntry entry) async {
    await _repository.update(entry.copyWith(updatedAt: DateTime.now()));
    await loadEntries();
  }

  Future<void> toggleCompleted(String id) async {
    final entry = _entries.firstWhere((e) => e.id == id);
    await _repository.update(entry.copyWith(
      isCompleted: !entry.isCompleted,
      updatedAt: DateTime.now(),
    ));
    await loadEntries();
  }

  Future<String> deleteEntry(String id) async {
    await _repository.delete(id);
    await loadEntries();
    return id;
  }

  Future<bool> undoDelete(String id) async {
    final result = await _repository.undoDelete(id);
    if (result) await loadEntries();
    return result;
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
    super.dispose();
  }
}
