import '../day_signals.dart';
import '../pattern_insight.dart';
import '../user_baseline_profile.dart';
import 'pattern_analyzer_base.dart';

class HydrationPatternAnalyzer extends PatternAnalyzerBase {
  @override
  List<PatternInsight> analyze(
    List<DaySignals> days,
    String analysisDate,
    int windowDays,
    UserBaselineProfile? baseline,
  ) {
    final insights = <PatternInsight>[];
    _hydrationEnergyCorrelation(days, insights, analysisDate, windowDays);
    _lowHydrationPattern(days, insights, analysisDate, windowDays, baseline);
    return insights;
  }

  void _hydrationEnergyCorrelation(
    List<DaySignals> days,
    List<PatternInsight> out,
    String analysisDate,
    int windowDays,
  ) {
    final paired = <CorrelationPair>[];
    for (final d in days) {
      if (d.hasHydration && d.hasEnergy) {
        paired.add(CorrelationPair(d.waterLiters, d.avgEnergy));
      }
    }
    if (paired.length < 3) return;

    final corr = correlation(paired);
    if (corr.abs() <= 0.4) return;
    final conf = (corr.abs() * 0.85).clamp(0.0, 1.0);
    if (conf < 0.6) return;

    out.add(PatternInsight(
      id: 'v2_hydration_energy_${windowDays}d',
      titleEn: 'Hydration may affect your energy',
      titleHu: 'A folyadékbevitel befolyásolhatja az energiádat',
      descriptionEn:
          'Days with better hydration show higher energy levels over the last $windowDays days.',
      descriptionHu:
          'A jobb folyadékbevitelű napok magasabb energiaszintet mutatnak az elmúlt $windowDays napban.',
      confidence: conf,
      correlationStrength: corr,
      relatedSignals: ['hydration', 'energy'],
      domain: PatternDomain.hydration,
      severity: PatternSeverity.notable,
      analysisDate: analysisDate,
      dataPoints: paired.length,
      timeRangeDays: windowDays,
      actionSuggestionEn: 'Try to reach your daily hydration goal consistently.',
      actionSuggestionHu: 'Próbáld rendszeresen elérni a napi folyadékbeviteli célodat.',
    ));
  }

  void _lowHydrationPattern(
    List<DaySignals> days,
    List<PatternInsight> out,
    String analysisDate,
    int windowDays,
    UserBaselineProfile? baseline,
  ) {
    final hydDays = days.where((d) => d.hasHydration).toList();
    if (hydDays.length < 3) return;

    final avgHyd =
        hydDays.map((d) => d.waterLiters).reduce((a, b) => a + b) / hydDays.length;
    final threshold = baseline?.averageHydration ?? 2.0;
    if (avgHyd >= threshold) return;

    final deficit = threshold - avgHyd;
    final conf = (deficit / threshold * 1.5).clamp(0.0, 1.0);
    if (conf < 0.6) return;

    out.add(PatternInsight(
      id: 'v2_low_hydration_${windowDays}d',
      titleEn: 'Hydration below your baseline',
      titleHu: 'Folyadékbevitel az alapszinted alatt',
      descriptionEn:
          'Your average hydration is ${avgHyd.toStringAsFixed(1)}L, ${deficit.toStringAsFixed(1)}L below your baseline.',
      descriptionHu:
          'Az átlagos folyadékbeviteled ${avgHyd.toStringAsFixed(1)}L, ${deficit.toStringAsFixed(1)}L-rel az alapszinted alatt.',
      confidence: conf,
      correlationStrength: 0,
      relatedSignals: ['hydration'],
      domain: PatternDomain.hydration,
      severity: PatternSeverity.notable,
      analysisDate: analysisDate,
      dataPoints: hydDays.length,
      timeRangeDays: windowDays,
      actionSuggestionEn: 'Set reminders to drink water throughout the day.',
      actionSuggestionHu: 'Állíts be emlékeztetőket, hogy igyál vizet a nap folyamán.',
    ));
  }
}
