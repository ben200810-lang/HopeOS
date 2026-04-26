import 'dart:convert';
import '../database/database_helper.dart';
import '../models/mood_entry.dart';

class MoodRepository {
  Future<List<MoodEntry>> getAll() async {
    final db = await DatabaseHelper.database;
    final maps = await db.query('mood_entries', orderBy: 'createdAt DESC');
    return maps.map((map) => MoodEntry.fromMap(map)).toList();
  }

  Future<List<MoodEntry>> getToday() async {
    final db = await DatabaseHelper.database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day).toIso8601String();
    final maps = await db.query(
      'mood_entries',
      where: 'createdAt >= ?',
      whereArgs: [startOfDay],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => MoodEntry.fromMap(map)).toList();
  }

  Future<List<MoodEntry>> getByDateRange(DateTime start, DateTime end) async {
    final db = await DatabaseHelper.database;
    final maps = await db.query(
      'mood_entries',
      where: 'createdAt >= ? AND createdAt <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => MoodEntry.fromMap(map)).toList();
  }

  Future<MoodEntry?> getLatest() async {
    final db = await DatabaseHelper.database;
    final maps = await db.query(
      'mood_entries',
      orderBy: 'createdAt DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return MoodEntry.fromMap(maps.first);
  }

  Future<void> insert(MoodEntry entry) async {
    final db = await DatabaseHelper.database;
    await db.insert('mood_entries', entry.toMap());
  }

  Future<void> update(MoodEntry entry) async {
    final db = await DatabaseHelper.database;
    await db.update(
      'mood_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await DatabaseHelper.database;
    final item = await db.query('mood_entries', where: 'id = ?', whereArgs: [id]);
    if (item.isNotEmpty) {
      await db.insert('deleted_items', {
        'id': id,
        'tableName': 'mood_entries',
        'data': jsonEncode(item.first),
        'deletedAt': DateTime.now().toIso8601String(),
      });
      await db.delete('mood_entries', where: 'id = ?', whereArgs: [id]);
    }
  }

  Future<bool> undoDelete(String id) async {
    final db = await DatabaseHelper.database;
    final deleted = await db.query(
      'deleted_items',
      where: 'id = ? AND tableName = ?',
      whereArgs: [id, 'mood_entries'],
    );
    if (deleted.isEmpty) return false;

    final data = jsonDecode(deleted.first['data'] as String) as Map<String, dynamic>;
    await db.insert('mood_entries', data);
    await db.delete('deleted_items', where: 'id = ?', whereArgs: [id]);
    return true;
  }

  Future<double> getAverageMood(int days) async {
    final db = await DatabaseHelper.database;
    final startDate = DateTime.now().subtract(Duration(days: days)).toIso8601String();
    final result = await db.rawQuery(
      'SELECT AVG(moodLevel) as avg FROM mood_entries WHERE createdAt >= ?',
      [startDate],
    );
    return (result.first['avg'] as num?)?.toDouble() ?? 0;
  }
}
