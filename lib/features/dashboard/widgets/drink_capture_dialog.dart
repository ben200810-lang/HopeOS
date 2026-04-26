import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hopeos/l10n/app_localizations.dart';
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

  static const _defaultDrinks = [
    _DrinkOption(id: 'water', name: 'Water', emoji: '💧', defaultMl: 250, hydrationFactor: 1.0),
    _DrinkOption(id: 'coffee', name: 'Coffee', emoji: '☕', defaultMl: 200, hydrationFactor: 0.8),
    _DrinkOption(id: 'tea', name: 'Tea', emoji: '🍵', defaultMl: 200, hydrationFactor: 0.9),
    _DrinkOption(id: 'energy_drink', name: 'Energy drink', emoji: '⚡', defaultMl: 250, hydrationFactor: 0.6),
    _DrinkOption(id: 'custom', name: 'Custom', emoji: '🥤', defaultMl: 250, hydrationFactor: 0.8),
  ];

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

    // Add fallback drinks if knowledge service is empty
    if (drinks.isEmpty) {
      drinks.addAll(_defaultDrinks);
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
    final l10n = AppLocalizations.of(context);

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.logDrink ?? 'Log Drink',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Drink type dropdown
            Text(
              l10n?.drinkType ?? 'Drink type',
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
              '${l10n?.amount ?? 'Amount'}: ${_amountMl.round()} ml',
              style: theme.textTheme.labelLarge,
            ),
            Slider(
              value: _amountMl,
              min: 100,
              max: 1000,
              divisions: 18,
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
                  child: Text(l10n?.cancel ?? 'Cancel'),
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
                  child: Text(l10n?.log ?? 'Log'),
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
