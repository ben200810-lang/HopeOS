import 'package:flutter/material.dart';
import 'dart:math' as math;

class LifeSignalsCard extends StatelessWidget {
  final List<double> hydrationData;
  final List<double> activityData;
  final List<double> sleepData;
  final List<double> moodData;

  const LifeSignalsCard({
    super.key,
    required this.hydrationData,
    required this.activityData,
    required this.sleepData,
    required this.moodData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Life Signals',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SignalTile(
                label: 'Hydration',
                icon: Icons.water_drop,
                color: Colors.blue,
                data: hydrationData,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SignalTile(
                label: 'Activity',
                icon: Icons.directions_run,
                color: Colors.green,
                data: activityData,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _SignalTile(
                label: 'Sleep',
                icon: Icons.bedtime,
                color: Colors.indigo,
                data: sleepData,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SignalTile(
                label: 'Mood',
                icon: Icons.mood,
                color: Colors.purple,
                data: moodData,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SignalTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final List<double> data;

  const _SignalTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasData = data.isNotEmpty && data.any((v) => v > 0);
    final trend = _computeTrend();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              if (hasData)
                Icon(
                  trend >= 0 ? Icons.trending_up : Icons.trending_down,
                  size: 16,
                  color: trend >= 0 ? Colors.green : Colors.red,
                ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: hasData
                ? CustomPaint(
                    size: const Size(double.infinity, 40),
                    painter: _MiniSparklinePainter(
                      data: data,
                      color: color,
                    ),
                  )
                : Center(
                    child: Text(
                      'No data yet',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  double _computeTrend() {
    if (data.length < 2) return 0;
    final recent = data.last;
    final previous = data[data.length - 2];
    return recent - previous;
  }
}

class _MiniSparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;

  _MiniSparklinePainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxVal = data.reduce(math.max);
    final minVal = data.reduce(math.min);
    final range = maxVal - minVal;
    final normalizedData = data.map((v) {
      return range > 0 ? (v - minVal) / range : 0.5;
    }).toList();

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.25),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();
    final spacing =
        data.length > 1 ? size.width / (data.length - 1) : size.width;
    const yPadding = 4.0;
    final usableHeight = size.height - yPadding * 2;

    for (int i = 0; i < normalizedData.length; i++) {
      final x = data.length > 1 ? i * spacing : size.width / 2;
      final y = yPadding + usableHeight * (1 - normalizedData[i]);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(
      data.length > 1 ? (data.length - 1) * spacing : size.width / 2,
      size.height,
    );
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(_MiniSparklinePainter oldDelegate) =>
      oldDelegate.data != data;
}
