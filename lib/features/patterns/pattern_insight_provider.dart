import 'package:flutter/foundation.dart';
import 'pattern_insight.dart';
import 'pattern_engine_service.dart';

class PatternInsightProvider extends ChangeNotifier {
  final PatternEngineService _service = PatternEngineService();

  List<PatternInsight> _insights = [];
  bool _isLoading = false;
  bool _hasLoaded = false;

  List<PatternInsight> get insights => _insights;
  bool get isLoading => _isLoading;
  bool get hasInsights => _insights.isNotEmpty;

  Future<void> loadInsights({bool forceRefresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      _insights = await _service.getInsights(forceRefresh: forceRefresh);
      _hasLoaded = true;
    } catch (e) {
      debugPrint('Failed to load pattern insights: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshInsights() async {
    await loadInsights(forceRefresh: true);
  }

  Future<void> ensureLoaded() async {
    if (!_hasLoaded) {
      await loadInsights();
    }
  }
}
