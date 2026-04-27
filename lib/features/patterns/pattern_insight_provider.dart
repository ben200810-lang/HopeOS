import 'package:flutter/foundation.dart';
import 'pattern_insight.dart';
import 'pattern_engine_v2.dart';

class PatternInsightProvider extends ChangeNotifier {
  final PatternEngineV2 _engine = PatternEngineV2();

  List<PatternInsight> _insights = [];
  List<String> _behavioralChanges = [];
  bool _isLoading = false;
  bool _hasLoaded = false;

  List<PatternInsight> get insights => _insights;
  List<String> get behavioralChanges => _behavioralChanges;
  bool get isLoading => _isLoading;
  bool get hasInsights => _insights.isNotEmpty;

  Future<void> loadInsights({bool forceRefresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      _insights = await _engine.getInsights(forceRefresh: forceRefresh);
      _behavioralChanges = await _engine.detectBehavioralChanges();
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

  Future<void> recordAppOpen() async {
    await _engine.recordAppOpen();
  }
}
