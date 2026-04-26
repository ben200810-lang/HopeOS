import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/hope_card.dart';
import '../adhd/adhd_insights_screen.dart';
import '../patterns/pattern_insights_screen.dart';
import 'about_screen.dart';
import 'privacy_screen.dart';
import 'settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<SettingsProvider>();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        const SliverAppBar(
          floating: true,
          title: Text('Settings'),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 8),

              // Appearance
              _SectionTitle(title: 'Appearance'),
              HopeCard(
                child: Column(
                  children: [
                    _ThemeTile(
                      currentMode: settings.themeMode,
                      onChanged: settings.setThemeMode,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Language
              _SectionTitle(title: 'Language'),
              HopeCard(
                child: Column(
                  children: [
                    _LanguageSetting(
                      currentLanguage: settings.language,
                      onChanged: settings.setLanguage,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Measurement Units
              _SectionTitle(title: 'Units'),
              HopeCard(
                child: Column(
                  children: [
                    _UnitSetting(
                      currentUnit: settings.unit,
                      onChanged: settings.setMeasurementUnit,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Notifications
              _SectionTitle(title: 'Notifications'),
              HopeCard(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Enable notifications'),
                      subtitle: const Text('Reminders and daily check-ins'),
                      value: settings.notificationsEnabled,
                      onChanged: (v) => settings.setNotificationsEnabled(v),
                    ),
                    if (settings.notificationsEnabled) ...[
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.water_drop_outlined),
                        title: const Text('Drink reminder'),
                        subtitle: const Text('Every 2 hours (8:00-22:00)'),
                        trailing: Icon(Icons.check_circle,
                            color: theme.colorScheme.primary),
                      ),
                      ListTile(
                        leading: const Icon(Icons.bedtime_outlined),
                        title: const Text('Sleep reminder'),
                        subtitle: const Text('Daily at 22:00'),
                        trailing: Icon(Icons.check_circle,
                            color: theme.colorScheme.primary),
                      ),
                      ListTile(
                        leading: const Icon(Icons.self_improvement),
                        title: const Text('Daily reflection'),
                        subtitle: const Text('Daily at 20:00'),
                        trailing: Icon(Icons.check_circle,
                            color: theme.colorScheme.primary),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Quick Capture
              _SectionTitle(title: 'Quick Capture'),
              HopeCard(
                child: SwitchListTile(
                  title: const Text('Lock screen quick capture'),
                  subtitle: const Text('Capture thoughts from lock screen'),
                  value: settings.quickCaptureEnabled,
                  onChanged: (v) => settings.setQuickCaptureEnabled(v),
                ),
              ),

              const SizedBox(height: 20),

              // Goals
              _SectionTitle(title: 'Daily Goals'),
              HopeCard(
                child: Column(
                  children: [
                    _GoalSlider(
                      icon: Icons.water_drop,
                      label: 'Water Goal',
                      value: settings.waterGoal,
                      min: 0.5,
                      max: 5.0,
                      divisions: 9,
                      suffix: 'L',
                      color: Colors.blue,
                      onChanged: settings.setWaterGoal,
                    ),
                    const Divider(),
                    _GoalSlider(
                      icon: Icons.bedtime,
                      label: 'Sleep Goal',
                      value: settings.sleepGoal,
                      min: 4,
                      max: 12,
                      divisions: 16,
                      suffix: 'h',
                      color: Colors.indigo,
                      onChanged: settings.setSleepGoal,
                    ),
                    const Divider(),
                    _GoalSliderInt(
                      icon: Icons.fitness_center,
                      label: 'Exercise Goal',
                      value: settings.exerciseGoal,
                      min: 10,
                      max: 120,
                      divisions: 11,
                      suffix: 'min',
                      color: Colors.green,
                      onChanged: settings.setExerciseGoal,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Knowledge Base
              _SectionTitle(title: 'Knowledge Base'),
              HopeCard(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.auto_awesome,
                          color: theme.colorScheme.primary),
                      title: const Text('Pattern Insights'),
                      subtitle: const Text('Your personal patterns & trends'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PatternInsightsScreen()),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.psychology,
                          color: theme.colorScheme.primary),
                      title: const Text('ADHD Insights'),
                      subtitle: const Text('Pattern analysis & strategies'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AdhdInsightsScreen()),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // About & Legal
              _SectionTitle(title: 'About & Legal'),
              HopeCard(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.shield_outlined,
                          color: theme.colorScheme.primary),
                      title: const Text('Privacy'),
                      subtitle: const Text('How your data is stored'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PrivacyScreen()),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.info_outline,
                          color: theme.colorScheme.primary),
                      title: const Text('About HopeOS'),
                      subtitle: const Text('Mission, founder & values'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AboutScreen()),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  final ThemeMode currentMode;
  final Function(ThemeMode) onChanged;

  const _ThemeTile({required this.currentMode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Theme',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment(
              value: ThemeMode.system,
              icon: Icon(Icons.brightness_auto, size: 18),
              label: Text('Auto'),
            ),
            ButtonSegment(
              value: ThemeMode.light,
              icon: Icon(Icons.light_mode, size: 18),
              label: Text('Light'),
            ),
            ButtonSegment(
              value: ThemeMode.dark,
              icon: Icon(Icons.dark_mode, size: 18),
              label: Text('Dark'),
            ),
          ],
          selected: {currentMode},
          onSelectionChanged: (modes) => onChanged(modes.first),
        ),
      ],
    );
  }
}

class _GoalSlider extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String suffix;
  final Color color;
  final Function(double) onChanged;

  const _GoalSlider({
    required this.icon,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.suffix,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(label, style: theme.textTheme.bodyMedium),
              const Spacer(),
              Text(
                '${value.toStringAsFixed(1)}$suffix',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: color,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _GoalSliderInt extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final int min;
  final int max;
  final int divisions;
  final String suffix;
  final Color color;
  final Function(int) onChanged;

  const _GoalSliderInt({
    required this.icon,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.suffix,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(label, style: theme.textTheme.bodyMedium),
              const Spacer(),
              Text(
                '$value$suffix',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: divisions,
            activeColor: color,
            onChanged: (v) => onChanged(v.round()),
          ),
        ],
      ),
    );
  }
}

class _LanguageSetting extends StatelessWidget {
  final String currentLanguage;
  final Function(String) onChanged;

  const _LanguageSetting({
    required this.currentLanguage,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Language',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'en', label: Text('English')),
            ButtonSegment(value: 'hu', label: Text('Magyar')),
          ],
          selected: {currentLanguage},
          onSelectionChanged: (langs) => onChanged(langs.first),
        ),
      ],
    );
  }
}

class _UnitSetting extends StatelessWidget {
  final MeasurementUnit currentUnit;
  final Function(MeasurementUnit) onChanged;

  const _UnitSetting({
    required this.currentUnit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Measurement Units',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<MeasurementUnit>(
          segments: const [
            ButtonSegment(
              value: MeasurementUnit.metric,
              label: Text('Metric'),
            ),
            ButtonSegment(
              value: MeasurementUnit.imperial,
              label: Text('Imperial'),
            ),
          ],
          selected: {currentUnit},
          onSelectionChanged: (units) => onChanged(units.first),
        ),
      ],
    );
  }
}
