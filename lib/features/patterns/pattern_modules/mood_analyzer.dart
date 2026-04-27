import '../day_signals.dart';
import '../pattern_insight.dart';
import '../user_baseline_profile.dart';
import 'pattern_analyzer_base.dart';

class MoodPatternAnalyzer extends PatternAnalyzerBase {
  @override
  List<PatternInsight> analyze(
    List<DaySignals> days,
    String analysisDate,
    int windowDays,
    UserBaselineProfile? baseline,
  ) {
    final insights = <PatternInsight>[];
    _activityMoodCorrelation(days, insights, analysisDate, windowDays);
    _hydrationMoodCorrelation(days, insights, analysisDate, windowDays);
    _moodTrend(days, insights, analysisDate, windowDays, baseline);
    return insights;
  }

  void _activityMoodCorrelation(
    List<DaySignals> days,
    List<PatternInsight> out,
    String analysisDate,
    int windowDays,
  ) {
    final paired = <CorrelationPair>[];
    for (final d in days) {
      if (d.steps > 0 && d.hasMood) {
        paired.add(CorrelationPair(d.steps.toDouble(), d.avgMood));
      }
    }
    if (paired.length < 3) return;

    final corr = correlation(paired);
    if (corr.abs() <= 0.4) return;
    final conf = (corr.abs() * 0.85).clamp(0.0, 1.0);
    if (conf < 0.6) return;

    final pct = (corr * 100).abs().round();
    out.add(PatternInsight(
      id: 'v2_activity_mood_${windowDays}d',
      titleEn: 'Better mood after walking',
      titleHu: 'Jobb hangulat séta után',
      descriptionEn:
          'You report $pct% better mood on days with more steps over the last $windowDays days.',
      descriptionHu:
          '$pct%-kal jobb hangulatról számolsz be a több lépéses napokon az elmúlt $windowDays napban.',
      confidence: conf,
      correlationStrength: corr,
      relatedSignals: ['activity', 'mood'],
      domain: PatternDomain.mood,
      severity: PatternSeverity.notable,
      analysisDate: analysisDate,
      dataPoints: paired.length,
      timeRangeDays: windowDays,
      actionSuggestionEn: 'A 20-minute walk may boost your mood.',
      actionSuggestionHu: 'Egy 20 perces séta javíthatja a hangulatodat.',
    ));
  }

  void _hydrationMoodCorrelation(
    List<DaySignals> days,
    List<PatternInsight> out,
    String analysisDate,
    int windowDays,
  ) {
    final paired = <CorrelationPair>[];
    for (final d in days) {
      if (d.hasHydration && d.hasMood) {
        paired.add(CorrelationPair(d.waterLiters, d.avgMood));
      }
    }
    if (paired.length < 3) return;

    final corr = correlation(paired);
    if (corr.abs() <= 0.4) return;
    final conf = (corr.abs() * 0.8).clamp(0.0, 1.0);
    if (conf < 0.6) return;

    out.add(PatternInsight(
      id: 'v2_hydration_mood_${windowDays}d',
      titleEn: 'Hydration linked to mood',
      titleHu: 'Folyadékbevitel és hangulat összefüggése',
      descriptionEn:
          'Better hydration is associated with higher mood scores over the last $windowDays days.',
      descriptionHu:
          'A jobb folyadékbevitel magasabb hangulati pontszámokkal jár az elmúlt $windowDays napban.',
      confidence: conf,
      correlationStrength: corr,
      relatedSignals: ['hydration', 'mood'],
      domain: PatternDomain.mood,
      severity: PatternSeverity.gentle,
      analysisDate: analysisDate,
      dataPoints: paired.length,
      timeRangeDays: windowDays,
      actionSuggestionEn: 'Try drinking water consistently through the day.',
      actionSuggestionHu: 'Próbálj egyenletesen inni a nap folyamán.',
    ));
  }

  void _moodTrend(
    List<DaySignals> days,
    List<PatternInsight> out,
    String analysisDate,
    int windowDays,
    UserBaselineProfile? baseline,
  ) {
    final moodDays = days.where((d) => d.hasMood).toList();
    if (moodDays.length < 3) return;

    final avgMood =
        moodDays.map((d) => d.avgMood).reduce((a, b) => a + b) / moodDays.length;
    final baselineMood = baseline?.averageMood ?? 3.0;
    final diff = avgMood - baselineMood;
    if (diff.abs() < 0.5) return;

    final dropping = diff < 0;
    final pct = percentChange(avgMood, baselineMood).abs().round();
    final conf = (diff.abs() / 5.0 * 1.5).clamp(0.0, 1.0);
    if (conf < 0.6) return;

    out.add(PatternInsight(
      id: 'v2_mood_trend_${windowDays}d',
      titleEn: dropping ? 'Mood trending lower' : 'Mood trending higher',
      titleHu: dropping ? 'A hangulat csökkenő tendenciát mutat' : 'A hangulat emelkedő tendenciát mutat',
      descriptionEn:
          'Your mood is $pct% ${dropping ? "below" : "above"} your baseline over the last $windowDays days.',
      descriptionHu:
          'A hangulatod $pct%-kal ${dropping ? "az alapszinted alatt" : "az alapszinted felett"} van az elmúlt $windowDays napban.',
      confidence: conf,
      correlationStrength: 0,
      relatedSignals: ['mood'],
      domain: PatternDomain.mood,
      severity: dropping ? PatternSeverity.notable : PatternSeverity.gentle,
      analysisDate: analysisDate,
      dataPoints: moodDays.length,
      timeRangeDays: windowDays,
      actionSuggestionEn: dropping
          ? 'Consider what changed recently and be gentle with yourself.'
          : 'Keep doing what you\'re doing — your mood is up!',
      actionSuggestionHu: dropping
          ? 'Gondolkodj el, mi változott mostanában, és légy kedves magaddal.'
          : 'Folytasd, amit csinálsz — a hangulatod emelkedik!',
    ));
  }
}
