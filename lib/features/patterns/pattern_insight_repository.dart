import '../../data/database/database_helper.dart';
import 'pattern_insight.dart';

class PatternInsightRepository {
  static const _tableName = 'pattern_insights';

  Future<void> _ensureTable() async {
    final db = await DatabaseHelper.database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName (
        id TEXT PRIMARY KEY,
        titleEn TEXT NOT NULL,
        titleHu TEXT NOT NULL,
        descriptionEn TEXT NOT NULL,
        descriptionHu TEXT NOT NULL,
        confidence REAL NOT NULL,
        correlationStrength REAL NOT NULL DEFAULT 0.0,
        relatedSignals TEXT NOT NULL,
        domain TEXT NOT NULL,
        severity TEXT NOT NULL,
        analysisDate TEXT NOT NULL,
        dataPoints INTEGER NOT NULL,
        timeRangeDays INTEGER NOT NULL DEFAULT 7,
        actionSuggestionEn TEXT,
        actionSuggestionHu TEXT
      )
    ''');
    // Add new columns if table existed before v2
    try {
      await db.execute('ALTER TABLE $_tableName ADD COLUMN correlationStrength REAL NOT NULL DEFAULT 0.0');
    } catch (_) {}
    try {
      await db.execute('ALTER TABLE $_tableName ADD COLUMN timeRangeDays INTEGER NOT NULL DEFAULT 7');
    } catch (_) {}
    try {
      await db.execute('ALTER TABLE $_tableName ADD COLUMN actionSuggestionEn TEXT');
    } catch (_) {}
    try {
      await db.execute('ALTER TABLE $_tableName ADD COLUMN actionSuggestionHu TEXT');
    } catch (_) {}
  }

  Future<List<PatternInsight>> getAll() async {
    await _ensureTable();
    final db = await DatabaseHelper.database;
    final maps = await db.query(
      _tableName,
      orderBy: 'confidence DESC',
    );
    return maps.map((m) => PatternInsight.fromMap(m)).toList();
  }

  Future<void> replaceAll(List<PatternInsight> insights) async {
    await _ensureTable();
    final db = await DatabaseHelper.database;
    await db.transaction((txn) async {
      await txn.delete(_tableName);
      for (final insight in insights) {
        await txn.insert(_tableName, insight.toMap());
      }
    });
  }

  Future<void> clear() async {
    await _ensureTable();
    final db = await DatabaseHelper.database;
    await db.delete(_tableName);
  }
}
