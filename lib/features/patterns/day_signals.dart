/// Aggregated signals for a single calendar day.
///
/// Used by all pattern analyzer modules as input data.
class DaySignals {
  final DateTime date;
  double sleepHours;
  double waterLiters;
  int exerciseMinutes;
  int steps;
  List<int> moodLevels;
  List<int> energyLevels;
  int noteCount;
  List<int> noteHours;
  int expenseCount;
  double totalExpenses;
  int drinkCount;

  DaySignals({required this.date})
      : sleepHours = 0,
        waterLiters = 0,
        exerciseMinutes = 0,
        steps = 0,
        moodLevels = [],
        energyLevels = [],
        noteCount = 0,
        noteHours = [],
        expenseCount = 0,
        totalExpenses = 0,
        drinkCount = 0;

  double get avgMood =>
      moodLevels.isEmpty ? 0 : moodLevels.reduce((a, b) => a + b) / moodLevels.length;

  double get avgEnergy =>
      energyLevels.isEmpty ? 0 : energyLevels.reduce((a, b) => a + b) / energyLevels.length;

  bool get hasMood => moodLevels.isNotEmpty;
  bool get hasEnergy => energyLevels.isNotEmpty;
  bool get hasSleep => sleepHours > 0;
  bool get hasActivity => exerciseMinutes > 0 || steps > 0;
  bool get hasHydration => waterLiters > 0;
  bool get hasFinance => expenseCount > 0;
  bool get hasNotes => noteCount > 0;
}

/// A pair of correlated values for Pearson calculation.
class CorrelationPair {
  final double x;
  final double y;
  const CorrelationPair(this.x, this.y);
}
