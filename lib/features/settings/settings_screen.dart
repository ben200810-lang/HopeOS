import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/hope_card.dart';
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

              // Profile
              _SectionTitle(title: 'Profile'),
              HopeCard(
                child: Column(
                  children: [
                    _SettingsTextField(
                      label: 'Your Name',
                      value: settings.userName,
                      hint: 'Enter your name',
                      onChanged: settings.setUserName,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

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
                child: SwitchListTile(
                  title: const Text('Enable notifications'),
                  subtitle: const Text('Reminders and daily check-ins'),
                  value: settings.notificationsEnabled,
                  onChanged: (v) => settings.setNotificationsEnabled(v),
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

              // About
              _SectionTitle(title: 'About'),
              HopeCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HopeOS',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your personal life operating system',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Version 1.0.0',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Designed for ADHD minds. Built with care.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
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

class _SettingsTextField extends StatefulWidget {
  final String label;
  final String value;
  final String hint;
  final Function(String) onChanged;

  const _SettingsTextField({
    required this.label,
    required this.value,
    required this.hint,
    required this.onChanged,
  });

  @override
  State<_SettingsTextField> createState() => _SettingsTextFieldState();
}

class _SettingsTextFieldState extends State<_SettingsTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
      ),
      onChanged: widget.onChanged,
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
