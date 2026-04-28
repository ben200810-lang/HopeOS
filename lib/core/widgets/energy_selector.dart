import 'package:flutter/material.dart';

class EnergySelector extends StatelessWidget {
  final int selectedLevel;
  final ValueChanged<int> onChanged;

  const EnergySelector({
    super.key,
    required this.selectedLevel,
    required this.onChanged,
  });

  static const _levelCount = 10;

  static Color _colorForLevel(int level) {
    if (level <= 2) return Colors.red;
    if (level <= 4) return Colors.orange;
    if (level <= 6) return Colors.amber;
    if (level <= 8) return Colors.lightGreen;
    return Colors.green;
  }

  static IconData _iconForLevel(int level) {
    if (level <= 2) return Icons.battery_1_bar;
    if (level <= 4) return Icons.battery_3_bar;
    if (level <= 6) return Icons.battery_5_bar;
    if (level <= 8) return Icons.battery_full;
    return Icons.bolt;
  }

  static String _labelForLevel(int level) {
    if (level <= 2) return '😴';
    if (level <= 4) return '🪫';
    if (level <= 6) return '⚡';
    if (level <= 8) return '💪';
    return '🚀';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _colorForLevel(selectedLevel);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_iconForLevel(selectedLevel), color: color, size: 28),
            const SizedBox(width: 8),
            Text(
              _labelForLevel(selectedLevel),
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 8),
            Text(
              '$selectedLevel / $_levelCount',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: color,
            thumbColor: color,
            overlayColor: color.withValues(alpha: 0.12),
            inactiveTrackColor: color.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: selectedLevel.toDouble(),
            min: 1,
            max: _levelCount.toDouble(),
            divisions: _levelCount - 1,
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '😴',
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '🚀',
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
