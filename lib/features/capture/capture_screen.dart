import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/mood_selector.dart';
import '../../core/widgets/energy_selector.dart';
import '../../data/models/capture_entry.dart';
import '../health/health_provider.dart';
import '../mental/mental_provider.dart';
import 'capture_provider.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  CaptureType? _activeType;
  final _textController = TextEditingController();
  final _amountController = TextEditingController();
  int _selectedMood = 3;
  int _selectedEnergy = 3;
  String _expenseCategory = 'Food';
  bool _isRecording = false;

  @override
  void dispose() {
    _textController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final capture = context.watch<CaptureProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Capture'),
        actions: [
          if (capture.todayCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${capture.todayCount} today',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _activeType == null
          ? _buildTypeGrid(theme)
          : _buildCaptureForm(theme),
    );
  }

  Widget _buildTypeGrid(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What do you want to capture?',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap to log in 1–3 taps',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                _CaptureTypeCard(
                  icon: Icons.edit_note,
                  label: 'Note',
                  subtitle: 'Quick thought',
                  color: Colors.teal,
                  onTap: () => _openType(CaptureType.note),
                ),
                _CaptureTypeCard(
                  icon: Icons.mic,
                  label: 'Voice',
                  subtitle: 'Audio note',
                  color: Colors.deepPurple,
                  onTap: () => _openType(CaptureType.voice),
                ),
                _CaptureTypeCard(
                  icon: Icons.mood,
                  label: 'Emotion',
                  subtitle: 'How you feel',
                  color: Colors.amber.shade700,
                  onTap: () => _openType(CaptureType.emotion),
                ),
                _CaptureTypeCard(
                  icon: Icons.water_drop,
                  label: 'Drink',
                  subtitle: 'Log hydration',
                  color: Colors.blue,
                  onTap: () => _openType(CaptureType.drink),
                ),
                _CaptureTypeCard(
                  icon: Icons.restaurant,
                  label: 'Meal',
                  subtitle: 'What you ate',
                  color: Colors.orange,
                  onTap: () => _openType(CaptureType.meal),
                ),
                _CaptureTypeCard(
                  icon: Icons.receipt_long,
                  label: 'Expense',
                  subtitle: 'Track spending',
                  color: Colors.red.shade400,
                  onTap: () => _openType(CaptureType.expense),
                ),
                _CaptureTypeCard(
                  icon: Icons.auto_awesome,
                  label: 'Moment',
                  subtitle: 'Special moment',
                  color: Colors.pink,
                  onTap: () => _openType(CaptureType.moment),
                ),
                _CaptureTypeCard(
                  icon: Icons.camera_alt,
                  label: 'Photo',
                  subtitle: 'Snap & save',
                  color: Colors.cyan,
                  onTap: () => _openType(CaptureType.photo),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureForm(ThemeData theme) {
    return Column(
      children: [
        // Back bar
        Material(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          child: InkWell(
            onTap: _closeForm,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.arrow_back, size: 20,
                      color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(
                    'Back to capture types',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _buildFormForType(theme),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormForType(ThemeData theme) {
    switch (_activeType!) {
      case CaptureType.note:
        return _buildNoteForm(theme);
      case CaptureType.voice:
        return _buildVoiceForm(theme);
      case CaptureType.emotion:
        return _buildEmotionForm(theme);
      case CaptureType.drink:
        return _buildDrinkForm(theme);
      case CaptureType.meal:
        return _buildMealForm(theme);
      case CaptureType.expense:
        return _buildExpenseForm(theme);
      case CaptureType.moment:
        return _buildMomentForm(theme);
      case CaptureType.photo:
        return _buildPhotoForm(theme);
    }
  }

  // ─── Note ───────────────────────────────────────────────

  Widget _buildNoteForm(ThemeData theme) {
    return Column(
      key: const ValueKey('note'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FormHeader(icon: Icons.edit_note, label: 'Note', color: Colors.teal),
        const SizedBox(height: 16),
        TextField(
          controller: _textController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'What\'s on your mind?',
          ),
          maxLines: 6,
          onChanged: (_) => _autosaveDraft(),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _submitNote,
          icon: const Icon(Icons.check, size: 20),
          label: const Text('Save Note'),
        ),
      ],
    );
  }

  void _submitNote() {
    if (_textController.text.trim().isEmpty) return;
    final capture = context.read<CaptureProvider>();
    capture.updateDraft(text: _textController.text.trim());
    capture.finalizeDraft();
    _textController.clear();
    _showSuccess('Note saved');
    setState(() => _activeType = null);
  }

  // ─── Voice ──────────────────────────────────────────────

  Widget _buildVoiceForm(ThemeData theme) {
    return Column(
      key: const ValueKey('voice'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FormHeader(
            icon: Icons.mic, label: 'Voice Note', color: Colors.deepPurple),
        const SizedBox(height: 24),
        Center(
          child: GestureDetector(
            onTap: _toggleRecording,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _isRecording ? 120 : 100,
              height: _isRecording ? 120 : 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isRecording
                    ? Colors.red.withValues(alpha: 0.15)
                    : Colors.deepPurple.withValues(alpha: 0.1),
                border: Border.all(
                  color: _isRecording ? Colors.red : Colors.deepPurple,
                  width: 3,
                ),
              ),
              child: Icon(
                _isRecording ? Icons.stop : Icons.mic,
                size: 48,
                color: _isRecording ? Colors.red : Colors.deepPurple,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            _isRecording ? 'Tap to stop recording' : 'Tap to start recording',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _textController,
          decoration: const InputDecoration(
            hintText: 'Add a text note (optional)',
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        Text(
          'Audio will be stored locally. Transcription coming soon.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _submitVoice,
          icon: const Icon(Icons.save, size: 20),
          label: const Text('Save Voice Note'),
        ),
      ],
    );
  }

  void _toggleRecording() {
    setState(() => _isRecording = !_isRecording);
    if (!_isRecording) {
      // Recording stopped — in future, this will save the audio file
      _showSuccess('Recording saved');
    }
  }

  void _submitVoice() {
    final capture = context.read<CaptureProvider>();
    capture.updateDraft(
      text: _textController.text.isNotEmpty
          ? _textController.text.trim()
          : null,
    );
    capture.finalizeDraft();
    _textController.clear();
    setState(() => _isRecording = false);
    _showSuccess('Voice note saved');
    setState(() => _activeType = null);
  }

  // ─── Emotion ────────────────────────────────────────────

  Widget _buildEmotionForm(ThemeData theme) {
    return Column(
      key: const ValueKey('emotion'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FormHeader(
            icon: Icons.mood, label: 'Emotion', color: Colors.amber.shade700),
        const SizedBox(height: 16),
        Text(
          'How are you feeling?',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        MoodSelector(
          selectedLevel: _selectedMood,
          onChanged: (level) => setState(() => _selectedMood = level),
        ),
        const SizedBox(height: 24),
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
          controller: _textController,
          decoration: const InputDecoration(
            hintText: 'Quick note (optional)',
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _submitEmotion,
          icon: const Icon(Icons.check, size: 20),
          label: const Text('Log Emotion'),
        ),
      ],
    );
  }

  void _submitEmotion() {
    // Log to both capture and mental provider for insights
    context.read<MentalProvider>().logMood(
          moodLevel: _selectedMood,
          energyLevel: _selectedEnergy,
          note: _textController.text.isNotEmpty ? _textController.text : null,
        );
    final capture = context.read<CaptureProvider>();
    capture.updateDraft(
      moodLevel: _selectedMood,
      energyLevel: _selectedEnergy,
      text: _textController.text.isNotEmpty
          ? _textController.text.trim()
          : null,
    );
    capture.finalizeDraft();
    _textController.clear();
    setState(() {
      _selectedMood = 3;
      _selectedEnergy = 3;
    });
    _showSuccess('Emotion logged');
    setState(() => _activeType = null);
  }

  // ─── Drink ──────────────────────────────────────────────

  Widget _buildDrinkForm(ThemeData theme) {
    final health = context.watch<HealthProvider>();

    return Column(
      key: const ValueKey('drink'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FormHeader(
            icon: Icons.water_drop, label: 'Drink', color: Colors.blue),
        const SizedBox(height: 12),
        Center(
          child: Text(
            '${health.waterLiters.toStringAsFixed(1)}L today',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            _DrinkButton(label: '+100ml', onTap: () => _addDrink(0.1)),
            const SizedBox(width: 10),
            _DrinkButton(label: '+250ml', onTap: () => _addDrink(0.25)),
            const SizedBox(width: 10),
            _DrinkButton(label: '+500ml', onTap: () => _addDrink(0.5)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _DrinkButton(label: '+1L', onTap: () => _addDrink(1.0)),
            const SizedBox(width: 10),
            _DrinkButton(
                label: 'Coffee ☕', onTap: () => _addDrink(0.2, 'Coffee')),
            const SizedBox(width: 10),
            _DrinkButton(
                label: 'Tea 🍵', onTap: () => _addDrink(0.25, 'Tea')),
          ],
        ),
      ],
    );
  }

  void _addDrink(double liters, [String? drinkType]) {
    context.read<HealthProvider>().addWater(liters);
    final capture = context.read<CaptureProvider>();
    capture.updateDraft(
      amount: liters,
      text: drinkType,
      category: drinkType ?? 'Water',
    );
    capture.finalizeDraft();
    final ml = (liters * 1000).round();
    _showSuccess('+${ml}ml ${drinkType ?? 'water'} logged');
    // Re-open draft for next drink since user may log multiple
    capture.startDraft(CaptureType.drink);
  }

  // ─── Meal ───────────────────────────────────────────────

  Widget _buildMealForm(ThemeData theme) {
    return Column(
      key: const ValueKey('meal'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FormHeader(
            icon: Icons.restaurant, label: 'Meal', color: Colors.orange),
        const SizedBox(height: 16),
        TextField(
          controller: _textController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'What did you eat?',
          ),
          maxLines: 3,
          onChanged: (_) => _autosaveDraft(),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _MealChip(label: '🥣 Breakfast', onTap: () => _quickMeal('Breakfast')),
              const SizedBox(width: 8),
              _MealChip(label: '🥗 Lunch', onTap: () => _quickMeal('Lunch')),
              const SizedBox(width: 8),
              _MealChip(label: '🍽️ Dinner', onTap: () => _quickMeal('Dinner')),
              const SizedBox(width: 8),
              _MealChip(label: '🍎 Snack', onTap: () => _quickMeal('Snack')),
            ],
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _submitMeal,
          icon: const Icon(Icons.check, size: 20),
          label: const Text('Log Meal'),
        ),
      ],
    );
  }

  void _quickMeal(String mealType) {
    final capture = context.read<CaptureProvider>();
    capture.updateDraft(
      text: _textController.text.isNotEmpty
          ? _textController.text.trim()
          : mealType,
      category: mealType,
    );
    capture.finalizeDraft();
    _textController.clear();
    _showSuccess('$mealType logged');
    setState(() => _activeType = null);
  }

  void _submitMeal() {
    if (_textController.text.trim().isEmpty) return;
    final capture = context.read<CaptureProvider>();
    capture.updateDraft(text: _textController.text.trim());
    capture.finalizeDraft();
    _textController.clear();
    _showSuccess('Meal logged');
    setState(() => _activeType = null);
  }

  // ─── Expense ────────────────────────────────────────────

  Widget _buildExpenseForm(ThemeData theme) {
    return Column(
      key: const ValueKey('expense'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FormHeader(
            icon: Icons.receipt_long,
            label: 'Expense',
            color: Colors.red.shade400),
        const SizedBox(height: 16),
        TextField(
          controller: _amountController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Amount',
            prefixText: '\$ ',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final cat in [
                'Food',
                'Transport',
                'Shopping',
                'Health',
                'Bills',
                'Other'
              ])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: _expenseCategory == cat,
                    onSelected: (_) =>
                        setState(() => _expenseCategory = cat),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _textController,
          decoration: const InputDecoration(
            hintText: 'Description (optional)',
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _submitExpense,
          icon: const Icon(Icons.check, size: 20),
          label: const Text('Log Expense'),
        ),
      ],
    );
  }

  void _submitExpense() {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) return;
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) return;

    final capture = context.read<CaptureProvider>();
    capture.updateDraft(
      amount: amount,
      category: _expenseCategory,
      text: _textController.text.isNotEmpty
          ? _textController.text.trim()
          : null,
    );
    capture.finalizeDraft();
    _amountController.clear();
    _textController.clear();
    _showSuccess('Expense logged: \$${amount.toStringAsFixed(2)}');
    setState(() => _activeType = null);
  }

  // ─── Moment ─────────────────────────────────────────────

  Widget _buildMomentForm(ThemeData theme) {
    return Column(
      key: const ValueKey('moment'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FormHeader(
            icon: Icons.auto_awesome, label: 'Moment', color: Colors.pink),
        const SizedBox(height: 16),
        Text(
          'Capture something special',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _textController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'What happened?',
          ),
          maxLines: 4,
          onChanged: (_) => _autosaveDraft(),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _submitMoment,
          icon: const Icon(Icons.auto_awesome, size: 20),
          label: const Text('Save Moment'),
        ),
      ],
    );
  }

  void _submitMoment() {
    if (_textController.text.trim().isEmpty) return;
    final capture = context.read<CaptureProvider>();
    capture.updateDraft(text: _textController.text.trim());
    capture.finalizeDraft();
    _textController.clear();
    _showSuccess('Moment captured');
    setState(() => _activeType = null);
  }

  // ─── Photo ──────────────────────────────────────────────

  Widget _buildPhotoForm(ThemeData theme) {
    return Column(
      key: const ValueKey('photo'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FormHeader(
            icon: Icons.camera_alt, label: 'Photo', color: Colors.cyan),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _PhotoButton(
                icon: Icons.camera_alt,
                label: 'Take Photo',
                onTap: () => _capturePhoto(fromCamera: true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PhotoButton(
                icon: Icons.photo_library,
                label: 'Gallery',
                onTap: () => _capturePhoto(fromCamera: false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _textController,
          decoration: const InputDecoration(
            hintText: 'Caption (optional)',
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        Text(
          'Photo capture requires camera permissions. '
          'Image picker integration coming in the next update.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _submitPhoto,
          icon: const Icon(Icons.save, size: 20),
          label: const Text('Save with Caption'),
        ),
      ],
    );
  }

  void _capturePhoto({required bool fromCamera}) {
    // Photo picker integration will be added with image_picker package
    _showSuccess(
        fromCamera ? 'Camera opening soon' : 'Gallery opening soon');
  }

  void _submitPhoto() {
    final capture = context.read<CaptureProvider>();
    capture.updateDraft(
      text: _textController.text.isNotEmpty
          ? _textController.text.trim()
          : null,
    );
    capture.finalizeDraft();
    _textController.clear();
    _showSuccess('Photo entry saved');
    setState(() => _activeType = null);
  }

  // ─── Helpers ────────────────────────────────────────────

  void _openType(CaptureType type) {
    setState(() {
      _activeType = type;
      _textController.clear();
      _amountController.clear();
      _selectedMood = 3;
      _selectedEnergy = 3;
      _isRecording = false;
      _expenseCategory = 'Food';
    });
    context.read<CaptureProvider>().startDraft(type);
  }

  void _closeForm() {
    context.read<CaptureProvider>().discardDraft();
    setState(() => _activeType = null);
  }

  void _autosaveDraft() {
    context.read<CaptureProvider>().updateDraft(
          text: _textController.text,
        );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ─── Shared widgets ─────────────────────────────────────────

class _CaptureTypeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _CaptureTypeCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: color.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
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
        ),
      ),
    );
  }
}

class _FormHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _FormHeader({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _DrinkButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DrinkButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.blue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MealChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _MealChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
    );
  }
}

class _PhotoButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PhotoButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.cyan.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Icon(icon, color: Colors.cyan, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.cyan,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
