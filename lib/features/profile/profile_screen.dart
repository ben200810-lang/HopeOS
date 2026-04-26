import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/hope_card.dart';
import '../settings/settings_provider.dart';
import '../settings/settings_screen.dart';
import '../actions/action_provider.dart';
import '../journal/journal_provider.dart';
import 'onboarding_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<SettingsProvider>();
    final actions = context.watch<ActionProvider>();
    final journal = context.watch<JournalProvider>();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          floating: true,
          title: const Text('Profile'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const Scaffold(body: SettingsScreen()),
                ),
              ),
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 8),

              // Avatar + name + profile info
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(
                        settings.userName.isNotEmpty
                            ? settings.userName[0].toUpperCase()
                            : '?',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      settings.userName.isNotEmpty
                          ? settings.userName
                          : 'Set your name',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _buildSubtitle(settings),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (!settings.onboarded) ...[
                      const SizedBox(height: 12),
                      FilledButton.tonal(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const OnboardingScreen()),
                        ),
                        child: const Text('Complete Profile Setup'),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Stats
              Row(
                children: [
                  _ProfileStat(
                    value: '${actions.completedActions.length}',
                    label: 'Actions done',
                    color: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  _ProfileStat(
                    value: '${journal.totalCount}',
                    label: 'Journal entries',
                    color: Colors.teal,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Account ──
              _SectionTitle(title: 'Account'),
              HopeCard(
                child: Column(
                  children: [
                    _SettingsTextField(
                      label: 'Nickname',
                      value: settings.userName,
                      hint: 'Enter your name',
                      onChanged: settings.setUserName,
                    ),
                    const Divider(),
                    _SettingsTile(
                      icon: Icons.person_outline,
                      title: 'Edit Profile',
                      subtitle: _profileSummary(settings),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const OnboardingScreen()),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Appearance ──
              _SectionTitle(title: 'Appearance'),
              HopeCard(
                child: Column(
                  children: [
                    _ThemeTile(
                      currentMode: settings.themeMode,
                      onChanged: settings.setThemeMode,
                    ),
                    const Divider(),
                    _ColorModeTile(
                      currentMode: settings.colorMode,
                      onChanged: settings.setColorMode,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Preferences ──
              _SectionTitle(title: 'Preferences'),
              HopeCard(
                child: Column(
                  children: [
                    _UnitTile(
                      current: settings.unit,
                      onChanged: settings.setMeasurementUnit,
                    ),
                    const Divider(),
                    _CurrencyTile(
                      current: settings.currency,
                      onChanged: settings.setCurrency,
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('Notifications'),
                      subtitle: const Text('Reminders and encouragement'),
                      secondary: const Icon(Icons.notifications_outlined),
                      value: settings.notificationsEnabled,
                      onChanged: (v) => settings.setNotificationsEnabled(v),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Daily Goals ──
              _SectionTitle(title: 'Daily Goals'),
              HopeCard(
                child: Column(
                  children: [
                    _GoalSlider(
                      icon: Icons.water_drop,
                      label: 'Water',
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
                      label: 'Sleep',
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
                      label: 'Exercise',
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

              // ── Privacy ──
              _SectionTitle(title: 'Privacy'),
              HopeCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.shield_outlined,
                            color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Your data is private',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'All data is stored locally on your device. '
                      'Nothing is sent to any server. '
                      'Your journal, health data, emotions, and expenses '
                      'never leave your phone.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── About ──
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
                      'Version 1.1.0',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
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

  String _buildSubtitle(SettingsProvider settings) {
    final parts = <String>[];
    if (settings.age != null) parts.add('${settings.age} years');
    if (settings.gender != null) {
      parts.add(settings.gender == GenderIdentity.male ? 'Male' : 'Female');
    }
    return parts.isEmpty ? 'HopeOS User' : parts.join(' · ');
  }

  String _profileSummary(SettingsProvider settings) {
    final parts = <String>[];
    if (settings.heightCm != null) {
      parts.add('${settings.heightCm!.round()}cm');
    }
    if (settings.weightKg != null) {
      parts.add('${settings.weightKg!.round()}kg');
    }
    if (settings.bodyType != null) {
      parts.add(settings.bodyType!.name);
    }
    return parts.isEmpty ? 'Tap to set up' : parts.join(' · ');
  }
}

// ── Widgets ──

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _ProfileStat({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
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

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
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

class _ColorModeTile extends StatelessWidget {
  final ColorMode currentMode;
  final Function(ColorMode) onChanged;

  const _ColorModeTile({required this.currentMode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          'Color',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: ColorMode.values.map((mode) {
            final isSelected = mode == currentMode;
            final color = _colorForMode(mode);
            return GestureDetector(
              onTap: () => onChanged(mode),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: theme.colorScheme.onSurface, width: 3)
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                          )
                        ]
                      : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : null,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Color _colorForMode(ColorMode mode) {
    switch (mode) {
      case ColorMode.blue:
        return const Color(0xFF6C63FF);
      case ColorMode.green:
        return const Color(0xFF4CAF50);
      case ColorMode.purple:
        return const Color(0xFF9C27B0);
      case ColorMode.orange:
        return const Color(0xFFFF9800);
      case ColorMode.pink:
        return const Color(0xFFE91E63);
      case ColorMode.teal:
        return const Color(0xFF009688);
    }
  }
}

class _UnitTile extends StatelessWidget {
  final MeasurementUnit current;
  final Function(MeasurementUnit) onChanged;

  const _UnitTile({required this.current, required this.onChanged});

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
              label: Text('Metric (cm, kg)'),
            ),
            ButtonSegment(
              value: MeasurementUnit.imperial,
              label: Text('Imperial (ft, lb)'),
            ),
          ],
          selected: {current},
          onSelectionChanged: (s) => onChanged(s.first),
        ),
      ],
    );
  }
}

class _CurrencyTile extends StatelessWidget {
  final String current;
  final Function(String) onChanged;

  const _CurrencyTile({required this.current, required this.onChanged});

  static const _currencies = [
    'USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD', 'CHF', 'HUF', 'INR', 'BRL',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Currency',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _currencies.map((c) {
            return ChoiceChip(
              label: Text(c),
              selected: current == c,
              onSelected: (_) => onChanged(c),
            );
          }).toList(),
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
