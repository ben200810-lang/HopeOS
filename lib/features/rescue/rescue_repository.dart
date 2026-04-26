import '../../data/database/database_helper.dart';
import 'rescue_event.dart';

class RescueRepository {
  Future<void> _ensureTable() async {
    final db = await DatabaseHelper.database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS rescue_events (
        id TEXT PRIMARY KEY,
        action TEXT NOT NULL,
        completedAt TEXT NOT NULL
      )
    ''');
  }

  Future<void> insert(RescueEvent event) async {
    await _ensureTable();
    final db = await DatabaseHelper.database;
    await db.insert('rescue_events', event.toMap());
  }

  Future<List<RescueEvent>> getAll() async {
    await _ensureTable();
    final db = await DatabaseHelper.database;
    final maps = await db.query(
      'rescue_events',
      orderBy: 'completedAt DESC',
    );
    return maps.map((m) => RescueEvent.fromMap(m)).toList();
  }

  Future<List<RescueEvent>> getToday() async {
    await _ensureTable();
    final db = await DatabaseHelper.database;
    final startOfDay = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final maps = await db.query(
      'rescue_events',
      where: 'completedAt >= ?',
      whereArgs: [startOfDay.toIso8601String()],
      orderBy: 'completedAt DESC',
    );
    return maps.map((m) => RescueEvent.fromMap(m)).toList();
  }
}
