import 'package:flutter/material.dart';

class QuickActionsRow extends StatelessWidget {
  final VoidCallback onNote;
  final VoidCallback onVoice;
  final VoidCallback onFeeling;
  final VoidCallback onDrink;
  final VoidCallback onExpense;

  const QuickActionsRow({
    super.key,
    required this.onNote,
    required this.onVoice,
    required this.onFeeling,
    required this.onDrink,
    required this.onExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _QuickActionButton(
              icon: Icons.edit_note,
              label: 'Note',
              color: Colors.teal,
              onTap: onNote,
            ),
            const SizedBox(width: 8),
            _QuickActionButton(
              icon: Icons.mic,
              label: 'Voice',
              color: Colors.deepPurple,
              onTap: onVoice,
            ),
            const SizedBox(width: 8),
            _QuickActionButton(
              icon: Icons.mood,
              label: 'Feeling',
              color: Colors.amber.shade700,
              onTap: onFeeling,
            ),
            const SizedBox(width: 8),
            _QuickActionButton(
              icon: Icons.water_drop,
              label: 'Drink',
              color: Colors.blue,
              onTap: onDrink,
            ),
            const SizedBox(width: 8),
            _QuickActionButton(
              icon: Icons.receipt_long,
              label: 'Expense',
              color: Colors.red.shade400,
              onTap: onExpense,
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
