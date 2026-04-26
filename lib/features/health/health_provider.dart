import 'package:flutter/material.dart';
import '../../core/utils/id_generator.dart';
import '../../data/models/health_entry.dart';
import '../../data/repositories/health_repository.dart';

class HealthProvider extends ChangeNotifier {
  final HealthRepository _repository = HealthRepository();

  HealthEntry? _todayEntry;
  List<HealthEntry> _weekEntries = [];
  bool _isLoading = true;

  HealthEntry? get todayEntry => _todayEntry;
  List<HealthEntry> get weekEntries => _weekEntries;
  bool get isLoading => _isLoading;

  double get waterLiters => _todayEntry?.waterLiters ?? 0;
  double get sleepHours => _todayEntry?.sleepHours ?? 0;
  int get exerciseMinutes => _todayEntry?.exerciseMinutes ?? 0;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    _todayEntry = await _repository.getToday();
    _weekEntries = await _repository.getRecent(7);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addWater(double liters) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entry = (_todayEntry ?? HealthEntry(
      id: IdGenerator.generate(),
      waterLiters: 0,
      date: today,
      updatedAt: now,
    )).copyWith(
      waterLiters: (_todayEntry?.waterLiters ?? 0) + liters,
      updatedAt: now,
    );
    await _repository.upsertToday(entry);
    await loadData();
  }

  Future<void> setSleep(double hours) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entry = (_todayEntry ?? HealthEntry(
      id: IdGenerator.generate(),
      waterLiters: 0,
      date: today,
      updatedAt: now,
    )).copyWith(
      sleepHours: hours,
      updatedAt: now,
    );
    await _repository.upsertToday(entry);
    await loadData();
  }

  Future<void> addExercise(int minutes) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entry = (_todayEntry ?? HealthEntry(
      id: IdGenerator.generate(),
      waterLiters: 0,
      date: today,
      updatedAt: now,
    )).copyWith(
      exerciseMinutes: (_todayEntry?.exerciseMinutes ?? 0) + minutes,
      updatedAt: now,
    );
    await _repository.upsertToday(entry);
    await loadData();
  }

  Future<void> resetWater() async {
    if (_todayEntry == null) return;
    final entry = _todayEntry!.copyWith(
      waterLiters: 0,
      updatedAt: DateTime.now(),
    );
    await _repository.upsertToday(entry);
    await loadData();
  }
}
