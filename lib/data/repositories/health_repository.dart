import 'dart:convert';
import '../database/database_helper.dart';
import '../models/health_entry.dart';

class HealthRepository {
  Future<HealthEntry?> getToday() async {
    final db = await DatabaseHelper.database;
    final today = DateTime.now();
    final dateStr = DateTime(today.year, today.month, today.day).toIso8601String();
    final maps = await db.query(
      'health_entries',
      where: 'date = ?',
      whereArgs: [dateStr],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return HealthEntry.fromMap(maps.first);
  }

  Future<List<HealthEntry>> getByDateRange(DateTime start, DateTime end) async {
    final db = await DatabaseHelper.database;
    final maps = await db.query(
      'health_entries',
      where: 'date >= ? AND date <= ?',
      whereArgs: [
        DateTime(start.year, start.month, start.day).toIso8601String(),
        DateTime(end.year, end.month, end.day).toIso8601String(),
      ],
      orderBy: 'date DESC',
    );
    return maps.map((map) => HealthEntry.fromMap(map)).toList();
  }

  Future<List<HealthEntry>> getRecent(int days) async {
    final now = DateTime.now();
    return getByDateRange(
      now.subtract(Duration(days: days)),
      now,
    );
  }

  Future<void> upsertToday(HealthEntry entry) async {
    final db = await DatabaseHelper.database;
    final existing = await getToday();
    if (existing != null) {
      await db.update(
        'health_entries',
        entry.toMap(),
        where: 'id = ?',
        whereArgs: [existing.id],
      );
    } else {
      await db.insert('health_entries', entry.toMap());
    }
  }

  Future<void> delete(String id) async {
    final db = await DatabaseHelper.database;
    final item = await db.query('health_entries', where: 'id = ?', whereArgs: [id]);
    if (item.isNotEmpty) {
      await db.insert('deleted_items', {
        'id': id,
        'tableName': 'health_entries',
        'data': jsonEncode(item.first),
        'deletedAt': DateTime.now().toIso8601String(),
      });
      await db.delete('health_entries', where: 'id = ?', whereArgs: [id]);
    }
  }

  Future<bool> undoDelete(String id) async {
    final db = await DatabaseHelper.database;
    final deleted = await db.query(
      'deleted_items',
      where: 'id = ? AND tableName = ?',
      whereArgs: [id, 'health_entries'],
    );
    if (deleted.isEmpty) return false;

    final data = jsonDecode(deleted.first['data'] as String) as Map<String, dynamic>;
    await db.insert('health_entries', data);
    await db.delete('deleted_items', where: 'id = ?', whereArgs: [id]);
    return true;
  }
}
