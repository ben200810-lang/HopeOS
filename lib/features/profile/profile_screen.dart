import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/hope_card.dart';
import '../settings/settings_provider.dart';
import '../settings/settings_screen.dart';
import '../actions/action_provider.dart';
import '../journal/journal_provider.dart';
import 'onboarding_screen.dart';
// ignore_for_file: unused_import

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

              // ── Personal Info ──
              _SectionTitle(title: 'Personal Info'),
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


