import 'package:flutter/material.dart';
import 'package:hopeos/l10n/app_localizations.dart';

class QuickActionsRow extends StatelessWidget {
  final VoidCallback onNote;
  final VoidCallback onVoice;
  final VoidCallback onFeeling;
  final VoidCallback onDrink;
  final VoidCallback onExpense;
  final VoidCallback? onSleep;

  const QuickActionsRow({
    super.key,
    required this.onNote,
    required this.onVoice,
    required this.onFeeling,
    required this.onDrink,
    required this.onExpense,
    this.onSleep,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n?.quickActions ?? 'Quick Actions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _QuickActionButton(
              icon: Icons.water_drop,
              label: l10n?.drink ?? 'Drink',
              color: Colors.blue,
              onTap: onDrink,
            ),
            _QuickActionButton(
              icon: Icons.receipt_long,
              label: l10n?.expense ?? 'Expense',
              color: Colors.red.shade400,
              onTap: onExpense,
            ),
            _QuickActionButton(
              icon: Icons.mood,
              label: l10n?.mood ?? 'Mood',
              color: Colors.amber.shade700,
              onTap: onFeeling,
            ),
            _QuickActionButton(
              icon: Icons.edit_note,
              label: l10n?.note ?? 'Note',
              color: Colors.teal,
              onTap: onNote,
            ),
            if (onSleep != null)
              _QuickActionButton(
                icon: Icons.bedtime,
                label: l10n?.sleep ?? 'Sleep',
                color: Colors.indigo,
                onTap: onSleep!,
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
    return SizedBox(
      width: 64,
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
