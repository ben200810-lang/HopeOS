import 'package:flutter/material.dart';

import '../../data/models/timeline_event.dart';
import '../../data/repositories/timeline_repository.dart';

class TimelineProvider extends ChangeNotifier {
  final TimelineRepository _repository = TimelineRepository();

  List<TimelineEvent> _allEvents = [];
  List<TimelineEvent> _filteredEvents = [];
  TimelineFilter _activeFilter = TimelineFilter.all;
  bool _isLoading = true;
  String _searchQuery = '';

  List<TimelineEvent> get events => _filteredEvents;
  List<TimelineEvent> get allEvents => _allEvents;
  TimelineFilter get activeFilter => _activeFilter;
  bool get isLoading => _isLoading;
  int get totalCount => _allEvents.length;
  String get searchQuery => _searchQuery;

  int get todayCount {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return _allEvents.where((e) => e.timestamp.isAfter(startOfDay)).length;
  }

  Future<void> loadAll({String currencySymbol = '\$'}) async {
    _isLoading = true;
    notifyListeners();

    _allEvents = await _repository.getAll(currencySymbol: currencySymbol);
    _applyFilters();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadToday({String currencySymbol = '\$'}) async {
    _isLoading = true;
    notifyListeners();

    _allEvents = await _repository.getToday(currencySymbol: currencySymbol);
    _applyFilters();

    _isLoading = false;
    notifyListeners();
  }

  void setFilter(TimelineFilter filter) {
    _activeFilter = filter;
    _applyFilters();
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    var result = _allEvents.where((e) => e.matchesFilter(_activeFilter));

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((e) =>
          e.title.toLowerCase().contains(query) ||
          (e.subtitle?.toLowerCase().contains(query) ?? false));
    }

    _filteredEvents = result.toList();
  }
}
