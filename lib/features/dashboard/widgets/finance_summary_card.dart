import 'package:flutter/material.dart';
import 'package:hopeos/l10n/app_localizations.dart';
import '../../../data/models/capture_entry.dart';

class FinanceSummaryCard extends StatelessWidget {
  final List<CaptureEntry> recentExpenses;
  final VoidCallback onAddIncome;
  final VoidCallback onAddExpense;

  const FinanceSummaryCard({
    super.key,
    required this.recentExpenses,
    required this.onAddIncome,
    required this.onAddExpense,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    // Calculate balance from recent expenses
    double totalIncome = 0;
    double totalExpense = 0;
    for (final entry in recentExpenses) {
      final amount = entry.amount ?? 0;
      if (amount >= 0) {
        totalIncome += amount;
      } else {
        totalExpense += amount.abs();
      }
    }
    final balance = totalIncome - totalExpense;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet,
                  size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                l10n?.finance ?? 'Finance',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Balance display
          Center(
            child: Column(
              children: [
                Text(
                  l10n?.currentBalance ?? 'Current Balance',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${balance >= 0 ? '+' : ''}${balance.toStringAsFixed(0)}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: balance >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Income / Expense row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.arrow_upward,
                          size: 14, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        '+${totalIncome.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.arrow_downward,
                          size: 14, color: Colors.red),
                      const SizedBox(width: 4),
                      Text(
                        '-${totalExpense.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // + / - buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onAddIncome,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(l10n?.income ?? 'Income'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    side: const BorderSide(color: Colors.green),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onAddExpense,
                  icon: const Icon(Icons.remove, size: 18),
                  label: Text(l10n?.expense ?? 'Expense'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
