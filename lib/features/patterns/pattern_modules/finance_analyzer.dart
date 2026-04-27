import '../day_signals.dart';
import '../pattern_insight.dart';
import '../user_baseline_profile.dart';
import 'pattern_analyzer_base.dart';

class FinancePatternAnalyzer extends PatternAnalyzerBase {
  @override
  List<PatternInsight> analyze(
    List<DaySignals> days,
    String analysisDate,
    int windowDays,
    UserBaselineProfile? baseline,
  ) {
    final insights = <PatternInsight>[];
    _spendingMoodCorrelation(days, insights, analysisDate, windowDays);
    _spendingClusters(days, insights, analysisDate, windowDays);
    return insights;
  }

  void _spendingMoodCorrelation(
    List<DaySignals> days,
    List<PatternInsight> out,
    String analysisDate,
    int windowDays,
  ) {
    final paired = <CorrelationPair>[];
    for (final d in days) {
      if (d.hasFinance && d.hasMood) {
        paired.add(CorrelationPair(d.totalExpenses, d.avgMood));
      }
    }
    if (paired.length < 3) return;

    final corr = correlation(paired);
    if (corr.abs() <= 0.4) return;
    final conf = (corr.abs() * 0.75).clamp(0.0, 1.0);
    if (conf < 0.6) return;

    final direction = corr < 0 ? 'lower' : 'higher';
    final directionHu = corr < 0 ? 'alacsonyabb' : 'magasabb';
    out.add(PatternInsight(
      id: 'v2_spending_mood_${windowDays}d',
      titleEn: 'Spending linked to mood',
      titleHu: 'Kiadások és hangulat összefüggése',
      descriptionEn:
          'Higher spending days are associated with $direction mood over the last $windowDays days.',
      descriptionHu:
          'A magasabb kiadású napok $directionHu hangulattal járnak az elmúlt $windowDays napban.',
      confidence: conf,
      correlationStrength: corr,
      relatedSignals: ['finance', 'mood'],
      domain: PatternDomain.finance,
      severity: PatternSeverity.notable,
      analysisDate: analysisDate,
      dataPoints: paired.length,
      timeRangeDays: windowDays,
      actionSuggestionEn: 'Consider a brief pause before unplanned purchases.',
      actionSuggestionHu: 'Fontold meg egy rövid szünetet a nem tervezett vásárlások előtt.',
    ));
  }

  void _spendingClusters(
    List<DaySignals> days,
    List<PatternInsight> out,
    String analysisDate,
    int windowDays,
  ) {
    final spendingDays = days.where((d) => d.expenseCount >= 3).toList();
    if (spendingDays.length < 2) return;

    final totalDaysWithExpenses = days.where((d) => d.hasFinance).length;
    if (totalDaysWithExpenses < 3) return;

    final ratio = spendingDays.length / totalDaysWithExpenses;
    final conf = (ratio * 0.8).clamp(0.0, 1.0);
    if (conf < 0.6) return;

    out.add(PatternInsight(
      id: 'v2_spending_clusters_${windowDays}d',
      titleEn: 'Spending clusters detected',
      titleHu: 'Kiadási csoportosulások észlelve',
      descriptionEn:
          '${spendingDays.length} days with 3+ expenses in the last $windowDays days.',
      descriptionHu:
          '${spendingDays.length} nap 3+ kiadással az elmúlt $windowDays napban.',
      confidence: conf,
      correlationStrength: 0,
      relatedSignals: ['finance'],
      domain: PatternDomain.finance,
      severity: PatternSeverity.notable,
      analysisDate: analysisDate,
      dataPoints: spendingDays.length,
      timeRangeDays: windowDays,
      actionSuggestionEn: 'Try setting a daily spending limit.',
      actionSuggestionHu: 'Próbálj napi költési limitet beállítani.',
    ));
  }
}
