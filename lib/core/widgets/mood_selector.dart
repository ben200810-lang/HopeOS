import 'package:flutter/material.dart';

class MoodSelector extends StatelessWidget {
  final int selectedLevel;
  final ValueChanged<int> onChanged;
  final double size;

  const MoodSelector({
    super.key,
    required this.selectedLevel,
    required this.onChanged,
    this.size = 48,
  });

  static const _moods = ['😢', '😔', '😐', '🙂', '😊'];
  static const _labels = ['Awful', 'Bad', 'Okay', 'Good', 'Great'];

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
                  ? theme.colorScheme.primaryContainer
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _moods[index],
                  style: TextStyle(fontSize: isSelected ? size : size * 0.8),
                ),
                const SizedBox(height: 4),
                Text(
                  _labels[index],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? theme.colorScheme.primary
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
