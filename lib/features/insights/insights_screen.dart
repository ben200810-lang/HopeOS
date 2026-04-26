import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/hope_card.dart';
import '../../core/widgets/progress_ring.dart';
import '../../data/models/capture_entry.dart';
import '../mental/mental_provider.dart';
import '../health/health_provider.dart';
import '../actions/action_provider.dart';
import '../journal/journal_provider.dart';
import '../capture/capture_provider.dart';
import '../settings/settings_provider.dart';
import '../timeline/timeline_provider.dart';
import '../patterns/pattern_engine.dart';
import '../patterns/pattern_insights_card.dart';
import '../patterns/pattern_insight_provider.dart';
import '../patterns/pattern_insight_card.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      context.read<MentalProvider>().loadEntries(),
      context.read<HealthProvider>().loadData(),
      context.read<ActionProvider>().loadActions(),
      context.read<JournalProvider>().loadEntries(),
      context.read<CaptureProvider>().loadEntries(),
    ]);
    if (mounted) {
      context.read<PatternInsightProvider>().loadInsights();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mental = context.watch<MentalProvider>();
    final health = context.watch<HealthProvider>();
    final actions = context.watch<ActionProvider>();
    final journal = context.watch<JournalProvider>();
    final capture = context.watch<CaptureProvider>();
    final settings = context.watch<SettingsProvider>();

    // Build data for graphs
    final hydrationData = _buildHydrationData(health);
    final activityData = _buildActivityData(health);
    final moodData = _buildMoodData(mental);
    final sleepData = _buildSleepData(health);
    final financeData = _buildFinanceData(capture);

    return RefreshIndicator(
      onRefresh: _loadData,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          const SliverAppBar(
            floating: true,
            title: Text('Insights'),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),

                // Overview cards
                _OverviewRow(
                  actionsCompleted: actions.todayCompleted,
                  pendingActions: actions.pendingActions.length,
                  journalEntries: journal.totalCount,
                  moodAverage: mental.weeklyAverage,
                ),

                const SizedBox(height: 24),

                // Today's Goals
                Text('Today\'s Goals',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _GoalsCard(
                  waterCurrent: health.waterLiters,
                  waterGoal: settings.waterGoal,
                  sleepCurrent: health.sleepHours,
                  sleepGoal: settings.sleepGoal,
                  exerciseCurrent: health.exerciseMinutes,
                  exerciseGoal: settings.exerciseGoal,
                ),

                const SizedBox(height: 24),

                // ── Hydration Trend ──
                _SectionTitle(
                  icon: Icons.water_drop,
                  label: 'Hydration Trend',
                  color: const Color(0xFF42A5F5),
                ),
                const SizedBox(height: 8),
                _TrendGraph(
                  data: hydrationData,
                  color: const Color(0xFF42A5F5),
                  fillColor: const Color(0xFF42A5F5),
                  unit: 'L',
                  emptyMessage: 'Log water to see your hydration trend',
                ),

                const SizedBox(height: 24),

                // ── Activity Trend ──
                _SectionTitle(
                  icon: Icons.directions_run,
                  label: 'Activity Trend',
                  color: const Color(0xFF66BB6A),
                ),
                const SizedBox(height: 8),
                _TrendGraph(
                  data: activityData,
                  color: const Color(0xFF66BB6A),
                  fillColor: const Color(0xFF66BB6A),
                  unit: 'min',
                  emptyMessage: 'Log exercise to see your activity trend',
                ),

                const SizedBox(height: 24),

                // ── Mood Trend ──
                _SectionTitle(
                  icon: Icons.mood,
                  label: 'Mood Trend',
                  color: const Color(0xFFAB47BC),
                ),
                const SizedBox(height: 8),
                _TrendGraph(
                  data: moodData,
                  color: const Color(0xFFAB47BC),
                  fillColor: const Color(0xFFAB47BC),
                  unit: '/5',
                  maxValue: 5,
                  emptyMessage: 'Log your mood to see emotional trends',
                ),

                const SizedBox(height: 24),

                // ── Sleep Trend ──
                _SectionTitle(
                  icon: Icons.bedtime,
                  label: 'Sleep Trend',
                  color: const Color(0xFF5C6BC0),
                ),
                const SizedBox(height: 8),
                _TrendGraph(
                  data: sleepData,
                  color: const Color(0xFF5C6BC0),
                  fillColor: const Color(0xFF5C6BC0),
                  unit: 'h',
                  emptyMessage: 'Log sleep to see your rest patterns',
                ),

                const SizedBox(height: 24),

                // ── Financial Balance ──
                _SectionTitle(
                  icon: Icons.account_balance_wallet,
                  label: 'Spending (7 days)',
                  color: const Color(0xFFEF5350),
                ),
                const SizedBox(height: 8),
                _FinanceCard(data: financeData),

                const SizedBox(height: 24),

                // ── Pattern Engine v2 Insights ──
                Text('Pattern Insights',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Builder(
                  builder: (context) {
                    final patternProvider = context.watch<PatternInsightProvider>();
                    return PatternInsightCards(
                      insights: patternProvider.insights,
                      locale: settings.language,
                      isLoading: patternProvider.isLoading,
                    );
                  },
                ),

                const SizedBox(height: 24),

                // ── Legacy Pattern Insights (v1) ──
                Builder(
                  builder: (context) {
                    final timeline = context.watch<TimelineProvider>();
                    final engine = PatternEngine();
                    final patterns = engine.analyze(timeline.allEvents);
                    if (patterns.isEmpty) return const SizedBox.shrink();
                    return PatternInsightsCard(
                      patterns: patterns,
                      locale: settings.language,
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Energy distribution
                if (mental.todayEntries.isNotEmpty) ...[
                  _SectionTitle(
                    icon: Icons.bolt,
                    label: 'Energy Today',
                    color: Colors.amber,
                  ),
                  const SizedBox(height: 8),
                  _EnergyDistribution(entries: mental.todayEntries),
                ],

                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Data Builders ──

  List<_DataPoint> _buildHydrationData(HealthProvider health) {
    final points = <_DataPoint>[];
    for (final entry in health.weekEntries.reversed) {
      final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      points.add(_DataPoint(
        label: dayNames[entry.date.weekday - 1],
        value: entry.waterLiters,
      ));
    }
    return points;
  }

  List<_DataPoint> _buildActivityData(HealthProvider health) {
    final points = <_DataPoint>[];
    for (final entry in health.weekEntries.reversed) {
      final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      points.add(_DataPoint(
        label: dayNames[entry.date.weekday - 1],
        value: (entry.exerciseMinutes ?? 0).toDouble(),
      ));
    }
    return points;
  }

  List<_DataPoint> _buildMoodData(MentalProvider mental) {
    final points = <_DataPoint>[];
    final entries = mental.recentEntries.take(7).toList().reversed.toList();
    for (int i = 0; i < entries.length; i++) {
      points.add(_DataPoint(
        label: '${i + 1}',
        value: entries[i].moodLevel.toDouble(),
      ));
    }
    return points;
  }

  List<_DataPoint> _buildSleepData(HealthProvider health) {
    final points = <_DataPoint>[];
    for (final entry in health.weekEntries.reversed) {
      final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      points.add(_DataPoint(
        label: dayNames[entry.date.weekday - 1],
        value: entry.sleepHours ?? 0,
      ));
    }
    return points;
  }

  List<_FinancePoint> _buildFinanceData(CaptureProvider capture) {
    final expenses = capture.entries
        .where((e) => e.type == CaptureType.expense && e.amount != null)
        .toList();

    // Group by day for last 7 days
    final now = DateTime.now();
    final points = <_FinancePoint>[];
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    for (int i = 6; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day - i);
      final dayExpenses = expenses
          .where((e) =>
              e.createdAt.year == day.year &&
              e.createdAt.month == day.month &&
              e.createdAt.day == day.day)
          .fold<double>(0, (sum, e) => sum + (e.amount ?? 0));

      points.add(_FinancePoint(
        label: dayNames[day.weekday - 1],
        amount: dayExpenses,
      ));
    }
    return points;
  }
}

// ── Data Classes ──

class _DataPoint {
  final String label;
  final double value;

  _DataPoint({required this.label, required this.value});
}

class _FinancePoint {
  final String label;
  final double amount;

  _FinancePoint({required this.label, required this.amount});
}

// ── Section Title ──

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SectionTitle({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ── Trend Graph (used for hydration, activity, mood, sleep) ──

class _TrendGraph extends StatelessWidget {
  final List<_DataPoint> data;
  final Color color;
  final Color fillColor;
  final String unit;
  final double? maxValue;
  final String emptyMessage;

  const _TrendGraph({
    required this.data,
    required this.color,
    required this.fillColor,
    required this.unit,
    this.maxValue,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (data.isEmpty) {
      return HopeCard(
        child: SizedBox(
          height: 120,
          child: Center(
            child: Text(emptyMessage,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
        ),
      );
    }

    return HopeCard(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      child: Column(
        children: [
          SizedBox(
            height: 140,
            child: CustomPaint(
              size: const Size(double.infinity, 140),
              painter: _CalmTrendPainter(
                data: data,
                lineColor: color,
                fillColor: fillColor,
                maxValue: maxValue,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: data
                .map((p) => Expanded(
                      child: Text(
                        p.label,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 10,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: data
                .map((p) => Expanded(
                      child: Text(
                        p.value > 0
                            ? '${p.value % 1 == 0 ? p.value.toInt() : p.value.toStringAsFixed(1)}$unit'
                            : '—',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                          fontSize: 9,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _CalmTrendPainter extends CustomPainter {
  final List<_DataPoint> data;
  final Color lineColor;
  final Color fillColor;
  final double? maxValue;

  _CalmTrendPainter({
    required this.data,
    required this.lineColor,
    required this.fillColor,
    this.maxValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final max = maxValue ??
        data.fold<double>(0, (m, d) => d.value > m ? d.value : m) * 1.2;
    if (max == 0) return;

    // Subtle horizontal grid lines
    final gridPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.08)
      ..strokeWidth = 0.5;

    for (int i = 1; i <= 4; i++) {
      final y = size.height - (i / 4 * size.height);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (data.length == 1) {
      final y = size.height - (data.first.value / max * size.height);
      canvas.drawCircle(
        Offset(size.width / 2, y.clamp(4, size.height - 4)),
        6,
        Paint()..color = lineColor.withValues(alpha: 0.7),
      );
      return;
    }

    final spacing = size.width / (data.length - 1);

    // Build smooth path
    final path = Path();
    final fillPath = Path();
    final points = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final x = i * spacing;
      final rawY = size.height - (data[i].value / max * size.height);
      final y = rawY.clamp(4.0, size.height - 4);
      points.add(Offset(x, y));
    }

    path.moveTo(points[0].dx, points[0].dy);
    fillPath.moveTo(points[0].dx, size.height);
    fillPath.lineTo(points[0].dx, points[0].dy);

    for (int i = 1; i < points.length; i++) {
      final cpx = (points[i - 1].dx + points[i].dx) / 2;
      path.cubicTo(cpx, points[i - 1].dy, cpx, points[i].dy,
          points[i].dx, points[i].dy);
      fillPath.cubicTo(cpx, points[i - 1].dy, cpx, points[i].dy,
          points[i].dx, points[i].dy);
    }

    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();

    // Gradient fill
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            fillColor.withValues(alpha: 0.2),
            fillColor.withValues(alpha: 0.02),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Smooth line
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor.withValues(alpha: 0.7)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Dots
    for (final p in points) {
      canvas.drawCircle(p, 4, Paint()..color = lineColor.withValues(alpha: 0.8));
      canvas.drawCircle(p, 2, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(_CalmTrendPainter oldDelegate) =>
      oldDelegate.data.length != data.length;
}

// ── Finance Card ──

class _FinanceCard extends StatelessWidget {
  final List<_FinancePoint> data;

  const _FinanceCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = data.fold<double>(0, (s, d) => s + d.amount);
    final maxDay = data.fold<double>(0, (m, d) => d.amount > m ? d.amount : m);

    if (total == 0) {
      return HopeCard(
        child: SizedBox(
          height: 120,
          child: Center(
            child: Text('Log expenses to see spending trends',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
        ),
      );
    }

    return HopeCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('7-day total',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              Text('\$${total.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFEF5350))),
            ],
          ),
          const SizedBox(height: 12),
          ...data.map((point) {
            final pct = maxDay > 0 ? point.amount / maxDay : 0.0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  SizedBox(
                    width: 32,
                    child: Text(point.label,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        backgroundColor:
                            const Color(0xFFEF5350).withValues(alpha: 0.06),
                        valueColor: AlwaysStoppedAnimation(
                          const Color(0xFFEF5350).withValues(alpha: 0.6),
                        ),
                        minHeight: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 48,
                    child: Text(
                      point.amount > 0
                          ? '\$${point.amount.toStringAsFixed(0)}'
                          : '—',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: const Color(0xFFEF5350),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Overview Row ──

class _OverviewRow extends StatelessWidget {
  final int actionsCompleted;
  final int pendingActions;
  final int journalEntries;
  final double moodAverage;

  const _OverviewRow({
    required this.actionsCompleted,
    required this.pendingActions,
    required this.journalEntries,
    required this.moodAverage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          value: '$actionsCompleted',
          label: 'Done today',
          icon: Icons.check_circle_outline,
          color: Colors.green,
        ),
        const SizedBox(width: 8),
        _StatCard(
          value: '$pendingActions',
          label: 'Pending',
          icon: Icons.pending_actions,
          color: Colors.orange,
        ),
        const SizedBox(width: 8),
        _StatCard(
          value: moodAverage > 0 ? moodAverage.toStringAsFixed(1) : '—',
          label: 'Avg mood',
          icon: Icons.mood,
          color: Colors.purple,
        ),
        const SizedBox(width: 8),
        _StatCard(
          value: '$journalEntries',
          label: 'Entries',
          icon: Icons.book,
          color: Colors.teal,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(value,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold, color: color)),
            Text(label,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ── Goals Card ──

class _GoalsCard extends StatelessWidget {
  final double waterCurrent;
  final double waterGoal;
  final double sleepCurrent;
  final double sleepGoal;
  final int exerciseCurrent;
  final int exerciseGoal;

  const _GoalsCard({
    required this.waterCurrent,
    required this.waterGoal,
    required this.sleepCurrent,
    required this.sleepGoal,
    required this.exerciseCurrent,
    required this.exerciseGoal,
  });

  @override
  Widget build(BuildContext context) {
    return HopeCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _GoalRing(
            label: 'Water',
            current: '${waterCurrent.toStringAsFixed(1)}L',
            progress: waterGoal > 0 ? waterCurrent / waterGoal : 0,
            color: const Color(0xFF42A5F5),
          ),
          _GoalRing(
            label: 'Sleep',
            current: '${sleepCurrent.toStringAsFixed(1)}h',
            progress: sleepGoal > 0 ? sleepCurrent / sleepGoal : 0,
            color: const Color(0xFF5C6BC0),
          ),
          _GoalRing(
            label: 'Exercise',
            current: '${exerciseCurrent}m',
            progress: exerciseGoal > 0 ? exerciseCurrent / exerciseGoal : 0,
            color: const Color(0xFF66BB6A),
          ),
        ],
      ),
    );
  }
}

class _GoalRing extends StatelessWidget {
  final String label;
  final String current;
  final double progress;
  final Color color;

  const _GoalRing({
    required this.label,
    required this.current,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        ProgressRing(
          progress: progress,
          size: 64,
          strokeWidth: 6,
          color: color,
          child: Text(current,
              style: theme.textTheme.labelSmall
                  ?.copyWith(fontWeight: FontWeight.bold, color: color)),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

// ── Energy Distribution ──

class _EnergyDistribution extends StatelessWidget {
  final List entries;

  const _EnergyDistribution({required this.entries});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final energyCounts = <int, int>{};
    for (final entry in entries) {
      energyCounts[entry.energyLevel] =
          (energyCounts[entry.energyLevel] ?? 0) + 1;
    }

    final labels = ['Empty', 'Low', 'Medium', 'High', 'Peak'];
    final colors = [
      const Color(0xFFEF5350),
      const Color(0xFFFF7043),
      const Color(0xFFFFCA28),
      const Color(0xFF9CCC65),
      const Color(0xFF66BB6A),
    ];

    return HopeCard(
      child: Column(
        children: List.generate(5, (index) {
          final level = index + 1;
          final count = energyCounts[level] ?? 0;
          final maxCount = entries.length;
          final pct = maxCount > 0 ? count / maxCount : 0.0;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 56,
                  child: Text(labels[index],
                      style: theme.textTheme.bodySmall),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: colors[index].withValues(alpha: 0.08),
                      valueColor: AlwaysStoppedAnimation(
                          colors[index].withValues(alpha: 0.7)),
                      minHeight: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 24,
                  child: Text('$count',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
