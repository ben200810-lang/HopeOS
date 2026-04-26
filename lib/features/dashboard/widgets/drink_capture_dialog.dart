import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/knowledge/knowledge_service.dart';
import '../../settings/settings_provider.dart';

class DrinkCaptureDialog extends StatefulWidget {
  const DrinkCaptureDialog({super.key});

  @override
  State<DrinkCaptureDialog> createState() => _DrinkCaptureDialogState();
}

class _DrinkCaptureDialogState extends State<DrinkCaptureDialog> {
  String? _selectedDrinkId;
  String _selectedDrinkName = '';
  String _selectedEmoji = '💧';
  double _amountMl = 250;
  double _hydrationFactor = 1.0;

  List<_DrinkOption> _drinks = [];

  @override
  void initState() {
    super.initState();
    _loadDrinks();
  }

  void _loadDrinks() {
    final knowledge = KnowledgeService();
    final settings = context.read<SettingsProvider>();
    final locale = settings.language;
    final drinksDataset = knowledge.drinks;
    final customDrinks = settings.customDrinkCategories;

    final drinks = <_DrinkOption>[];

    if (drinksDataset != null) {
      for (final cat in drinksDataset.categories) {
        for (final item in cat.items) {
          drinks.add(_DrinkOption(
            id: item.id,
            name: item.localizedName(locale),
            emoji: item.emoji,
            defaultMl: (item.extra['ml_default'] as num?)?.toDouble() ?? 250,
            hydrationFactor:
                (item.extra['hydration_factor'] as num?)?.toDouble() ?? 1.0,
          ));
        }
      }
    }

    for (final custom in customDrinks) {
      drinks.add(_DrinkOption(
        id: 'custom_$custom',
        name: custom,
        emoji: '🥤',
        defaultMl: 250,
        hydrationFactor: 0.8,
      ));
    }

    setState(() {
      _drinks = drinks;
      if (drinks.isNotEmpty) {
        _selectedDrinkId = drinks[0].id;
        _selectedDrinkName = drinks[0].name;
        _selectedEmoji = drinks[0].emoji;
        _amountMl = drinks[0].defaultMl;
        _hydrationFactor = drinks[0].hydrationFactor;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<SettingsProvider>();
    final isHu = settings.language == 'hu';

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isHu ? 'Ital rögzítése' : 'Log Drink',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Drink type dropdown
            Text(
              isHu ? 'Ital típusa' : 'Drink type',
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedDrinkId,
              isExpanded: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _drinks.map((d) {
                return DropdownMenuItem(
                  value: d.id,
                  child: Text('${d.emoji} ${d.name}'),
                );
              }).toList(),
              onChanged: (id) {
                if (id == null) return;
                final drink = _drinks.firstWhere((d) => d.id == id);
                setState(() {
                  _selectedDrinkId = id;
                  _selectedDrinkName = drink.name;
                  _selectedEmoji = drink.emoji;
                  _amountMl = drink.defaultMl;
                  _hydrationFactor = drink.hydrationFactor;
                });
              },
            ),
            const SizedBox(height: 16),

            // Amount slider
            Text(
              isHu
                  ? 'Mennyiség: ${_amountMl.round()} ml'
                  : 'Amount: ${_amountMl.round()} ml',
              style: theme.textTheme.labelLarge,
            ),
            Slider(
              value: _amountMl,
              min: 50,
              max: 1000,
              divisions: 19,
              label: '${_amountMl.round()} ml',
              onChanged: (v) => setState(() => _amountMl = v),
            ),

            const SizedBox(height: 8),

            // Quick amount buttons
            Wrap(
              spacing: 8,
              children: [100, 200, 250, 330, 500].map((ml) {
                return ActionChip(
                  label: Text('$ml ml'),
                  onPressed: () => setState(() => _amountMl = ml.toDouble()),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(isHu ? 'Mégse' : 'Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    final hydrationLiters =
                        (_amountMl / 1000) * _hydrationFactor;
                    Navigator.pop(context, DrinkResult(
                      drinkName: _selectedDrinkName,
                      emoji: _selectedEmoji,
                      amountMl: _amountMl,
                      hydrationLiters: hydrationLiters,
                    ));
                  },
                  child: Text(isHu ? 'Rögzítés' : 'Log'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DrinkOption {
  final String id;
  final String name;
  final String emoji;
  final double defaultMl;
  final double hydrationFactor;

  const _DrinkOption({
    required this.id,
    required this.name,
    required this.emoji,
    required this.defaultMl,
    required this.hydrationFactor,
  });
}

class DrinkResult {
  final String drinkName;
  final String emoji;
  final double amountMl;
  final double hydrationLiters;

  const DrinkResult({
    required this.drinkName,
    required this.emoji,
    required this.amountMl,
    required this.hydrationLiters,
  });
}
