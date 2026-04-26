import 'dart:convert';
import '../database/database_helper.dart';
import '../models/capture_entry.dart';

class CaptureRepository {
  Future<List<CaptureEntry>> getAll() async {
    final db = await DatabaseHelper.database;
    final maps = await db.query('captures', orderBy: 'createdAt DESC');
    return maps.map((map) => CaptureEntry.fromMap(map)).toList();
  }

  Future<List<CaptureEntry>> getByType(CaptureType type) async {
    final db = await DatabaseHelper.database;
    final maps = await db.query(
      'captures',
      where: 'type = ?',
      whereArgs: [type.name],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => CaptureEntry.fromMap(map)).toList();
  }

  Future<List<CaptureEntry>> getToday() async {
    final db = await DatabaseHelper.database;
    final startOfDay = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final maps = await db.query(
      'captures',
      where: 'createdAt >= ?',
      whereArgs: [startOfDay.toIso8601String()],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => CaptureEntry.fromMap(map)).toList();
  }

  Future<List<CaptureEntry>> getRecent(int limit) async {
    final db = await DatabaseHelper.database;
    final maps = await db.query(
      'captures',
      orderBy: 'createdAt DESC',
      limit: limit,
    );
    return maps.map((map) => CaptureEntry.fromMap(map)).toList();
  }

  Future<void> insert(CaptureEntry entry) async {
    final db = await DatabaseHelper.database;
    await db.insert('captures', entry.toMap());
  }

  Future<void> update(CaptureEntry entry) async {
    final db = await DatabaseHelper.database;
    await db.update(
      'captures',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<void> hardDelete(String id) async {
    final db = await DatabaseHelper.database;
    await db.delete('captures', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> delete(String id) async {
    final db = await DatabaseHelper.database;
    final item =
        await db.query('captures', where: 'id = ?', whereArgs: [id]);
    if (item.isNotEmpty) {
      await db.insert('deleted_items', {
        'id': id,
        'tableName': 'captures',
        'data': jsonEncode(item.first),
        'deletedAt': DateTime.now().toIso8601String(),
      });
      await db.delete('captures', where: 'id = ?', whereArgs: [id]);
    }
  }

  Future<bool> undoDelete(String id) async {
    final db = await DatabaseHelper.database;
    final deleted = await db.query(
      'deleted_items',
      where: 'id = ? AND tableName = ?',
      whereArgs: [id, 'captures'],
    );
    if (deleted.isEmpty) return false;

    final data =
        jsonDecode(deleted.first['data'] as String) as Map<String, dynamic>;
    await db.insert('captures', data);
    await db.delete('deleted_items', where: 'id = ?', whereArgs: [id]);
    return true;
  }

  Future<int> getTotalCount() async {
    final db = await DatabaseHelper.database;
    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM captures');
    return result.first['count'] as int;
  }

  Future<List<Map<String, dynamic>>> getDeletedItems() async {
    final db = await DatabaseHelper.database;
    return db.query(
      'deleted_items',
      where: 'tableName = ?',
      whereArgs: ['captures'],
      orderBy: 'deletedAt DESC',
    );
  }

  Future<void> permanentlyDelete(String id) async {
    final db = await DatabaseHelper.database;
    await db.delete('deleted_items', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> purgeExpiredItems() async {
    final db = await DatabaseHelper.database;
    final cutoff =
        DateTime.now().subtract(const Duration(days: 30)).toIso8601String();
    await db.delete(
      'deleted_items',
      where: 'tableName = ? AND deletedAt < ?',
      whereArgs: ['captures', cutoff],
    );
  }

  Future<int> getTodayCount() async {
    final db = await DatabaseHelper.database;
    final startOfDay = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM captures WHERE createdAt >= ?',
      [startOfDay.toIso8601String()],
    );
    return result.first['count'] as int;
  }
}
