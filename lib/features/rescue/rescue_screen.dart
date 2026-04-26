import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hopeos/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

import 'rescue_event.dart';
import 'rescue_repository.dart';

class _MicroAction {
  final String label;
  final IconData icon;

  const _MicroAction(this.label, this.icon);
}

const _allActions = [
  _MicroAction('Drink something', Icons.water_drop),
  _MicroAction('Walk for 2 minutes', Icons.directions_walk),
  _MicroAction('Write one sentence', Icons.edit),
  _MicroAction('Take 5 deep breaths', Icons.self_improvement),
  _MicroAction('Stretch', Icons.accessibility_new),
  _MicroAction('Look outside', Icons.visibility),
  _MicroAction('Wash your face', Icons.wash),
  _MicroAction('Put on your favourite song', Icons.music_note),
  _MicroAction('Tidy one small thing', Icons.cleaning_services),
  _MicroAction('Say one thing you\'re grateful for', Icons.favorite),
];

class RescueScreen extends StatefulWidget {
  const RescueScreen({super.key});

  @override
  State<RescueScreen> createState() => _RescueScreenState();
}

class _RescueScreenState extends State<RescueScreen>
    with TickerProviderStateMixin {
  late List<_MicroAction> _actions;
  final Set<int> _completed = {};
  final RescueRepository _repository = RescueRepository();

  bool _showSuccess = false;
  Timer? _hideTimer;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _pickActions();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  void _pickActions() {
    final rng = Random();
    final shuffled = List<_MicroAction>.from(_allActions)..shuffle(rng);
    _actions = shuffled.take(3).toList();
  }

  Future<void> _onComplete(int index) async {
    if (_completed.contains(index)) return;

    final action = _actions[index];

    final event = RescueEvent(
      id: const Uuid().v4(),
      action: action.label,
      completedAt: DateTime.now(),
    );
    await _repository.insert(event);

    setState(() {
      _completed.add(index);
      _showSuccess = true;
    });

    _fadeController.forward(from: 0);

    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _showSuccess = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(AppLocalizations.of(context)?.rescueMode ?? 'Rescue Mode'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),

              Text(
                AppLocalizations.of(context)?.letsRestart ?? 'Let\u2019s restart with one small step.',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                'Pick one. That\u2019s enough.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              ...List.generate(_actions.length, (i) {
                final action = _actions[i];
                final done = _completed.contains(i);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _RescueCard(
                    action: action,
                    done: done,
                    onTap: () => _onComplete(i),
                  ),
                );
              }),

              const Spacer(),

              // Dopamine feedback
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: _showSuccess
                    ? FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.bolt,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                AppLocalizations.of(context)?.niceMomentumStarted ?? 'Nice. Momentum started.',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _RescueCard extends StatelessWidget {
  final _MicroAction action;
  final bool done;
  final VoidCallback onTap;

  const _RescueCard({
    required this.action,
    required this.done,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: done
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.6)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: done
            ? Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.4))
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: done ? null : onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: done
                      ? Icon(
                          Icons.check_circle,
                          key: const ValueKey('done'),
                          size: 36,
                          color: theme.colorScheme.primary,
                        )
                      : Icon(
                          action.icon,
                          key: const ValueKey('icon'),
                          size: 36,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    action.label,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: done ? TextDecoration.lineThrough : null,
                      color: done
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
