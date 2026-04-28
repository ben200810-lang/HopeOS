import 'package:flutter/material.dart';
import '../../core/services/sleep_estimation_service.dart';
import '../../core/utils/id_generator.dart';
import '../../data/models/health_entry.dart';
import '../../data/repositories/health_repository.dart';

class HealthProvider extends ChangeNotifier {
  final HealthRepository _repository = HealthRepository();
  final SleepEstimationService _sleepEstimation = SleepEstimationService();

  HealthEntry? _todayEntry;
  List<HealthEntry> _weekEntries = [];
  bool _isLoading = true;
  SleepEstimate? _sleepEstimate;
  bool _sleepIsManual = false;

  HealthEntry? get todayEntry => _todayEntry;
  List<HealthEntry> get weekEntries => _weekEntries;
  bool get isLoading => _isLoading;
  SleepEstimate? get sleepEstimate => _sleepEstimate;
  bool get sleepIsManual => _sleepIsManual;

  double get waterLiters => _todayEntry?.waterLiters ?? 0;
  double get sleepHours => _todayEntry?.sleepHours ?? 0;
  int get exerciseMinutes => _todayEntry?.exerciseMinutes ?? 0;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    _todayEntry = await _repository.getToday();
    _weekEntries = await _repository.getRecent(7);
    _sleepIsManual = _todayEntry?.note == 'manual';

    _isLoading = false;
    notifyListeners();
  }

  Future<void> estimateSleep() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    try {
      final estimate = await _sleepEstimation.estimateSleep(today);
      _sleepEstimate = estimate;

      if (estimate != null && !_sleepIsManual) {
        final entry = (_todayEntry ?? HealthEntry(
          id: IdGenerator.generate(),
          waterLiters: 0,
          date: today,
          updatedAt: now,
        )).copyWith(
          sleepHours: estimate.hours,
          note: _buildSleepNote(estimate),
          updatedAt: now,
        );
        await _repository.upsertToday(entry);
        await loadData();
      } else {
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Sleep estimation failed: $e');
      notifyListeners();
    }
  }

  Future<void> setSleep(double hours) async {
    _sleepIsManual = true;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entry = (_todayEntry ?? HealthEntry(
      id: IdGenerator.generate(),
      waterLiters: 0,
      date: today,
      updatedAt: now,
    )).copyWith(
      sleepHours: hours,
      note: 'manual',
      updatedAt: now,
    );
    await _repository.upsertToday(entry);
    await loadData();
  }

  Future<void> useEstimatedSleep() async {
    if (_sleepEstimate == null) return;
    _sleepIsManual = false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entry = (_todayEntry ?? HealthEntry(
      id: IdGenerator.generate(),
      waterLiters: 0,
      date: today,
      updatedAt: now,
    )).copyWith(
      sleepHours: _sleepEstimate!.hours,
      note: _buildSleepNote(_sleepEstimate!),
      updatedAt: now,
    );
    await _repository.upsertToday(entry);
    await loadData();
  }

  String _buildSleepNote(SleepEstimate estimate) {
    final sources = estimate.dataSources.join('+');
    return 'estimated:$sources:${estimate.confidence.name}';
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
