import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hopeos/l10n/app_localizations.dart';
import '../rescue/rescue_screen.dart';

class HelpFloatingButton extends StatelessWidget {
  const HelpFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned(
      bottom: 80,
      right: 16,
      child: _HelpButton(theme: theme),
    );
  }
}

class _HelpButton extends StatelessWidget {
  final ThemeData theme;

  const _HelpButton({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(20),
      elevation: 1,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HelpScreen()),
        ),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Icon(
            Icons.favorite_border,
            size: 18,
            color: theme.colorScheme.onTertiaryContainer,
          ),
        ),
      ),
    );
  }
}

// ── Help Screen ──

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.iNeedHelp ?? 'I need help'),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            AppLocalizations.of(context)?.itsOkayToNeedHelp ?? 'It\'s okay to need help.',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context)?.chooseWhatFeelsRight ?? 'Choose what feels right for you right now.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),

          // ── Rescue Mode ──
          _HelpCategory(
            icon: Icons.flash_on,
            title: AppLocalizations.of(context)?.rescueMode ?? 'Rescue Mode',
            subtitle: AppLocalizations.of(context)?.oneSmallStepToRestart ?? 'One small step to restart momentum',
            color: Colors.deepPurple,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RescueScreen()),
            ),
          ),
          const SizedBox(height: 14),

          // ── Motivation ──
          _HelpCategory(
            icon: Icons.local_fire_department,
            title: 'Motivation',
            subtitle: 'A warm push when you need it',
            color: Colors.orange,
            onTap: () => _showResponse(context, _motivation),
          ),
          const SizedBox(height: 14),

          // ── Reality Check ──
          _HelpCategory(
            icon: Icons.visibility,
            title: 'Reality Check',
            subtitle: 'Honest perspective without judgment',
            color: Colors.blue,
            onTap: () => _showResponse(context, _realityCheck),
          ),
          const SizedBox(height: 14),

          // ── Small Next Step ──
          _HelpCategory(
            icon: Icons.directions_walk,
            title: 'Small Next Step',
            subtitle: 'Just one tiny thing you can do right now',
            color: Colors.green,
            onTap: () => _showResponse(context, _nextStep),
          ),
          const SizedBox(height: 14),

          // ── Reflection Prompt ──
          _HelpCategory(
            icon: Icons.psychology,
            title: 'Reflection Prompt',
            subtitle: 'A question to help you think clearly',
            color: Colors.purple,
            onTap: () => _showResponse(context, _reflection),
          ),
          const SizedBox(height: 14),

          // ── Calm Down ──
          _HelpCategory(
            icon: Icons.self_improvement,
            title: 'I Need to Calm Down',
            subtitle: 'Breathing exercises and grounding',
            color: Colors.teal,
            onTap: () => _showBreathing(context),
          ),
          const SizedBox(height: 14),

          // ── No Energy ──
          _HelpCategory(
            icon: Icons.battery_1_bar,
            title: 'I Have No Energy',
            subtitle: 'Gentle suggestions for low days',
            color: Colors.red.shade400,
            onTap: () => _showResponse(context, _lowEnergy),
          ),
          const SizedBox(height: 14),

          // ── Can't Focus ──
          _HelpCategory(
            icon: Icons.track_changes,
            title: 'I Can\'t Focus',
            subtitle: 'ADHD-friendly strategies',
            color: Colors.indigo,
            onTap: () => _showResponse(context, _focus),
          ),

          const SizedBox(height: 28),

          // Crisis resources
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.phone, color: theme.colorScheme.error, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Crisis Resources',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'If you are in crisis, please reach out:\n'
                  '988 Suicide & Crisis Lifeline: Call or text 988\n'
                  'Crisis Text Line: Text HOME to 741741',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showResponse(BuildContext context, List<_HelpMessage> messages) {
    final random = Random();
    final msg = messages[random.nextInt(messages.length)];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                msg.emoji,
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 16),
              Text(
                msg.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                msg.body,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showResponse(context, messages);
                    },
                    child: Text(AppLocalizations.of(context)?.anotherOne ?? 'Another one'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(AppLocalizations.of(context)?.thankYou ?? 'Thank you'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBreathing(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _BreathingScreen()),
    );
  }
}

// ── Breathing Exercise Screen ──

class _BreathingScreen extends StatefulWidget {
  const _BreathingScreen();

  @override
  State<_BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<_BreathingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _phase = 'Breathe In';
  int _seconds = 4;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 19), // 4 + 7 + 8
    )..addListener(() {
        final progress = _controller.value * 19;
        if (progress < 4) {
          if (_phase != 'Breathe In') setState(() => _phase = 'Breathe In');
          setState(() => _seconds = 4 - progress.floor());
        } else if (progress < 11) {
          if (_phase != 'Hold') setState(() => _phase = 'Hold');
          setState(() => _seconds = 11 - progress.floor());
        } else {
          if (_phase != 'Breathe Out') setState(() => _phase = 'Breathe Out');
          setState(() => _seconds = 19 - progress.floor());
        }
      });
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)?.breathing ?? 'Breathing')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (ctx, child) {
                final scale = _phase == 'Breathe In'
                    ? 0.6 + (_controller.value * 19 / 4).clamp(0.0, 1.0) * 0.4
                    : _phase == 'Hold'
                        ? 1.0
                        : 1.0 -
                            ((_controller.value * 19 - 11) / 8)
                                    .clamp(0.0, 1.0) *
                                0.4;
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$_seconds',
                        style: theme.textTheme.displayLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            Text(
              _phase,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '4-7-8 Technique',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 48),
            Text(
              'You\'re safe. This moment will pass.',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Help Category Card ──

class _HelpCategory extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _HelpCategory({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Help Message Data ──

class _HelpMessage {
  final String emoji;
  final String title;
  final String body;

  const _HelpMessage(this.emoji, this.title, this.body);
}

const _motivation = [
  _HelpMessage(
    '🔥',
    'You showed up.',
    'That already counts. Most people don\'t even get this far. '
        'The hardest part is starting — and you just did it.',
  ),
  _HelpMessage(
    '🌱',
    'Growth is invisible.',
    'You can\'t see roots growing underground, but they\'re building '
        'the foundation. Your effort today matters, even if you can\'t see it yet.',
  ),
  _HelpMessage(
    '💪',
    'Imperfect action beats perfect plans.',
    'Don\'t wait until you feel ready. Do one messy, imperfect thing. '
        'That\'s how real progress happens.',
  ),
  _HelpMessage(
    '⭐',
    'You\'re further than you think.',
    'Look back at where you were a month ago. A year ago. '
        'You\'ve been quietly getting stronger this whole time.',
  ),
  _HelpMessage(
    '🌊',
    'Waves don\'t stop the ocean.',
    'Setbacks don\'t undo your progress. They\'re just waves. '
        'The tide is still rising.',
  ),
];

const _realityCheck = [
  _HelpMessage(
    '🪞',
    'What\'s actually urgent?',
    'Most things that feel urgent aren\'t. Ask yourself: '
        'will this matter in a week? If not, it can wait.',
  ),
  _HelpMessage(
    '📊',
    'You\'re not behind.',
    'You\'re comparing your chapter 3 to someone else\'s chapter 20. '
        'Your timeline is your own.',
  ),
  _HelpMessage(
    '🎯',
    'Done > Perfect.',
    'That thing you\'ve been avoiding? A mediocre version of it '
        'is better than the perfect version that never exists.',
  ),
  _HelpMessage(
    '🧊',
    'Feelings aren\'t facts.',
    'Feeling overwhelmed doesn\'t mean you are overwhelmed. '
        'Take a breath. List what\'s actually on your plate.',
  ),
  _HelpMessage(
    '⏳',
    'You don\'t need more time.',
    'You need fewer priorities. Pick the one thing that matters most '
        'today and let the rest go.',
  ),
];

const _nextStep = [
  _HelpMessage(
    '👟',
    'Stand up.',
    'Literally, just stand up from where you are. Stretch your arms above '
        'your head. Take one deep breath. That\'s step one.',
  ),
  _HelpMessage(
    '💧',
    'Drink something.',
    'Get a glass of water. Your brain is 75% water and it might just be '
        'thirsty. Hydrate, then decide what\'s next.',
  ),
  _HelpMessage(
    '📝',
    'Write one sentence.',
    'Open your journal and write just one sentence about how you feel right now. '
        'That\'s it. No pressure to write more.',
  ),
  _HelpMessage(
    '🕐',
    'Set a 5-minute timer.',
    'Pick the smallest task you can think of. Do it for 5 minutes. '
        'When the timer goes off, you can stop. Or not.',
  ),
  _HelpMessage(
    '🌤️',
    'Look out a window.',
    'Take 30 seconds to look at the sky. Notice the light. '
        'Your brain needs a context switch.',
  ),
];

const _reflection = [
  _HelpMessage(
    '🤔',
    'What would you tell a friend?',
    'If your best friend was feeling exactly like you are right now, '
        'what would you say to them? Say that to yourself.',
  ),
  _HelpMessage(
    '🌟',
    'What went right today?',
    'Name one thing — even tiny — that went okay today. '
        'Your brain is wired to remember the bad. Help it notice the good.',
  ),
  _HelpMessage(
    '🔄',
    'What pattern are you in?',
    'Are you stuck in a loop? Scrolling, avoiding, worrying? '
        'Notice it without judgment. Naming a pattern weakens its grip.',
  ),
  _HelpMessage(
    '🎁',
    'What do you need right now?',
    'Not what you should do. What do you actually need? '
        'Rest? Connection? Movement? Food? Trust that answer.',
  ),
  _HelpMessage(
    '🌙',
    'What can you let go of today?',
    'Pick one expectation, one task, one worry — and give yourself '
        'permission to drop it. Just for today.',
  ),
];

const _lowEnergy = [
  _HelpMessage(
    '🛋️',
    'Rest is not laziness.',
    'Your body is asking for something. Honor that. '
        'Lie down for 10 minutes without guilt. Set an alarm if you need to.',
  ),
  _HelpMessage(
    '🍎',
    'Eat something gentle.',
    'When was your last meal? Low energy often means low fuel. '
        'Even a banana or some crackers can shift how you feel.',
  ),
  _HelpMessage(
    '☀️',
    'Get 2 minutes of light.',
    'Step outside or open a curtain. Sunlight tells your brain it\'s daytime. '
        'Even on cloudy days, outdoor light helps.',
  ),
];

const _focus = [
  _HelpMessage(
    '🎧',
    'Change your input.',
    'Put on background music, white noise, or nature sounds. '
        'ADHD brains often focus better with ambient stimulation.',
  ),
  _HelpMessage(
    '📱',
    'Remove one distraction.',
    'Put your phone in another room. Close one tab. '
        'You don\'t need to remove all distractions — just one.',
  ),
  _HelpMessage(
    '🏃',
    'Move your body first.',
    'Do 20 jumping jacks or walk around the block. '
        'Physical movement primes the ADHD brain for focus.',
  ),
  _HelpMessage(
    '📋',
    'Write your distraction down.',
    'When a random thought pops up, write it on a "later" list. '
        'Then go back to what you were doing. Your brain just needs to know it won\'t be forgotten.',
  ),
];
