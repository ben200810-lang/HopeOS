import 'package:flutter/material.dart';
import '../../core/utils/id_generator.dart';
import '../../data/models/mood_entry.dart';
import '../../data/repositories/mood_repository.dart';

class MentalProvider extends ChangeNotifier {
  final MoodRepository _repository = MoodRepository();

  List<MoodEntry> _todayEntries = [];
  List<MoodEntry> _recentEntries = [];
  MoodEntry? _latestEntry;
  double _weeklyAverage = 0;
  bool _isLoading = true;

  List<MoodEntry> get todayEntries => _todayEntries;
  List<MoodEntry> get recentEntries => _recentEntries;
  MoodEntry? get latestEntry => _latestEntry;
  double get weeklyAverage => _weeklyAverage;
  bool get isLoading => _isLoading;

  Future<void> loadEntries() async {
    _isLoading = true;
    notifyListeners();

    _todayEntries = await _repository.getToday();
    _recentEntries = await _repository.getAll();
    _latestEntry = await _repository.getLatest();
    _weeklyAverage = await _repository.getAverageMood(7);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logMood({
    required int moodLevel,
    required int energyLevel,
    String? note,
    List<String> tags = const [],
  }) async {
    final entry = MoodEntry(
      id: IdGenerator.generate(),
      moodLevel: moodLevel,
      energyLevel: energyLevel,
      note: note,
      tags: tags,
      createdAt: DateTime.now(),
    );
    await _repository.insert(entry);
    await loadEntries();
  }

  Future<void> updateEntry(MoodEntry entry) async {
    await _repository.update(entry);
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
}
