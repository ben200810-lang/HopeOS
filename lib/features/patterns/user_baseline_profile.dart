import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Rolling baseline of a user's typical daily metrics.
///
/// Updated weekly so pattern insights can compare current behavior
/// against the user's own normal range.
class UserBaselineProfile {
  final double averageSleep;
  final double averageMood;
  final double averageEnergy;
  final int averageSteps;
  final double averageHydration;
  final String lastUpdated;

  const UserBaselineProfile({
    required this.averageSleep,
    required this.averageMood,
    required this.averageEnergy,
    required this.averageSteps,
    required this.averageHydration,
    required this.lastUpdated,
  });

  static const _prefsKey = 'user_baseline_profile';
  static const _updateIntervalDays = 7;

  Map<String, dynamic> toMap() => {
        'averageSleep': averageSleep,
        'averageMood': averageMood,
        'averageEnergy': averageEnergy,
        'averageSteps': averageSteps,
        'averageHydration': averageHydration,
        'lastUpdated': lastUpdated,
      };

  factory UserBaselineProfile.fromMap(Map<String, dynamic> map) {
    return UserBaselineProfile(
      averageSleep: (map['averageSleep'] as num).toDouble(),
      averageMood: (map['averageMood'] as num).toDouble(),
      averageEnergy: (map['averageEnergy'] as num).toDouble(),
      averageSteps: (map['averageSteps'] as num).toInt(),
      averageHydration: (map['averageHydration'] as num).toDouble(),
      lastUpdated: map['lastUpdated'] as String,
    );
  }

  static Future<UserBaselineProfile?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_prefsKey);
    if (json == null) return null;
    return UserBaselineProfile.fromMap(
      Map<String, dynamic>.from(jsonDecode(json) as Map),
    );
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(toMap()));
  }

  static bool needsUpdate(UserBaselineProfile? current) {
    if (current == null) return true;
    final lastDate = DateTime.tryParse(current.lastUpdated);
    if (lastDate == null) return true;
    return DateTime.now().difference(lastDate).inDays >= _updateIntervalDays;
  }

  double sleepDeviation(double currentSleep) =>
      currentSleep - averageSleep;

  double moodDeviation(double currentMood) =>
      currentMood - averageMood;

  double energyDeviation(double currentEnergy) =>
      currentEnergy - averageEnergy;

  double stepsDeviation(int currentSteps) =>
      (currentSteps - averageSteps).toDouble();

  double hydrationDeviation(double currentHydration) =>
      currentHydration - averageHydration;
}
