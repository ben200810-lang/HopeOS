import '../../../data/database/database_helper.dart';
import '../domain/activity_entry.dart';

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
}
