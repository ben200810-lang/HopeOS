import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum GenderIdentity { male, female }

enum BodyType { slim, lean, athletic, average, stocky, heavy }

enum MeasurementUnit { metric, imperial }

enum ColorMode { blue, green, purple, orange, pink, teal }

class SettingsProvider extends ChangeNotifier {
  static const _themeKey = 'theme_mode';
  static const _waterGoalKey = 'water_goal';
  static const _sleepGoalKey = 'sleep_goal';
  static const _exerciseGoalKey = 'exercise_goal';
  static const _nameKey = 'user_name';
  static const _genderKey = 'gender_identity';
  static const _birthDateKey = 'birth_date';
  static const _heightKey = 'height_cm';
  static const _weightKey = 'weight_kg';
  static const _bodyTypeKey = 'body_type';
  static const _onboardedKey = 'onboarded';
  static const _unitKey = 'measurement_unit';
  static const _currencyKey = 'currency';
  static const _notificationsKey = 'notifications_enabled';
  static const _colorModeKey = 'color_mode';
  static const _languageKey = 'language';
  static const _quickCaptureKey = 'quick_capture_enabled';
  static const _foodCategoriesKey = 'custom_food_categories';
  static const _drinkCategoriesKey = 'custom_drink_categories';

  ThemeMode _themeMode = ThemeMode.system;
  double _waterGoal = 2.5;
  double _sleepGoal = 8.0;
  int _exerciseGoal = 30;
  String _userName = '';
  GenderIdentity? _gender;
  DateTime? _birthDate;
  double? _heightCm;
  double? _weightKg;
  BodyType? _bodyType;
  bool _onboarded = false;
  MeasurementUnit _unit = MeasurementUnit.metric;
  String _currency = 'USD';
  bool _notificationsEnabled = true;
  ColorMode _colorMode = ColorMode.blue;
  String _language = 'en';
  bool _quickCaptureEnabled = false;
  List<String> _customFoodCategories = [];
  List<String> _customDrinkCategories = [];

  ThemeMode get themeMode => _themeMode;
  double get waterGoal => _waterGoal;
  double get sleepGoal => _sleepGoal;
  int get exerciseGoal => _exerciseGoal;
  String get userName => _userName;
  GenderIdentity? get gender => _gender;
  DateTime? get birthDate => _birthDate;
  double? get heightCm => _heightCm;
  double? get weightKg => _weightKg;
  BodyType? get bodyType => _bodyType;
  bool get onboarded => _onboarded;
  MeasurementUnit get unit => _unit;
  String get currency => _currency;
  bool get notificationsEnabled => _notificationsEnabled;
  ColorMode get colorMode => _colorMode;
  String get language => _language;
  bool get quickCaptureEnabled => _quickCaptureEnabled;
  List<String> get customFoodCategories => _customFoodCategories;
  List<String> get customDrinkCategories => _customDrinkCategories;

  int? get age {
    if (_birthDate == null) return null;
    final now = DateTime.now();
    int years = now.year - _birthDate!.year;
    if (now.month < _birthDate!.month ||
        (now.month == _birthDate!.month && now.day < _birthDate!.day)) {
      years--;
    }
    return years;
  }

  Color get seedColor {
    switch (_colorMode) {
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

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? 0;
    _themeMode = ThemeMode.values[themeIndex];
    _waterGoal = prefs.getDouble(_waterGoalKey) ?? 2.5;
    _sleepGoal = prefs.getDouble(_sleepGoalKey) ?? 8.0;
    _exerciseGoal = prefs.getInt(_exerciseGoalKey) ?? 30;
    _userName = prefs.getString(_nameKey) ?? '';
    _onboarded = prefs.getBool(_onboardedKey) ?? false;
    _notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;
    _currency = prefs.getString(_currencyKey) ?? 'USD';

    final genderIndex = prefs.getInt(_genderKey);
    _gender = genderIndex != null ? GenderIdentity.values[genderIndex] : null;

    final birthStr = prefs.getString(_birthDateKey);
    _birthDate = birthStr != null ? DateTime.tryParse(birthStr) : null;

    _heightCm = prefs.getDouble(_heightKey);
    _weightKg = prefs.getDouble(_weightKey);

    final bodyIndex = prefs.getInt(_bodyTypeKey);
    _bodyType = bodyIndex != null ? BodyType.values[bodyIndex] : null;

    final unitIndex = prefs.getInt(_unitKey);
    _unit = unitIndex != null
        ? MeasurementUnit.values[unitIndex]
        : MeasurementUnit.metric;

    final colorIndex = prefs.getInt(_colorModeKey);
    _colorMode =
        colorIndex != null ? ColorMode.values[colorIndex] : ColorMode.blue;

    _language = prefs.getString(_languageKey) ?? 'en';
    _quickCaptureEnabled = prefs.getBool(_quickCaptureKey) ?? false;

    final foodCats = prefs.getStringList(_foodCategoriesKey);
    _customFoodCategories = foodCats ?? [];

    final drinkCats = prefs.getStringList(_drinkCategoriesKey);
    _customDrinkCategories = drinkCats ?? [];

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
    notifyListeners();
  }

  Future<void> setWaterGoal(double goal) async {
    _waterGoal = goal;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_waterGoalKey, goal);
    notifyListeners();
  }

  Future<void> setSleepGoal(double goal) async {
    _sleepGoal = goal;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_sleepGoalKey, goal);
    notifyListeners();
  }

  Future<void> setExerciseGoal(int goal) async {
    _exerciseGoal = goal;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_exerciseGoalKey, goal);
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    _userName = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
    notifyListeners();
  }

  Future<void> setGender(GenderIdentity gender) async {
    _gender = gender;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_genderKey, gender.index);
    notifyListeners();
  }

  Future<void> setBirthDate(DateTime date) async {
    _birthDate = date;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_birthDateKey, date.toIso8601String());
    notifyListeners();
  }

  Future<void> setHeight(double cm) async {
    _heightCm = cm;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_heightKey, cm);
    notifyListeners();
  }

  Future<void> setWeight(double kg) async {
    _weightKg = kg;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_weightKey, kg);
    notifyListeners();
  }

  Future<void> setBodyType(BodyType type) async {
    _bodyType = type;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_bodyTypeKey, type.index);
    notifyListeners();
  }

  Future<void> setOnboarded(bool value) async {
    _onboarded = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardedKey, value);
    notifyListeners();
  }

  Future<void> setMeasurementUnit(MeasurementUnit unit) async {
    _unit = unit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_unitKey, unit.index);
    notifyListeners();
  }

  Future<void> setCurrency(String currency) async {
    _currency = currency;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, currency);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, enabled);
    notifyListeners();
  }

  Future<void> setColorMode(ColorMode mode) async {
    _colorMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_colorModeKey, mode.index);
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, lang);
    notifyListeners();
  }

  Future<void> setQuickCaptureEnabled(bool enabled) async {
    _quickCaptureEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_quickCaptureKey, enabled);
    notifyListeners();
  }

  Future<void> setCustomFoodCategories(List<String> categories) async {
    _customFoodCategories = categories;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_foodCategoriesKey, categories);
    notifyListeners();
  }

  Future<void> setCustomDrinkCategories(List<String> categories) async {
    _customDrinkCategories = categories;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_drinkCategoriesKey, categories);
    notifyListeners();
  }
}
