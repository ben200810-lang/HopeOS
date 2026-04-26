import 'dart:convert';
import 'package:flutter/services.dart';

class KnowledgeItem {
  final String id;
  final Map<String, String> name;
  final String emoji;
  final Map<String, dynamic> extra;

  const KnowledgeItem({
    required this.id,
    required this.name,
    required this.emoji,
    this.extra = const {},
  });

  String localizedName(String locale) => name[locale] ?? name['en'] ?? id;

  factory KnowledgeItem.fromJson(Map<String, dynamic> json) {
    final nameRaw = json['name'];
    final Map<String, String> nameMap;
    if (nameRaw is Map) {
      nameMap = nameRaw.map((k, v) => MapEntry(k.toString(), v.toString()));
    } else {
      nameMap = {'en': nameRaw?.toString() ?? ''};
    }

    final extra = Map<String, dynamic>.from(json)
      ..remove('id')
      ..remove('name')
      ..remove('emoji');

    return KnowledgeItem(
      id: json['id'] as String,
      name: nameMap,
      emoji: (json['emoji'] as String?) ?? '',
      extra: extra,
    );
  }
}

class KnowledgeCategory {
  final String id;
  final Map<String, String> name;
  final String emoji;
  final List<KnowledgeItem> items;

  const KnowledgeCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.items,
  });

  String localizedName(String locale) => name[locale] ?? name['en'] ?? id;

  factory KnowledgeCategory.fromJson(Map<String, dynamic> json) {
    final nameRaw = json['name'];
    final Map<String, String> nameMap;
    if (nameRaw is Map) {
      nameMap = nameRaw.map((k, v) => MapEntry(k.toString(), v.toString()));
    } else {
      nameMap = {'en': nameRaw?.toString() ?? ''};
    }

    final rawItems = json['items'] ?? json['tags'] ?? [];
    final items = (rawItems as List)
        .map((e) => KnowledgeItem.fromJson(e as Map<String, dynamic>))
        .toList();

    return KnowledgeCategory(
      id: json['id'] as String,
      name: nameMap,
      emoji: (json['emoji'] as String?) ?? '',
      items: items,
    );
  }
}

class KnowledgeDataset {
  final List<KnowledgeCategory> categories;
  final Map<String, dynamic> raw;

  const KnowledgeDataset({required this.categories, required this.raw});
}

class KnowledgeService {
  static KnowledgeService? _instance;
  factory KnowledgeService() => _instance ??= KnowledgeService._();
  KnowledgeService._();

  KnowledgeDataset? _foods;
  KnowledgeDataset? _drinks;
  KnowledgeDataset? _activityTypes;
  Map<String, dynamic>? _sleepTypes;
  Map<String, dynamic>? _moodTags;
  Map<String, dynamic>? _adhdSymptoms;
  Map<String, dynamic>? _adhdPatterns;
  Map<String, dynamic>? _adhdStrategies;

  bool _loaded = false;
  bool get isLoaded => _loaded;

  KnowledgeDataset? get foods => _foods;
  KnowledgeDataset? get drinks => _drinks;
  KnowledgeDataset? get activityTypes => _activityTypes;
  Map<String, dynamic>? get sleepTypes => _sleepTypes;
  Map<String, dynamic>? get moodTags => _moodTags;
  Map<String, dynamic>? get adhdSymptoms => _adhdSymptoms;
  Map<String, dynamic>? get adhdPatterns => _adhdPatterns;
  Map<String, dynamic>? get adhdStrategies => _adhdStrategies;

  Future<void> initialize() async {
    if (_loaded) return;

    final results = await Future.wait([
      _loadJson('assets/knowledge/foods.json'),
      _loadJson('assets/knowledge/drinks.json'),
      _loadJson('assets/knowledge/activity_types.json'),
      _loadJson('assets/knowledge/sleep_types.json'),
      _loadJson('assets/knowledge/mood_tags.json'),
      _loadJson('assets/knowledge/adhd_symptoms.json'),
      _loadJson('assets/knowledge/adhd_patterns.json'),
      _loadJson('assets/knowledge/adhd_strategies.json'),
    ]);

    _foods = _parseDataset(results[0]);
    _drinks = _parseDataset(results[1]);
    _activityTypes = _parseDataset(results[2]);
    _sleepTypes = results[3];
    _moodTags = results[4];
    _adhdSymptoms = results[5];
    _adhdPatterns = results[6];
    _adhdStrategies = results[7];

    _loaded = true;
  }

  KnowledgeDataset _parseDataset(Map<String, dynamic> json) {
    final rawCategories = json['categories'] as List? ?? [];
    final categories = rawCategories
        .map((c) => KnowledgeCategory.fromJson(c as Map<String, dynamic>))
        .toList();
    return KnowledgeDataset(categories: categories, raw: json);
  }

  Future<Map<String, dynamic>> _loadJson(String path) async {
    final raw = await rootBundle.loadString(path);
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  List<KnowledgeItem> searchFoods(String query, {String locale = 'en'}) {
    return _searchDataset(_foods, query, locale);
  }

  List<KnowledgeItem> searchDrinks(String query, {String locale = 'en'}) {
    return _searchDataset(_drinks, query, locale);
  }

  List<KnowledgeItem> searchActivities(String query, {String locale = 'en'}) {
    return _searchDataset(_activityTypes, query, locale);
  }

  List<KnowledgeItem> _searchDataset(
      KnowledgeDataset? dataset, String query, String locale) {
    if (dataset == null || query.isEmpty) return [];
    final q = query.toLowerCase();
    final results = <KnowledgeItem>[];
    for (final cat in dataset.categories) {
      for (final item in cat.items) {
        final name = item.localizedName(locale).toLowerCase();
        if (name.contains(q)) {
          results.add(item);
        }
      }
    }
    return results;
  }

  List<KnowledgeItem> getMoodTags({String locale = 'en'}) {
    if (_moodTags == null) return [];
    final categories = _moodTags!['categories'] as List? ?? [];
    final tags = <KnowledgeItem>[];
    for (final cat in categories) {
      final rawTags = (cat as Map<String, dynamic>)['tags'] as List? ?? [];
      for (final tag in rawTags) {
        tags.add(KnowledgeItem.fromJson(tag as Map<String, dynamic>));
      }
    }
    return tags;
  }
}
