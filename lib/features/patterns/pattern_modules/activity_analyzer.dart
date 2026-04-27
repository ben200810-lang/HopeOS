import '../day_signals.dart';
import '../pattern_insight.dart';
import '../user_baseline_profile.dart';
import 'pattern_analyzer_base.dart';

class ActivityPatternAnalyzer extends PatternAnalyzerBase {
  @override
  List<PatternInsight> analyze(
    List<DaySignals> days,
    String analysisDate,
    int windowDays,
    UserBaselineProfile? baseline,
  ) {
    final insights = <PatternInsight>[];
    _stepsEnergyCorrelation(days, insights, analysisDate, windowDays);
    _stepsSleepCorrelation(days, insights, analysisDate, windowDays);
    _highActivityDays(days, insights, analysisDate, windowDays, baseline);
    return insights;
  }

  void _stepsEnergyCorrelation(
    List<DaySignals> days,
    List<PatternInsight> out,
    String analysisDate,
    int windowDays,
  ) {
    final paired = <CorrelationPair>[];
    for (final d in days) {
      if (d.steps > 0 && d.hasEnergy) {
        paired.add(CorrelationPair(d.steps.toDouble(), d.avgEnergy));
      }
    }
    if (paired.length < 3) return;

    final corr = correlation(paired);
    if (corr.abs() <= 0.4) return;
    final conf = (corr.abs() * 0.85).clamp(0.0, 1.0);
    if (conf < 0.6) return;

    out.add(PatternInsight(
      id: 'v2_steps_energy_${windowDays}d',
      titleEn: 'Activity boosts your energy',
      titleHu: 'A mozgás növeli az energiádat',
      descriptionEn:
          'More steps are associated with higher energy levels over the last $windowDays days.',
      descriptionHu:
          'A több lépés magasabb energiaszinttel jár az elmúlt $windowDays napban.',
      confidence: conf,
      correlationStrength: corr,
      relatedSignals: ['steps', 'energy'],
      domain: PatternDomain.activity,
      severity: PatternSeverity.notable,
      analysisDate: analysisDate,
      dataPoints: paired.length,
      timeRangeDays: windowDays,
      actionSuggestionEn: 'Try a short walk when energy feels low.',
      actionSuggestionHu: 'Próbálj meg egy rövid sétát tenni, ha alacsony az energiád.',
    ));
  }

  void _stepsSleepCorrelation(
    List<DaySignals> days,
    List<PatternInsight> out,
    String analysisDate,
    int windowDays,
  ) {
    final paired = <CorrelationPair>[];
    for (int i = 1; i < days.length; i++) {
      final prev = days[i - 1];
      final curr = days[i];
      if (prev.steps > 0 && curr.hasSleep) {
        paired.add(CorrelationPair(prev.steps.toDouble(), curr.sleepHours));
      }
    }
    if (paired.length < 3) return;

    final corr = correlation(paired);
    if (corr.abs() <= 0.4) return;
    final conf = (corr.abs() * 0.85).clamp(0.0, 1.0);
    if (conf < 0.6) return;

    final direction = corr > 0 ? 'more' : 'less';
    final directionHu = corr > 0 ? 'több' : 'kevesebb';
    out.add(PatternInsight(
      id: 'v2_steps_sleep_${windowDays}d',
      titleEn: 'Steps may affect your sleep',
      titleHu: 'A lépések befolyásolhatják az alvásod',
      descriptionEn:
          'Days with more steps tend to be followed by $direction sleep over the last $windowDays days.',
      descriptionHu:
          'A több lépéses napok után általában $directionHu alvás következik az elmúlt $windowDays napban.',
      confidence: conf,
      correlationStrength: corr,
      relatedSignals: ['steps', 'sleep'],
      domain: PatternDomain.activity,
      severity: PatternSeverity.gentle,
      analysisDate: analysisDate,
      dataPoints: paired.length,
      timeRangeDays: windowDays,
      actionSuggestionEn: 'Regular activity can help regulate your sleep cycle.',
      actionSuggestionHu: 'A rendszeres mozgás segíthet szabályozni az alvásciklusodat.',
    ));
  }

  void _highActivityDays(
    List<DaySignals> days,
    List<PatternInsight> out,
    String analysisDate,
    int windowDays,
    UserBaselineProfile? baseline,
  ) {
    final activeDays = days.where((d) => d.steps > 0).toList();
    if (activeDays.length < 3) return;

    final avgSteps =
        activeDays.map((d) => d.steps).reduce((a, b) => a + b) / activeDays.length;
    final baselineSteps = baseline?.averageSteps.toDouble() ?? 5000.0;

    if (avgSteps <= baselineSteps * 1.3) return;

    final pct = percentChange(avgSteps, baselineSteps).round();
    final conf = (pct / 100 * 0.8).clamp(0.0, 1.0);
    if (conf < 0.6) return;

    out.add(PatternInsight(
      id: 'v2_high_activity_${windowDays}d',
      titleEn: 'Activity above baseline',
      titleHu: 'Aktivitás az alapszint felett',
      descriptionEn:
          'Your average steps are $pct% above your baseline this period.',
      descriptionHu:
          'Az átlagos lépésszámod $pct%-kal az alapszinted felett van ebben az időszakban.',
      confidence: conf,
      correlationStrength: 0,
      relatedSignals: ['activity'],
      domain: PatternDomain.activity,
      severity: PatternSeverity.gentle,
      analysisDate: analysisDate,
      dataPoints: activeDays.length,
      timeRangeDays: windowDays,
      actionSuggestionEn: 'Great job staying active! Keep it up.',
      actionSuggestionHu: 'Szuper, hogy aktív vagy! Így tovább.',
    ));
  }
}
