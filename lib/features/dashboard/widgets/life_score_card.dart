import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:hopeos/l10n/app_localizations.dart';

class LifeScoreCard extends StatelessWidget {
  final double score;
  final String label;

  const LifeScoreCard({
    super.key,
    required this.score,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final clampedScore = score.clamp(0.0, 100.0);
    final color = _scoreColor(clampedScore);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.08),
            color.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: CustomPaint(
              painter: _ScoreArcPainter(
                progress: clampedScore / 100,
                color: color,
                backgroundColor:
                    theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
              child: Center(
                child: Text(
                  '${clampedScore.round()}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.lifeScore ?? 'Life Score',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n?.basedOnTodaysActivity ?? 'Based on today\'s activity',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _scoreColor(double score) {
    if (score >= 75) return const Color(0xFF4CAF50);
    if (score >= 50) return const Color(0xFFFFA726);
    if (score >= 25) return const Color(0xFFFF7043);
    return const Color(0xFFEF5350);
  }
}

String lifeScoreLabel(double score, [AppLocalizations? l10n]) {
  if (score >= 80) return l10n?.thriving ?? 'Thriving';
  if (score >= 60) return l10n?.doingWell ?? 'Doing well';
  if (score >= 40) return l10n?.gettingThere ?? 'Getting there';
  if (score >= 20) return l10n?.slowDay ?? 'Slow day — that\'s okay';
  return l10n?.startWithOneSmallStep ?? 'Start with one small step';
}

double calculateLifeScore({
  required int actionsCompleted,
  required int pendingActions,
  required double waterLiters,
  required double waterGoal,
  required double sleepHours,
  required double sleepGoal,
  required int exerciseMinutes,
  required int exerciseGoal,
  required double moodAverage,
  required bool hasMoodEntry,
}) {
  double score = 0;

  // Actions: 25 points max
  final totalActions = actionsCompleted + pendingActions;
  if (totalActions > 0) {
    score += (actionsCompleted / totalActions) * 25;
  } else {
    score += 5; // Small credit for a clean slate
  }

  // Hydration: 20 points max
  if (waterGoal > 0) {
    score += (waterLiters / waterGoal).clamp(0.0, 1.0) * 20;
  }

  // Sleep: 20 points max
  if (sleepGoal > 0 && sleepHours > 0) {
    score += (sleepHours / sleepGoal).clamp(0.0, 1.0) * 20;
  }

  // Exercise: 15 points max
  if (exerciseGoal > 0) {
    score += (exerciseMinutes / exerciseGoal).clamp(0.0, 1.0) * 15;
  }

  // Mood: 20 points max
  if (hasMoodEntry) {
    score += (moodAverage / 5.0).clamp(0.0, 1.0) * 20;
  }

  return score.clamp(0.0, 100.0);
}

class _ScoreArcPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _ScoreArcPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;
    const startAngle = -math.pi * 0.75;
    const sweepTotal = math.pi * 1.5;

    // Background arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepTotal,
      false,
      Paint()
        ..color = backgroundColor
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepTotal * progress,
      false,
      Paint()
        ..color = color
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ScoreArcPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
