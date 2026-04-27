import '../day_signals.dart';
import '../pattern_insight.dart';
import '../user_baseline_profile.dart';
import 'pattern_analyzer_base.dart';

class FocusPatternAnalyzer extends PatternAnalyzerBase {
  @override
  List<PatternInsight> analyze(
    List<DaySignals> days,
    String analysisDate,
    int windowDays,
    UserBaselineProfile? baseline,
  ) {
    final insights = <PatternInsight>[];
    _noteFrequencyProductivity(days, insights, analysisDate, windowDays);
    _lateNotePattern(days, insights, analysisDate, windowDays);
    return insights;
  }

  void _noteFrequencyProductivity(
    List<DaySignals> days,
    List<PatternInsight> out,
    String analysisDate,
    int windowDays,
  ) {
    final paired = <CorrelationPair>[];
    for (final d in days) {
      if (d.hasNotes && d.hasEnergy) {
        paired.add(CorrelationPair(d.noteCount.toDouble(), d.avgEnergy));
      }
    }
    if (paired.length < 3) return;

    final corr = correlation(paired);
    if (corr.abs() <= 0.4) return;
    final conf = (corr.abs() * 0.8).clamp(0.0, 1.0);
    if (conf < 0.6) return;

    final direction = corr > 0 ? 'more' : 'fewer';
    final directionHu = corr > 0 ? 'több' : 'kevesebb';
    out.add(PatternInsight(
      id: 'v2_notes_productivity_${windowDays}d',
      titleEn: 'Note-taking linked to energy',
      titleHu: 'Jegyzetelés és energia összefüggése',
      descriptionEn:
          'Days with $direction notes tend to have higher energy over the last $windowDays days.',
      descriptionHu:
          'A $directionHu jegyzettel rendelkező napokon magasabb az energia az elmúlt $windowDays napban.',
      confidence: conf,
      correlationStrength: corr,
      relatedSignals: ['notes', 'energy'],
      domain: PatternDomain.focus,
      severity: PatternSeverity.gentle,
      analysisDate: analysisDate,
      dataPoints: paired.length,
      timeRangeDays: windowDays,
      actionSuggestionEn: 'Try capturing thoughts regularly to stay organized.',
      actionSuggestionHu: 'Próbáld rendszeresen rögzíteni a gondolataidat a szervezettség érdekében.',
    ));
  }

  void _lateNotePattern(
    List<DaySignals> days,
    List<PatternInsight> out,
    String analysisDate,
    int windowDays,
  ) {
    int totalNoteHours = 0;
    int lateNotes = 0;
    for (final d in days) {
      for (final hour in d.noteHours) {
        totalNoteHours++;
        if (hour >= 22 || hour < 5) lateNotes++;
      }
    }
    if (totalNoteHours < 5) return;

    final ratio = lateNotes / totalNoteHours;
    if (ratio <= 0.3) return;

    final conf = (ratio * 0.85).clamp(0.0, 1.0);
    if (conf < 0.6) return;

    out.add(PatternInsight(
      id: 'v2_late_notes_${windowDays}d',
      titleEn: 'Late-night note activity',
      titleHu: 'Késő éjszakai jegyzetelés',
      descriptionEn:
          '${(ratio * 100).round()}% of your notes are written after 22:00 over the last $windowDays days.',
      descriptionHu:
          'A jegyzeteid ${(ratio * 100).round()}%-a 22:00 után készül az elmúlt $windowDays napban.',
      confidence: conf,
      correlationStrength: 0,
      relatedSignals: ['notes', 'sleep'],
      domain: PatternDomain.focus,
      severity: PatternSeverity.gentle,
      analysisDate: analysisDate,
      dataPoints: totalNoteHours,
      timeRangeDays: windowDays,
      actionSuggestionEn: 'Consider capturing thoughts earlier to protect wind-down time.',
      actionSuggestionHu: 'Fontold meg, hogy korábban rögzítsd a gondolataidat a lenyugvási idő védelme érdekében.',
    ));
  }
}
