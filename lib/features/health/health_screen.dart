import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hopeos/l10n/app_localizations.dart';
import '../../core/widgets/hope_card.dart';
import '../../core/widgets/progress_ring.dart';
import '../settings/settings_provider.dart';
import 'health_provider.dart';

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final health = context.watch<HealthProvider>();
    final settings = context.watch<SettingsProvider>();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          floating: true,
          title: Text(AppLocalizations.of(context)?.physicalHealth ?? 'Physical Health'),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 8),

              // Water tracking
              _WaterCard(
                current: health.waterLiters,
                goal: settings.waterGoal,
                onAdd: (amount) => health.addWater(amount),
                onReset: () => health.resetWater(),
              ),

              const SizedBox(height: 16),

              // Sleep tracking
              _SleepCard(
                hours: health.sleepHours,
                goal: settings.sleepGoal,
                onSet: (hours) => health.setSleep(hours),
              ),

              const SizedBox(height: 16),

              // Exercise tracking
              _ExerciseCard(
                minutes: health.exerciseMinutes,
                goal: settings.exerciseGoal,
                onAdd: (minutes) => health.addExercise(minutes),
              ),

              const SizedBox(height: 16),

              // Week overview
              if (health.weekEntries.isNotEmpty) ...[
                Text(
                  AppLocalizations.of(context)?.thisWeek ?? 'This Week',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _WeekOverview(entries: health.weekEntries, settings: settings),
              ],

              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }
}

class _WaterCard extends StatelessWidget {
  final double current;
  final double goal;
  final Function(double) onAdd;
  final VoidCallback onReset;

  const _WaterCard({
    required this.current,
    required this.goal,
    required this.onAdd,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = goal > 0 ? current / goal : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withValues(alpha: 0.1),
            Colors.cyan.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.water_drop, color: Colors.blue, size: 24),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)?.water ?? 'Water',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ProgressRing(
                progress: progress,
                size: 48,
                color: Colors.blue,
                child: Text(
                  '${(progress * 100).round()}%',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${current.toStringAsFixed(1)}L / ${goal.toStringAsFixed(1)}L',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _WaterButton(label: '+100ml', onTap: () => onAdd(0.1)),
              const SizedBox(width: 8),
              _WaterButton(label: '+250ml', onTap: () => onAdd(0.25)),
              const SizedBox(width: 8),
              _WaterButton(label: '+500ml', onTap: () => onAdd(0.5)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                onPressed: onReset,
                tooltip: AppLocalizations.of(context)?.resetButton ?? 'Reset',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WaterButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _WaterButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.blue.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _SleepCard extends StatefulWidget {
  final double hours;
  final double goal;
  final Function(double) onSet;

  const _SleepCard({
    required this.hours,
    required this.goal,
    required this.onSet,
  });

  @override
  State<_SleepCard> createState() => _SleepCardState();
}

class _SleepCardState extends State<_SleepCard> {
  late double _sliderValue;

  @override
  void initState() {
    super.initState();
    _sliderValue = widget.hours;
  }

  @override
  void didUpdateWidget(_SleepCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hours != widget.hours) {
      _sliderValue = widget.hours;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = widget.goal > 0 ? widget.hours / widget.goal : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.indigo.withValues(alpha: 0.1),
            Colors.deepPurple.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bedtime, color: Colors.indigo, size: 24),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)?.sleep ?? 'Sleep',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ProgressRing(
                progress: progress,
                size: 48,
                color: Colors.indigo,
                child: Text(
                  '${widget.hours.toStringAsFixed(1)}h',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Slider(
            value: _sliderValue,
            min: 0,
            max: 14,
            divisions: 28,
            activeColor: Colors.indigo,
            label: '${_sliderValue.toStringAsFixed(1)}h',
            onChanged: (value) => setState(() => _sliderValue = value),
            onChangeEnd: (value) => widget.onSet(value),
          ),
          Text(
            'Goal: ${widget.goal.toStringAsFixed(1)}h',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final int minutes;
  final int goal;
  final Function(int) onAdd;

  const _ExerciseCard({
    required this.minutes,
    required this.goal,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = goal > 0 ? minutes / goal : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withValues(alpha: 0.1),
            Colors.teal.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.fitness_center, color: Colors.green, size: 24),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)?.exercise ?? 'Exercise',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ProgressRing(
                progress: progress,
                size: 48,
                color: Colors.green,
                child: Text(
                  '${minutes}m',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${minutes}min / ${goal}min',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [5, 10, 15, 30].map((m) {
              return ActionChip(
                label: Text('+${m}min'),
                onPressed: () => onAdd(m),
                backgroundColor: Colors.green.withValues(alpha: 0.1),
                labelStyle: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _WeekOverview extends StatelessWidget {
  final List entries;
  final SettingsProvider settings;

  const _WeekOverview({required this.entries, required this.settings});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return HopeCard(
      child: Column(
        children: [
          ...entries.take(7).map((entry) {
            final l10n = AppLocalizations.of(context);
            final dayNames = [
              l10n?.dayMon ?? 'Mon', l10n?.dayTue ?? 'Tue', l10n?.dayWed ?? 'Wed',
              l10n?.dayThu ?? 'Thu', l10n?.dayFri ?? 'Fri', l10n?.daySat ?? 'Sat', l10n?.daySun ?? 'Sun',
            ];
            final dayName = dayNames[entry.date.weekday - 1];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 36,
                    child: Text(
                      dayName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (entry.waterLiters / settings.waterGoal)
                            .clamp(0.0, 1.0),
                        backgroundColor:
                            Colors.blue.withValues(alpha: 0.1),
                        valueColor: const AlwaysStoppedAnimation(Colors.blue),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: ((entry.sleepHours ?? 0) / settings.sleepGoal)
                            .clamp(0.0, 1.0),
                        backgroundColor:
                            Colors.indigo.withValues(alpha: 0.1),
                        valueColor:
                            const AlwaysStoppedAnimation(Colors.indigo),
                        minHeight: 6,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: Colors.blue, label: AppLocalizations.of(context)?.water ?? 'Water'),
              const SizedBox(width: 16),
              _LegendDot(color: Colors.indigo, label: AppLocalizations.of(context)?.sleep ?? 'Sleep'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
