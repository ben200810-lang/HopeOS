import '../day_signals.dart';
import '../pattern_insight.dart';
import '../user_baseline_profile.dart';
import 'pattern_analyzer_base.dart';

class SleepPatternAnalyzer extends PatternAnalyzerBase {
  @override
  List<PatternInsight> analyze(
    List<DaySignals> days,
    String analysisDate,
    int windowDays,
    UserBaselineProfile? baseline,
  ) {
    final insights = <PatternInsight>[];
    _sleepMoodCorrelation(days, insights, analysisDate, windowDays);
    _sleepEnergyCorrelation(days, insights, analysisDate, windowDays);
    _lowSleepPattern(days, insights, analysisDate, windowDays, baseline);
    return insights;
  }

  void _sleepMoodCorrelation(
    List<DaySignals> days,
    List<PatternInsight> out,
    String analysisDate,
    int windowDays,
  ) {
    final paired = <CorrelationPair>[];
    for (final d in days) {
      if (d.hasSleep && d.hasMood) {
        paired.add(CorrelationPair(d.sleepHours, d.avgMood));
      }
    }
    if (paired.length < 3) return;

    final corr = correlation(paired);
    if (corr.abs() <= 0.4) return;
    final conf = (corr.abs() * 0.9).clamp(0.0, 1.0);
    if (conf < 0.6) return;

    final pct = (corr * 100).abs().round();
    out.add(PatternInsight(
      id: 'v2_sleep_mood_${windowDays}d',
      titleEn: 'Better mood on well-rested days',
      titleHu: 'Jobb hangulat kipihent napokon',
      descriptionEn:
          'When you sleep more, your mood tends to be $pct% better over the last $windowDays days.',
      descriptionHu:
          'Ha többet alszol, a hangulatod átlagosan $pct%-kal jobb az elmúlt $windowDays napban.',
      confidence: conf,
      correlationStrength: corr,
      relatedSignals: ['sleep', 'mood'],
      domain: PatternDomain.sleep,
      severity: PatternSeverity.notable,
      analysisDate: analysisDate,
      dataPoints: paired.length,
      timeRangeDays: windowDays,
      actionSuggestionEn: 'Try protecting sleep consistency.',
      actionSuggestionHu: 'Próbáld megőrizni az alvás rendszerességét.',
    ));
  }

  void _sleepEnergyCorrelation(
    List<DaySignals> days,
    List<PatternInsight> out,
    String analysisDate,
    int windowDays,
  ) {
    final paired = <CorrelationPair>[];
    for (final d in days) {
      if (d.hasSleep && d.hasEnergy) {
        paired.add(CorrelationPair(d.sleepHours, d.avgEnergy));
      }
    }
    if (paired.length < 3) return;

    final corr = correlation(paired);
    if (corr.abs() <= 0.4) return;
    final conf = (corr.abs() * 0.85).clamp(0.0, 1.0);
    if (conf < 0.6) return;

    out.add(PatternInsight(
      id: 'v2_sleep_energy_${windowDays}d',
      titleEn: 'Sleep affects your energy',
      titleHu: 'Az alvás befolyásolja az energiádat',
      descriptionEn:
          'Your energy levels correlate with sleep quality over the last $windowDays days.',
      descriptionHu:
          'Az energiaszinted összefügg az alvásminőségeddel az elmúlt $windowDays napban.',
      confidence: conf,
      correlationStrength: corr,
      relatedSignals: ['sleep', 'energy'],
      domain: PatternDomain.sleep,
      severity: PatternSeverity.notable,
      analysisDate: analysisDate,
      dataPoints: paired.length,
      timeRangeDays: windowDays,
      actionSuggestionEn: 'Aim for consistent bedtime to stabilize energy.',
      actionSuggestionHu: 'Célozd meg a rendszeres lefekvést az energia stabilizálásához.',
    ));
  }

  void _lowSleepPattern(
    List<DaySignals> days,
    List<PatternInsight> out,
    String analysisDate,
    int windowDays,
    UserBaselineProfile? baseline,
  ) {
    final sleepDays = days.where((d) => d.hasSleep).toList();
    if (sleepDays.length < 3) return;

    final avgSleep =
        sleepDays.map((d) => d.sleepHours).reduce((a, b) => a + b) / sleepDays.length;
    final threshold = baseline?.averageSleep ?? 7.0;
    if (avgSleep >= threshold) return;

    final deficit = threshold - avgSleep;
    final conf = (deficit / threshold * 1.5).clamp(0.0, 1.0);
    if (conf < 0.6) return;

    out.add(PatternInsight(
      id: 'v2_low_sleep_${windowDays}d',
      titleEn: 'Sleep below your baseline',
      titleHu: 'Alvás az alapszinted alatt',
      descriptionEn:
          'Your average sleep is ${avgSleep.toStringAsFixed(1)}h, ${deficit.toStringAsFixed(1)}h below your baseline.',
      descriptionHu:
          'Az átlagos alvásod ${avgSleep.toStringAsFixed(1)} óra, ${deficit.toStringAsFixed(1)} órával az alapszinted alatt.',
      confidence: conf,
      correlationStrength: 0,
      relatedSignals: ['sleep'],
      domain: PatternDomain.sleep,
      severity: PatternSeverity.notable,
      analysisDate: analysisDate,
      dataPoints: sleepDays.length,
      timeRangeDays: windowDays,
      actionSuggestionEn: 'Try going to bed 30 minutes earlier this week.',
      actionSuggestionHu: 'Próbálj 30 perccel korábban lefeküdni ezen a héten.',
    ));
  }
}
