import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hopeos/l10n/app_localizations.dart';
import '../settings/settings_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Page 0: Welcome + nickname
  final _nicknameController = TextEditingController();

  // Page 1: Gender
  GenderIdentity? _gender;

  // Page 2: Birth date
  DateTime? _birthDate;

  // Page 3: Height + weight
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  // Page 4: Body type
  BodyType? _bodyType;

  // Page 5: Language
  String _language = 'en';

  // Page 6: Units
  MeasurementUnit _selectedUnit = MeasurementUnit.metric;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    if (settings.userName.isNotEmpty) {
      _nicknameController.text = settings.userName;
    }
    _gender = settings.gender;
    _birthDate = settings.birthDate;
    if (settings.heightCm != null) {
      _heightController.text = settings.heightCm!.round().toString();
    }
    if (settings.weightKg != null) {
      _weightController.text = settings.weightKg!.round().toString();
    }
    _bodyType = settings.bodyType;
    _language = settings.language;
    _selectedUnit = settings.unit;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nicknameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 6) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finish() async {
    final settings = context.read<SettingsProvider>();
    if (_nicknameController.text.trim().isNotEmpty) {
      await settings.setUserName(_nicknameController.text.trim());
    }
    if (_gender != null) await settings.setGender(_gender!);
    if (_birthDate != null) await settings.setBirthDate(_birthDate!);

    final height = double.tryParse(_heightController.text);
    if (height != null && height > 0) await settings.setHeight(height);

    final weight = double.tryParse(_weightController.text);
    if (weight != null && weight > 0) await settings.setWeight(weight);

    if (_bodyType != null) await settings.setBodyType(_bodyType!);
    await settings.setLanguage(_language);
    await settings.setMeasurementUnit(_selectedUnit);
    await settings.setOnboarded(true);
    await settings.setHasCompletedOnboarding(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress dots
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: Row(
                children: List.generate(7, (i) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: i <= _currentPage
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outlineVariant,
                      ),
                    ),
                  );
                }),
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) =>
                    setState(() => _currentPage = page),
                children: [
                  _WelcomePage(
                    controller: _nicknameController,
                    onNext: _nextPage,
                  ),
                  _GenderPage(
                    selected: _gender,
                    onSelect: (g) {
                      setState(() => _gender = g);
                      _nextPage();
                    },
                  ),
                  _BirthDatePage(
                    selected: _birthDate,
                    onSelect: (d) {
                      setState(() => _birthDate = d);
                      _nextPage();
                    },
                  ),
                  _MeasurementsPage(
                    heightController: _heightController,
                    weightController: _weightController,
                    onNext: _nextPage,
                  ),
                  _BodyTypePage(
                    gender: _gender,
                    selected: _bodyType,
                    onSelect: (bt) => setState(() => _bodyType = bt),
                    onNext: _nextPage,
                  ),
                  _LanguagePage(
                    selected: _language,
                    onSelect: (lang) {
                      setState(() => _language = lang);
                      _nextPage();
                    },
                  ),
                  _UnitsPage(
                    selected: _selectedUnit,
                    onSelect: (u) => setState(() => _selectedUnit = u),
                    onFinish: _finish,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Page 0: Welcome + Nickname ──

class _WelcomePage extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onNext;

  const _WelcomePage({required this.controller, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '🌱',
            style: const TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)?.welcomeToHopeOS ?? 'Welcome to HopeOS',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)?.letsGetToKnowYou ?? 'Your personal life operating system.\nLet\'s get to know you a little.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          TextField(
            controller: controller,
            autofocus: true,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)?.whatShouldWeCallYou ?? 'What should we call you?',
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onNext(),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onNext,
              child: Text(AppLocalizations.of(context)?.continueButton ?? 'Continue'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Page 1: Gender ──

class _GenderPage extends StatelessWidget {
  final GenderIdentity? selected;
  final ValueChanged<GenderIdentity> onSelect;

  const _GenderPage({this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)?.howDoYouIdentify ?? 'How do you identify?',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)?.thisHelpsPersonalize ?? 'This helps personalize your experience.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: _GenderCard(
                  icon: Icons.male,
                  label: AppLocalizations.of(context)?.male ?? 'Male',
                  isSelected: selected == GenderIdentity.male,
                  onTap: () => onSelect(GenderIdentity.male),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _GenderCard(
                  icon: Icons.female,
                  label: AppLocalizations.of(context)?.female ?? 'Female',
                  isSelected: selected == GenderIdentity.female,
                  onTap: () => onSelect(GenderIdentity.female),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: isSelected
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            children: [
              Icon(
                icon,
                size: 56,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Page 2: Birth Date ──

class _BirthDatePage extends StatelessWidget {
  final DateTime? selected;
  final ValueChanged<DateTime> onSelect;

  const _BirthDatePage({this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)?.whenWereYouBorn ?? 'When were you born?',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)?.staysPrivateAndLocal ?? 'This stays private and local on your device.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 40),
          if (selected != null)
            Text(
              '${selected!.day}/${selected!.month}/${selected!.year}',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: selected ?? DateTime(2000, 1, 1),
                firstDate: DateTime(1920),
                lastDate: DateTime.now(),
              );
              if (date != null) onSelect(date);
            },
            icon: const Icon(Icons.calendar_today),
            label: Text(selected == null ? (AppLocalizations.of(context)?.pickYourDate ?? 'Pick your date') : (AppLocalizations.of(context)?.changeDate ?? 'Change date')),
          ),
        ],
      ),
    );
  }
}

// ── Page 3: Height + Weight ──

class _MeasurementsPage extends StatelessWidget {
  final TextEditingController heightController;
  final TextEditingController weightController;
  final VoidCallback onNext;

  const _MeasurementsPage({
    required this.heightController,
    required this.weightController,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)?.yourMeasurements ?? 'Your measurements',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)?.storedLocallyNeverShared ?? 'Stored locally. Never shared.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: heightController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)?.heightLabel ?? 'Height',
                    hintText: '170',
                    suffixText: 'cm',
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: weightController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)?.weightLabel ?? 'Weight',
                    hintText: '70',
                    suffixText: 'kg',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onNext,
              child: Text(AppLocalizations.of(context)?.continueButton ?? 'Continue'),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onNext,
            child: Text(AppLocalizations.of(context)?.skipButton ?? 'Skip'),
          ),
        ],
      ),
    );
  }
}

// ── Page 4: Body Type ──

class _BodyTypePage extends StatelessWidget {
  final GenderIdentity? gender;
  final BodyType? selected;
  final ValueChanged<BodyType> onSelect;
  final VoidCallback onNext;

  const _BodyTypePage({
    this.gender,
    this.selected,
    required this.onSelect,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMale = gender != GenderIdentity.female;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)?.chooseYourBodyType ?? 'Choose your body type',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)?.helpsTrackWellness ?? 'This helps track your wellness journey.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.75,
              children: BodyType.values.map((bt) {
                return _BodyTypeCard(
                  bodyType: bt,
                  isMale: isMale,
                  isSelected: selected == bt,
                  onTap: () => onSelect(bt),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onNext,
              child: Text(AppLocalizations.of(context)?.nextButton ?? 'Next'),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onNext,
            child: Text(AppLocalizations.of(context)?.skipButton ?? 'Skip'),
          ),
        ],
      ),
    );
  }
}

class _BodyTypeCard extends StatelessWidget {
  final BodyType bodyType;
  final bool isMale;
  final bool isSelected;
  final VoidCallback onTap;

  const _BodyTypeCard({
    required this.bodyType,
    required this.isMale,
    required this.isSelected,
    required this.onTap,
  });

  String _label(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (bodyType) {
      case BodyType.slim:
        return l10n?.bodySlim ?? 'Slim';
      case BodyType.lean:
        return l10n?.bodyLean ?? 'Lean';
      case BodyType.athletic:
        return l10n?.bodyAthletic ?? 'Athletic';
      case BodyType.average:
        return l10n?.bodyAverage ?? 'Average';
      case BodyType.stocky:
        return l10n?.bodyStocky ?? 'Stocky';
      case BodyType.heavy:
        return l10n?.bodyHeavy ?? 'Heavy';
    }
  }

  IconData get _icon {
    if (isMale) {
      switch (bodyType) {
        case BodyType.slim:
          return Icons.accessibility_new;
        case BodyType.lean:
          return Icons.directions_run;
        case BodyType.athletic:
          return Icons.fitness_center;
        case BodyType.average:
          return Icons.person;
        case BodyType.stocky:
          return Icons.person_outline;
        case BodyType.heavy:
          return Icons.person_4;
      }
    } else {
      switch (bodyType) {
        case BodyType.slim:
          return Icons.accessibility_new;
        case BodyType.lean:
          return Icons.directions_run;
        case BodyType.athletic:
          return Icons.fitness_center;
        case BodyType.average:
          return Icons.person_2;
        case BodyType.stocky:
          return Icons.person_2_outlined;
        case BodyType.heavy:
          return Icons.person_3;
      }
    }
  }

  String _description(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (bodyType) {
      case BodyType.slim:
        return l10n?.bodySlimDesc ?? 'Narrow frame\nLight build';
      case BodyType.lean:
        return l10n?.bodyLeanDesc ?? 'Toned\nLow body fat';
      case BodyType.athletic:
        return l10n?.bodyAthleticDesc ?? 'Muscular\nFit build';
      case BodyType.average:
        return l10n?.bodyAverageDesc ?? 'Balanced\nModerate build';
      case BodyType.stocky:
        return l10n?.bodyStockyDesc ?? 'Broad\nSolid build';
      case BodyType.heavy:
        return l10n?.bodyHeavyDesc ?? 'Large frame\nFull build';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: isSelected
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _icon,
                size: 40,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 6),
              Text(
                _label(context),
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _description(context),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Page 5: Language ──

class _LanguagePage extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;

  const _LanguagePage({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🌍', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)?.chooseYourLanguage ?? 'Choose your language',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)?.selectPreferredLanguage ?? 'Select your preferred language.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 40),
          _LanguageOption(
            flag: '🇬🇧',
            label: 'English',
            value: 'en',
            selected: selected,
            onTap: () => onSelect('en'),
          ),
          const SizedBox(height: 12),
          _LanguageOption(
            flag: '🇭🇺',
            label: 'Magyar',
            value: 'hu',
            selected: selected,
            onTap: () => onSelect('hu'),
          ),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String flag;
  final String label;
  final String value;
  final String selected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.flag,
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = value == selected;

    return Material(
      color: isSelected
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 16),
              Text(
                label,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              if (isSelected)
                Icon(Icons.check_circle, color: theme.colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Page 6: Units ──

class _UnitsPage extends StatelessWidget {
  final MeasurementUnit selected;
  final ValueChanged<MeasurementUnit> onSelect;
  final Future<void> Function() onFinish;

  const _UnitsPage({
    required this.selected,
    required this.onSelect,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📏', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)?.preferredUnits ?? 'Preferred units',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)?.chooseHowYouMeasure ?? 'Choose how you measure things.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 40),
          _UnitOption(
            icon: Icons.straighten,
            label: AppLocalizations.of(context)?.metricLabel ?? 'Metric',
            subtitle: AppLocalizations.of(context)?.metricUnits ?? 'kg, cm, km, L',
            value: MeasurementUnit.metric,
            selected: selected,
            onTap: () => onSelect(MeasurementUnit.metric),
          ),
          const SizedBox(height: 12),
          _UnitOption(
            icon: Icons.square_foot,
            label: AppLocalizations.of(context)?.imperialLabel ?? 'Imperial',
            subtitle: AppLocalizations.of(context)?.imperialUnits ?? 'lbs, ft/in, mi, oz',
            value: MeasurementUnit.imperial,
            selected: selected,
            onTap: () => onSelect(MeasurementUnit.imperial),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () async {
                await onFinish();
                if (context.mounted) {
                  // If pushed from Profile, pop back; if root (first launch), Navigator handles rebuild
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                }
              },
              child: Text(AppLocalizations.of(context)?.continueButton ?? 'Get Started'),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final MeasurementUnit value;
  final MeasurementUnit selected;
  final VoidCallback onTap;

  const _UnitOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = value == selected;

    return Material(
      color: isSelected
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Row(
            children: [
              Icon(icon, size: 32,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (isSelected)
                Icon(Icons.check_circle, color: theme.colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
