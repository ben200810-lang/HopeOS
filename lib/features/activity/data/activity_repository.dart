import 'package:sqflite/sqflite.dart';
import '../../../data/database/database_helper.dart';
import '../domain/activity_entry.dart';

class DailyHealthSummary {
  final String date;
  final int steps;
  final double distanceKm;
  final int activeMinutes;

  const DailyHealthSummary({
    required this.date,
    required this.steps,
    required this.distanceKm,
    required this.activeMinutes,
  });

  Map<String, dynamic> toMap() => {
        'date': date,
        'steps_today': steps,
        'distance_today_km': distanceKm,
        'active_minutes_today': activeMinutes,
      };

  factory DailyHealthSummary.fromMap(Map<String, dynamic> map) {
    return DailyHealthSummary(
      date: map['date'] as String,
      steps: map['steps_today'] as int,
      distanceKm: (map['distance_today_km'] as num).toDouble(),
      activeMinutes: map['active_minutes_today'] as int,
    );
  }
}

class ActivityRepository {
  Future<List<ActivityEntry>> getAll() async {
    final db = await DatabaseHelper.database;

    await _ensureTable(db);

    final maps = await db.query(
      'activity_entries',
      orderBy: 'startTime DESC',
    );
    return maps.map((m) => ActivityEntry.fromMap(m)).toList();
  }

  Future<List<ActivityEntry>> getByDateRange(
      DateTime start, DateTime end) async {
    final db = await DatabaseHelper.database;
    await _ensureTable(db);

    final maps = await db.query(
      'activity_entries',
      where: 'startTime >= ? AND startTime <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'startTime DESC',
    );
    return maps.map((m) => ActivityEntry.fromMap(m)).toList();
  }

  Future<void> insert(ActivityEntry entry) async {
    final db = await DatabaseHelper.database;
    await _ensureTable(db);
    await db.insert('activity_entries', entry.toMap());
  }

  Future<void> insertAll(List<ActivityEntry> entries) async {
    final db = await DatabaseHelper.database;
    await _ensureTable(db);
    final batch = db.batch();
    for (final entry in entries) {
      batch.insert('activity_entries', entry.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<void> delete(String id) async {
    final db = await DatabaseHelper.database;
    await _ensureTable(db);
    await db.delete('activity_entries', where: 'id = ?', whereArgs: [id]);
  }

  // ── Daily Health Summary ──

  Future<void> upsertDailySummary(DailyHealthSummary summary) async {
    final db = await DatabaseHelper.database;
    await _ensureSummaryTable(db);
    await db.insert(
      'daily_health_summary',
      summary.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<DailyHealthSummary?> getDailySummary(String date) async {
    final db = await DatabaseHelper.database;
    await _ensureSummaryTable(db);
    final maps = await db.query(
      'daily_health_summary',
      where: 'date = ?',
      whereArgs: [date],
    );
    if (maps.isEmpty) return null;
    return DailyHealthSummary.fromMap(maps.first);
  }

  Future<List<DailyHealthSummary>> getSummariesInRange(
      String startDate, String endDate) async {
    final db = await DatabaseHelper.database;
    await _ensureSummaryTable(db);
    final maps = await db.query(
      'daily_health_summary',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate, endDate],
      orderBy: 'date ASC',
    );
    return maps.map((m) => DailyHealthSummary.fromMap(m)).toList();
  }

  Future<void> _ensureTable(dynamic db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS activity_entries (
        id TEXT PRIMARY KEY,
        activityType TEXT NOT NULL,
        durationMinutes INTEGER NOT NULL,
        steps INTEGER,
        distanceMeters REAL,
        caloriesBurned INTEGER,
        source TEXT NOT NULL DEFAULT 'manual',
        startTime TEXT NOT NULL,
        endTime TEXT,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  Future<void> _ensureSummaryTable(dynamic db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS daily_health_summary (
        date TEXT PRIMARY KEY,
        steps_today INTEGER NOT NULL DEFAULT 0,
        distance_today_km REAL NOT NULL DEFAULT 0.0,
        active_minutes_today INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }
}
