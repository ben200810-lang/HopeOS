import 'package:flutter/material.dart';

class EnergySelector extends StatelessWidget {
  final int selectedLevel;
  final ValueChanged<int> onChanged;

  const EnergySelector({
    super.key,
    required this.selectedLevel,
    required this.onChanged,
  });

  static const _icons = [
    Icons.battery_1_bar,
    Icons.battery_3_bar,
    Icons.battery_5_bar,
    Icons.battery_full,
    Icons.bolt,
  ];
  static const _labels = ['Empty', 'Low', 'Medium', 'High', 'Peak'];
  static const _colors = [
    Colors.red,
    Colors.orange,
    Colors.amber,
    Colors.lightGreen,
    Colors.green,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(5, (index) {
        final level = index + 1;
        final isSelected = level == selectedLevel;
        return GestureDetector(
          onTap: () => onChanged(level),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected
                  ? _colors[index].withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: _colors[index], width: 2)
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _icons[index],
                  size: isSelected ? 32 : 28,
                  color: isSelected
                      ? _colors[index]
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 4),
                Text(
                  _labels[index],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? _colors[index]
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
