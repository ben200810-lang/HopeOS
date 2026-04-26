import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/date_utils.dart';
import '../../core/widgets/hope_card.dart';
import '../../core/widgets/mood_selector.dart';
import '../../core/widgets/energy_selector.dart';
import 'mental_provider.dart';

class MentalScreen extends StatefulWidget {
  const MentalScreen({super.key});

  @override
  State<MentalScreen> createState() => _MentalScreenState();
}

class _MentalScreenState extends State<MentalScreen> {
  int _selectedMood = 3;
  int _selectedEnergy = 3;
  final _noteController = TextEditingController();
  bool _showLogForm = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mental = context.watch<MentalProvider>();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          floating: true,
          title: const Text('Mental State'),
          actions: [
            IconButton(
              icon: Icon(_showLogForm ? Icons.close : Icons.add),
              onPressed: () => setState(() => _showLogForm = !_showLogForm),
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Quick log form (shown by default for action-first)
              if (_showLogForm || mental.todayEntries.isEmpty) ...[
                _buildLogForm(context, theme, mental),
                const SizedBox(height: 16),
              ],

              // Weekly average
              if (mental.weeklyAverage > 0) ...[
                HopeCard(
                  child: Row(
                    children: [
                      Icon(Icons.trending_up,
                          color: theme.colorScheme.primary, size: 28),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '7-day mood average',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            '${mental.weeklyAverage.toStringAsFixed(1)} / 5.0',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Today's entries
              if (mental.todayEntries.isNotEmpty) ...[
                Text(
                  'Today',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...mental.todayEntries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildMoodCard(context, theme, entry, mental),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // History
              if (mental.recentEntries.isNotEmpty) ...[
                Text(
                  'History',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...mental.recentEntries
                    .where((e) => !AppDateUtils.isToday(e.createdAt))
                    .take(20)
                    .map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child:
                            _buildMoodCard(context, theme, entry, mental),
                      ),
                    ),
              ],

              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildLogForm(
      BuildContext context, ThemeData theme, MentalProvider mental) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
            theme.colorScheme.tertiaryContainer.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How are you feeling?',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          MoodSelector(
            selectedLevel: _selectedMood,
            onChanged: (level) => setState(() => _selectedMood = level),
          ),
          const SizedBox(height: 20),
          Text(
            'Energy level',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          EnergySelector(
            selectedLevel: _selectedEnergy,
            onChanged: (level) => setState(() => _selectedEnergy = level),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              hintText: 'Quick note (optional)',
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () async {
                await mental.logMood(
                  moodLevel: _selectedMood,
                  energyLevel: _selectedEnergy,
                  note: _noteController.text.isNotEmpty
                      ? _noteController.text
                      : null,
                );
                _noteController.clear();
                setState(() {
                  _selectedMood = 3;
                  _selectedEnergy = 3;
                  _showLogForm = false;
                });
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Mood logged'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('Log Mood'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodCard(BuildContext context, ThemeData theme,
      dynamic entry, MentalProvider mental) {
    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      onDismissed: (_) async {
        final id = await mental.deleteEntry(entry.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Entry deleted'),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () => mental.undoDelete(id),
              ),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      },
      child: HopeCard(
        child: Row(
          children: [
            Text(
              entry.moodEmoji,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Mood ${entry.moodLevel}/5',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        entry.energyEmoji,
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        ' ${entry.energyLevel}/5',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  if (entry.note != null)
                    Text(
                      entry.note!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Text(
              AppDateUtils.timeAgo(entry.createdAt),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
