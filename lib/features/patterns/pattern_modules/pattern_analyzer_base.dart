import 'dart:math' as math;

import '../day_signals.dart';
import '../pattern_insight.dart';
import '../user_baseline_profile.dart';

/// Base class for all pattern analyzer modules.
abstract class PatternAnalyzerBase {
  List<PatternInsight> analyze(
    List<DaySignals> days,
    String analysisDate,
    int windowDays,
    UserBaselineProfile? baseline,
  );

  /// Pearson correlation coefficient for a list of (x, y) pairs.
  double correlation(List<CorrelationPair> pairs) {
    if (pairs.length < 3) return 0;
    final n = pairs.length;
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0, sumY2 = 0;
    for (final p in pairs) {
      sumX += p.x;
      sumY += p.y;
      sumXY += p.x * p.y;
      sumX2 += p.x * p.x;
      sumY2 += p.y * p.y;
    }
    final num = n * sumXY - sumX * sumY;
    final den =
        math.sqrt((n * sumX2 - sumX * sumX) * (n * sumY2 - sumY * sumY));
    if (den == 0) return 0;
    return (num / den).clamp(-1.0, 1.0);
  }

  /// Simple rolling average for the last [window] values.
  double rollingAverage(List<double> values, int window) {
    if (values.isEmpty) return 0;
    final slice = values.length > window
        ? values.sublist(values.length - window)
        : values;
    return slice.reduce((a, b) => a + b) / slice.length;
  }

  /// Percentage change from baseline.
  double percentChange(double current, double baseline) {
    if (baseline == 0) return 0;
    return ((current - baseline) / baseline) * 100;
  }
}
